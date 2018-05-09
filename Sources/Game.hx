import kha.Assets;
import kha.Framebuffer;
import kha.input.KeyCode;

import Board.Move;
import Board.Player;
import Board.Sequence;
import Board.State;
import Translations.language;
import Translations.tr;
import UI.Dimensions;
import UI.UITileEmphasis;
import UI.UIWindow;

typedef Settings = {
  var version:Int;
  var language:String;
}

@:allow(IScene)
class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  var scenes:Map<String, IScene>;

  var pause:Bool = false;

  var sequencer:Sequencer<State> = new Sequencer();

  var ui:UI = new UI();

  var screen(default, set):String;
  function set_screen(value) {
    var currentScene = scenes[screen];
    if (currentScene != null) {
      currentScene.leave();
    }
    var newScene = scenes[value];
    if (newScene != null) {
      newScene.enter();
    }
    return screen = value;
  }

  var sequenceIndex(default, set):Null<Int>;
  function set_sequenceIndex(value) {
    pause = false;
    state = Board.create(value);
    return sequenceIndex = value;
  }
  var state:State;

  var showTileId:Bool = false;

  public function new() {
    loadSettings();

    Input.init();
    Input.connect({ keys:[KeyCode.L], slot:changeLanguage });
    Input.connect({ keys:[KeyCode.Decimal], slot:function() { UI.showHitbox = !UI.showHitbox; } });
    Input.connect({ keys:[KeyCode.Numpad0], slot:function() { showTileId = !showTileId; } });
    Input.connect({ keys:[KeyCode.Numpad1], slot:function() { quickLoad(1); } });
    Input.connect({ keys:[KeyCode.Numpad2], slot:function() { quickLoad(2); } });
    Input.connect({ keys:[KeyCode.Numpad3], slot:function() { quickLoad(3); } });
    Input.connect({ keys:[KeyCode.Alt, KeyCode.Numpad1], slot:function() { quickSave(1); } });
    Input.connect({ keys:[KeyCode.Alt, KeyCode.Numpad2], slot:function() { quickSave(2); } });
    Input.connect({ keys:[KeyCode.Alt, KeyCode.Numpad3], slot:function() { quickSave(3); } });

    scenes = [
      "title" => new SceneTitle(this),
      "play" => new ScenePlay(this),
    ];

    screen = 'title';
    sequenceIndex = null;
  }

  public function update() {
    sequencer.update(state);
  }

  public function render(framebuffer:Framebuffer) {
    var g = framebuffer.g2;
    var x = Input.mouse.x;
    var y = Input.mouse.y;
    var select = (Input.mouse.buttons[0] == true);
    g.begin();
    ui.preRender(g, WIDTH, HEIGHT, { x:x, y:y, select:select });
    renderScreen();
    ui.postRender();
    g.end();
  }

  //
  // Settings
  //

  static inline var SETTINGS_VERSION = 1;

  function checkSettings(settings:Null<Settings>):Settings {
    var defaults:Settings = { version:SETTINGS_VERSION, language:'en' };

    if (settings == null) {
      return defaults;
    }

    switch settings.version {
    case SETTINGS_VERSION:
    default:
      trace('Settings: unknown version');
      return defaults;
    }

    return settings;
  }

  function loadSettings() {
    var settings:Settings = checkSettings(Storage.read('settings'));
    language = settings.language;
  }

  function saveSettings() {
    var settings:Settings = { version:SETTINGS_VERSION, language:language };
    Storage.write('settings', settings);
  }

  //
  // Language
  //

  function changeLanguage() {
    language = (language == 'en') ? 'fr' : 'en';
    saveSettings();
  }

  //
  // Quick Load/Save
  //

  function quickLoad(id:Int) {
    var gamesave:Null<State> = Board.load(Storage.read('gamesave$id'));
    if (gamesave == null) {
      return;
    }

    trace('Quick Load $id');
    state = gamesave;
    screen = 'play';
  }

  function quickSave(id:Int) {
    if (Board.isRunning(state)) {
      trace('Quick Save $id');
      Storage.write('gamesave$id', Board.save(state));
    }
  }

  //
  // Sequencing
  //

  function aiSelectTile(state:State, id:Int):Bool {
    state.selectedTile = state.tiles[id];
    return true;
  }

  function aiMove(state:State, move:Move):Bool {
    Board.move(state, state.tiles[move.from], state.tiles[move.to]);
    return true;
  }

  //
  // Render
  //

  function renderScreen() {
    switch screen {
    case 'title':
      ui.image({ image:Assets.images.BackgroundTitle, x:0, y:0, w:WIDTH, h:HEIGHT, disabled:true });

      ui.title({ text:tr('title1'), x:WIDTH * 0.45, y:HEIGHT * 0.13, w:0, h:HEIGHT * 0.167, disabled:true });
      ui.title({ text:tr('title2'), x:WIDTH * 0.48, y:HEIGHT * 0.3, w:0, h:HEIGHT * 0.167, disabled:true });

      if (ui.button({ text:tr('newGame'), x:WIDTH * 0.63, y:HEIGHT * 0.58, w:WIDTH * 0.38, h:HEIGHT * 0.08 }).hit) {
        screen = 'play';
      }
      if (ui.button({ text:'${tr('language')} ${language.toUpperCase()}', x:WIDTH * 0.63, y:HEIGHT * 0.7, w:WIDTH * 0.38, h:HEIGHT * 0.08 }).hit) {
        changeLanguage();
      }
    case 'play':
      ui.image({ image:Assets.images.BackgroundPlay, x:0, y:0, w:WIDTH, h:HEIGHT, disabled:true });

      // Board
      var radius = HEIGHT * 0.027;
      var distanceX = radius * 1.25;
      var distanceY = radius * 1.25 * 1.7;
      var boardWidth = (Board.WIDTH - 1) * distanceX + radius * 2;
      var boardHeight = (Board.HEIGHT - 1) * distanceY + radius * 2;
      var dx = (WIDTH - boardWidth) * 0.5;
      var dy = (HEIGHT - boardHeight) * 0.5;
      var moves = state.allowedMoves;
      var human = Board.isRunning(state) && state.currentPlayer.kind == Human;
      for (tile in state.tiles) {
        var tx = dx + (tile.x - 1) * distanceX;
        var ty = dy + (tile.y - 1) * distanceY;
        var selectable = (moves.indexOf(tile) > -1);
        var selected = (state.selectedTile == tile);
        var emphasis:UITileEmphasis = None;
        if (human && !sequencer.busy() && selectable) {
          emphasis = (state.selectedTile == null) ? Selectable : AllowedMove;
        }
        else if (selected) {
          emphasis = Selected;
        }
        var player = (tile.piece == null) ? null : state.players[tile.piece];
        if (ui.tile({ x:tx, y:ty, w:radius * 2, h: radius * 2, emphasis:emphasis, player:player, id:(showTileId) ? Std.string(tile.id) : null, disabled:!human }).hit) {
          if (tile == state.selectedTile) {
            state.selectedTile = null;
          }
          else if (state.allowedMoves.indexOf(tile) == -1) {
            state.selectedTile = null;
            if (tile.piece == state.currentPlayer.id) {
              if (Board.allowedMovesForTile(state, tile).length > 0) {
                state.selectedTile = tile;
              }
            }
          }
          else if (state.selectedTile == null) {
            state.selectedTile = tile;
          }
          else {
            Board.applyMove(state, state.selectedTile, tile);
            state.selectedTile = null;
          }
          Board.update(state);
        }
      }

      if (Board.isOver(state)) {
        var standings:Array<Player> = [];
        for (playerId in state.standings) {
          standings.push(state.players[playerId]);
        }
        // Who is the great loser?
        for (player in state.players) {
          if (state.standings.indexOf(player.id) == -1) {
            standings.push(player);
          }
        }

        var window:UIWindow = { x:WIDTH * 0.2, y:HEIGHT * 0.1, w:WIDTH * 0.6, h:HEIGHT * 0.8, title:tr('standings') };
        var dimensions:Dimensions = UI.dimensions(window);
        ui.window(window);

        var nb = standings.length;
        var h = (dimensions.height - (nb - 1) * dimensions.margin) / nb;
        var dy = (dimensions.height + dimensions.margin) / nb;
        for (i in 0...nb) {
          ui.rank({
            rank:Std.string(i+1),
            player:standings[i],
            x:dimensions.left,
            y:dimensions.top + dy * i,
            w:dimensions.width,
            h:h,
          });
        }
      }
      else if (Board.isRunning(state)) {
        if (!pause && !human && !sequencer.busy()) {
          var move:Null<Move> = null;
          switch state.currentPlayer.kind {
          case AiEasy:
            move = AI.search(state);
          default:
          }
          if (move != null) {
            sequencer.push(aiSelectTile, move.from, 0.3);
            sequencer.push(aiMove, move, 0.3);
          }
        }
      }
      else {
        var window:UIWindow = { x:WIDTH * 0.3, y:HEIGHT * 0.33, w:WIDTH * 0.4, h:HEIGHT * 0.34, title:tr('numberOfPlayers') };
        var dimensions:Dimensions = UI.dimensions(window);
        ui.window(window);

        var sequences = Board.SEQUENCES;
        var nb = sequences.length;
        var w = (dimensions.width - (nb - 1) * dimensions.margin) / nb;
        var dx = (dimensions.width + dimensions.margin) / nb;
        for (i in 0...nb) {
          var sequence:Sequence = sequences[i];
          if (ui.button({
            text:Std.string(sequence.length),
            selected:(sequenceIndex == i),
            x:dimensions.left + dx * i,
            y:dimensions.top,
            w:w,
            h:w,
          }).hit) {
            sequenceIndex = i;
          }
        }

        if (ui.button({ text:tr('play'), disabled:(sequenceIndex == null), x:dimensions.left, y:dimensions.bottom - HEIGHT * 0.067, w:dimensions.width, h:HEIGHT * 0.067 }).hit) {
          Board.start(state);
        }
      }

      if (ui.button({ text:tr('quit'), x:WIDTH * 0.85, y:WIDTH * 0.025, w:WIDTH * 0.125, h:HEIGHT * 0.067 }).hit) {
        sequenceIndex = null;
        screen = 'title';
      }
    }
  }
}
