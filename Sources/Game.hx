import kha.Assets;
import kha.Framebuffer;

import Board;
import Board.ChineseCheckers;
import Board.Player;
import Board.Tile;
import Board.Sequence;
import Board.State;
import Mouse;
import Mui.MuiEval;
import Translations.language;
import Translations.tr;
import UI;
import UI.Dimensions;
import UI.UIWindow;

class Game {
  static public inline var TITLE = 'ChineseCheckersKha';
  static public inline var WIDTH = 800;
  static public inline var HEIGHT = 600;

  var mouse:Mouse = new Mouse();
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

  public function new() {
    language = 'en';
    screen = 'title';
    sequenceIndex = null;
  }

  public function update() {
  }

  public function render(framebuffer:Framebuffer) {
    var x = mouse.x * 1.0;
    var y = mouse.y * 1.0;
    var select = mouse.leftClick;

    var g = framebuffer.g2;
    g.begin();
    ui.begin(x, y, select);
    ui.g = g;

    switch screen {
    case 'title':
      ui.image({ image:Assets.images.BackgroundTitle, x:0, y:0, w:0, h:0 });

      ui.title({ text:tr('title1'), x:350, y:50, w:0, h:0 });
      ui.title({ text:tr('title2'), x:380, y:170, w:0, h:0 });

      if (ui.button({ text:tr('newGame'), x:WIDTH - 300, y:350, w:310, h:50 }).hit) {
        screen = 'play';
      }
      if (ui.button({ text:'${tr('language')} ${language.toUpperCase()}', x:WIDTH - 300, y:420, w:310, h:50 }).hit) {
        language = (language == 'en') ? 'fr' : 'en';
      }
    case 'play':
      // Auto start if there is only one sequence
      if (sequenceIndex == null && ChineseCheckers.sequences.length == 1) {
        sequenceIndex = 0;
        state.ready = true;
      }

      ui.image({ image:Assets.images.BackgroundPlay, x:0, y:0, w:0, h:0 });

      // Board
      var radius = 16;
      var distanceX = radius * 1.25;
      var distanceY = radius * 1.25 * 1.7;
      var boardWidth = ((state.width - 1) * distanceX) + (2 * radius);
      var boardHeight = ((state.height - 1) * distanceY) + (2 * radius);
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
        var player = (tile.piece == null) ? null : state.players[tile.piece];
        if (ui.tile({ x:tx, y:ty, w:radius * 2, h: radius * 2, emphasis:allowedMove || selected, player:player }).hit) {
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

      // Current player
      if (currentPlayer != null) {
        ui.player({ x:20, y:20, w:100, h:100, player:currentPlayer });
      }

      if (state.ready) {
        if (Board.isOver(state)) {
          var window:UIWindow = { x:0, y:0, w:WIDTH, h:HEIGHT, title:tr('standings') };
          ui.window(window);
          var x = WIDTH * 0.2;
          var y = HEIGHT * 0.2;
          var w = WIDTH - 2 * x;
          var h = HEIGHT * 0.1;
          for (i in 0...state.standings.length) {
            var dy = i * HEIGHT * 0.12;
            var player:Null<Player> = state.players[state.standings[i]];
            ui.rank({ x:x, y:y + dy, w:w, h:h, rank:Std.string(i+1), player:player });
          }
        }
      }
      else {
        var window:UIWindow = { x:250, y:220, w:300, h:160, title:tr('numberOfPlayers') };
        var dimensions:Dimensions = UI.dimensions(window);
        ui.window(window);

        var nb = ChineseCheckers.sequences.length;
        var dx = (dimensions.right - dimensions.left - (nb * 50) - ((nb - 2) * 10)) * 0.5;
        for (i in 0...nb) {
          var sequence:Sequence = ChineseCheckers.sequences[i];
          if (ui.button({
            text:Std.string(sequence.length),
            x:dimensions.left + dx + (i * 60),
            y:dimensions.top + 35,
            w:40,
            h:40,
            selected:(sequenceIndex == i),
          }).hit) {
            sequenceIndex = i;
          }
        }

        if (ui.button({ text:tr('play'), disabled:(sequenceIndex == null), x:dimensions.left, y:dimensions.bottom - 40, w:dimensions.width, h:40 }).hit) {
          state.ready = true;
        }
      }

      if (ui.button({ text:tr('quit'), x:680, y:20, w:100, h:40 }).hit) {
        sequenceIndex = null;
        screen = 'title';
      }
    }

    ui.end();
    g.end();
  }
}
