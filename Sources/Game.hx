import kha.Assets;
import kha.Framebuffer;
import kha.input.KeyCode;

import AI;
import Board;
import Board.Player;
import Board.Tile;
import Board.Sequence;
import Board.State;
import Input;
import Sequencer;
import Storage;
import Translations.language;
import Translations.tr;
import UI;
import UI.Dimensions;
import UI.UITileEmphasis;
import UI.UIWindow;

typedef Settings = {
  var version:Int;
  var language:String;
}

class Game {
  static public inline var TITLE = 'ChineseCheckersKha';
  static public inline var WIDTH = 800;
  static public inline var HEIGHT = 600;

  var aiMode(default, set):Bool = false;
  function set_aiMode(value) {
    sequencer.reset();
    return aiMode = value;
  }

  var sequencer:Sequencer<State> = new Sequencer();

  var ui:UI = new UI();

  var screen:String;

  var sequenceIndex(default, set):Null<Int>;
  function set_sequenceIndex(value) {
    aiMode = false;
    state = Board.create(value);
    return sequenceIndex = value;
  }
  var state:State;

  var showTileId:Bool = false;

  public function new() {
    loadSettings();
    Input.init();
    screen = 'title';
    sequenceIndex = null;
  }

  public function update() {
    sequencer.update(state);
    updateScreen();
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

    switch (settings.version) {
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
  // Update
  //

  function updateScreen() {
    if (Input.keyPressed(KeyCode.L)) {
      // Language
      language = (language == 'en') ? 'fr' : 'en';
      saveSettings();
    }
    else if (Input.keyPressed(KeyCode.Decimal)) {
      UI.showHitbox = !UI.showHitbox;
    }
    else if (Input.keyPressed(KeyCode.Numpad1) || Input.keyPressed(KeyCode.Numpad2) || Input.keyPressed(KeyCode.Numpad3)) {
      var save = 1;
      if (Input.keyDown(KeyCode.Numpad2)) {
        save = 2;
      }
      else if (Input.keyDown(KeyCode.Numpad3)) {
        save = 3;
      }
      var filename = 'gamesave$save';

      if (Input.keyDown(KeyCode.Alt)) {
        // Quick Save
        if (Board.isRunning(state)) {
          trace('Quick Save $save');
          Storage.write(filename, Board.save(state));
        }
      }
      else {
        // Quick Load
        var gamesave:Null<State> = Board.load(Storage.read(filename));
        if (gamesave != null) {
          trace('Quick Load $save');
          aiMode = false;
          state = gamesave;
          screen = 'play';
          return;
        }
      }
    }

    switch screen {
    case 'title':
    case 'play':
      if (Input.keyPressed(KeyCode.Backspace)) {
        // Cancel last move
        aiMode = false;
        Board.cancelLastMove(state);
      }
      else if (Input.keyPressed(KeyCode.Return)) {
        // Restore sequencer speed
        sequencer.speed = 1.0;
      }
      else if (Input.keyPressed(KeyCode.Add)) {
        // Increase sequencer speed
        sequencer.speed *= 2;
      }
      else if (Input.keyPressed(KeyCode.Subtract)) {
        sequencer.speed *= 0.5;
      }
      else if (Input.keyPressed(KeyCode.H)) {
        // Hint
        AI.search(state);
      }
      else if (Input.keyPressed(KeyCode.M)) {
        // Moves
        trace('moves:${state.moves}');
      }
      else if (Input.keyPressed(KeyCode.P)) {
        // Play/Pause
        aiMode = !aiMode;
      }
      else if (Input.keyPressed(KeyCode.S)) {
        // State
        trace('state:$state');
      }
      else if (Input.keyPressed(KeyCode.Numpad0)) {
        showTileId = !showTileId;
      }
    }
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
        language = (language == 'en') ? 'fr' : 'en';
        saveSettings();
      }
    case 'play':
      ui.image({ image:Assets.images.BackgroundPlay, x:0, y:0, w:WIDTH, h:HEIGHT, disabled:true });

      // Board
      var radius = HEIGHT * 0.027;
      var distanceX = radius * 1.25;
      var distanceY = radius * 1.25 * 1.7;
      var boardWidth = (state.width - 1) * distanceX + radius * 2;
      var boardHeight = (state.height - 1) * distanceY + radius * 2;
      var dx = (WIDTH - boardWidth) * 0.5;
      var dy = (HEIGHT - boardHeight) * 0.5;
      var moves = state.allowedMoves;
      var disabled = (!Board.isRunning(state) || aiMode);
      for (tile in state.tiles) {
        var tx = dx + (tile.x - 1) * distanceX;
        var ty = dy + (tile.y - 1) * distanceY;
        var selectable = (moves.indexOf(tile) > -1);
        var selected = (state.selectedTile == tile);
        var emphasis:UITileEmphasis = None;
        if (!aiMode && !sequencer.busy() && selectable) {
          emphasis = (state.selectedTile == null) ? Selectable : AllowedMove;
        }
        else if (selected) {
          emphasis = Selected;
        }
        var player = (tile.piece == null) ? null : state.players[tile.piece];
        if (ui.tile({ x:tx, y:ty, w:radius * 2, h: radius * 2, emphasis:emphasis, player:player, id:(showTileId) ? Std.string(tile.id) : null, disabled:disabled }).hit) {
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
        if (aiMode && !sequencer.busy()) {
          var move = AI.search(state);
          if (move != null) {
            sequencer.push(aiSelectTile, move.from, 0.5);
            sequencer.push(aiMove, move, 0.5);
          }
        }
      }
      else {
        var window:UIWindow = { x:WIDTH * 0.3, y:HEIGHT * 0.33, w:WIDTH * 0.4, h:HEIGHT * 0.34, title:tr('numberOfPlayers') };
        var dimensions:Dimensions = UI.dimensions(window);
        ui.window(window);

        var sequences = Board.sequences();
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
