import kha.Assets;
import kha.Framebuffer;
import kha.input.KeyCode;

import AI;
import Board;
import Board.ChineseCheckers;
import Board.Player;
import Board.Tile;
import Board.Sequence;
import Board.State;
import Input;
import Storage;
import Storage.StorageData;
import Translations.language;
import Translations.tr;
import UI;
import UI.Dimensions;
import UI.UITileEmphasis;
import UI.UIWindow;

typedef Settings = {
  > StorageData,
  var language:String;
}

class Game {
  static public inline var TITLE = 'ChineseCheckersKha';
  static public inline var WIDTH = 800;
  static public inline var HEIGHT = 600;

  var settings:Settings;

  var ui:UI = new UI();

  var screen:String;

  var sequenceIndex(default, set):Null<Int>;
  function set_sequenceIndex(value) {
    state = Board.create(value);
    selectedTile = null;
    return sequenceIndex = value;
  }
  var state:Null<State>;

  var selectedTile:Null<Tile>;

  // 0: None
  // 1: Id
  // 2: Position
  var tileInfo:Int = 0;

  public function new() {
    loadSettings();
    Input.init();
    screen = 'title';
    sequenceIndex = null;
  }

  public function update() {
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

  function loadSettings() {
    settings = Storage.read('settings', {
      version:1,
      language:'en',
    });
    language = settings.language;
  }

  function saveSettings() {
    settings.language = language;
    Storage.write('settings', settings);
  }

  //
  // Update
  //

  function updateScreen() {
    #if kha_html5
    if (Input.keyPressed(KeyCode.A)) {
      if (state != null && state.ready == true) {
        AI.search(state);
      }
    }
    else if (Input.keyPressed(KeyCode.L)) {
      language = (language == 'en') ? 'fr' : 'en';
      saveSettings();
    }
    else if (Input.keyPressed(KeyCode.Decimal)) {
      UI.showBoundsRectangles = !UI.showBoundsRectangles;
    }
    else if (Input.keyPressed(KeyCode.Numpad0)) {
      tileInfo++;
      if (tileInfo > 3) {
        tileInfo = 0;
      }
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
        if (state != null && state.ready == true) {
          trace('Quick Save $save');
          Storage.write(filename, state);
        }
      }
      else {
        // Quick Load
        var gamesave:State = Storage.read(filename);
        if (gamesave != null && gamesave.ready == true) {
          trace('Quick Load $save');
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
        if (state.ready && !Board.isOver(state)) {
          if (selectedTile == null) {
            Board.cancelLastMove(state);
          }
          else {
            selectedTile = null;
          }
        }
      }
    }
    #end
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
      var currentPlayer:Null<Player> = null;
      var moves:Array<Tile> = [];
      if (state != null) {
        currentPlayer = Board.currentPlayer(state);
        if (selectedTile != null) {
          moves = Board.allowedMoves(state, selectedTile);
        }
      }
      for (tile in state.tiles) {
        var tx = dx + (tile.x - 1) * distanceX;
        var ty = dy + (tile.y - 1) * distanceY;
        var allowedMove = (moves.indexOf(tile) > -1);
        var selected = (selectedTile == tile);
        var emphasis:UITileEmphasis = None;
        if (selected) {
          emphasis = Selected;
        }
        else if (allowedMove) {
          emphasis = AllowedMove;
        }
        else if (selectedTile == null && Board.allowedMoves(state, tile).length > 0) {
          emphasis = Selectable;
        }
        var player = (tile.piece == null) ? null : state.players[tile.piece];
        var info = switch tileInfo {
          case 1:
            Std.string(tile.id);
          case 2:
            'x:${tile.x}, y:${tile.y}';
          default:
            null;
        }
        if (ui.tile({ x:tx, y:ty, w:radius * 2, h: radius * 2, emphasis:emphasis, player:player, info:info }).hit) {
          if (allowedMove) {
            Board.move(state, selectedTile, tile);
            selectedTile = null;
          }
          if (!selected && Board.allowedMoves(state, tile).length > 0) {
            selectedTile = tile;
          }
          else {
            selectedTile = null;
          }
        }
      }

      if (state.ready) {
        if (Board.isOver(state)) {
          var window:UIWindow = { x:WIDTH * 0.2, y:HEIGHT * 0.1, w:WIDTH * 0.6, h:HEIGHT * 0.8, title:tr('standings') };
          var dimensions:Dimensions = UI.dimensions(window);
          ui.window(window);

          var nb = state.standings.length;
          var h = (dimensions.height - (nb - 1) * dimensions.margin) / nb;
          var dy = (dimensions.height + dimensions.margin) / nb;
          for (i in 0...nb) {
            var player:Null<Player> = state.players[state.standings[i]];
            ui.rank({
              rank:Std.string(i+1),
              player:player,
              x:dimensions.left,
              y:dimensions.top + dy * i,
              w:dimensions.width,
              h:h,
            });
          }
        }
      }
      else {
        var window:UIWindow = { x:WIDTH * 0.3, y:HEIGHT * 0.33, w:WIDTH * 0.4, h:HEIGHT * 0.34, title:tr('numberOfPlayers') };
        var dimensions:Dimensions = UI.dimensions(window);
        ui.window(window);

        var nb = ChineseCheckers.sequences.length;
        var w = (dimensions.width - (nb - 1) * dimensions.margin) / nb;
        var dx = (dimensions.width + dimensions.margin) / nb;
        for (i in 0...nb) {
          var sequence:Sequence = ChineseCheckers.sequences[i];
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
          state.ready = true;
        }
      }

      if (ui.button({ text:tr('quit'), x:WIDTH * 0.85, y:WIDTH * 0.025, w:WIDTH * 0.125, h:HEIGHT * 0.067 }).hit) {
        sequenceIndex = null;
        screen = 'title';
      }
    }
  }
}
