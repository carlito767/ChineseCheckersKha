import kha.Assets;
import kha.input.KeyCode;

import gato.input.VirtualKey;

import Board.Move;
import Board.Player;
import Board.Sequence;
import Board.State;
import BoardChineseCheckers as GameBoard;
import Translations.language;
import Translations.tr;
import UI.Dimensions;
import UI.UITileEmphasis;
import UI.UIWindow;

class ScenePlay extends Scene {
  var sequenceIndex(default, set):Null<Int>;
  function set_sequenceIndex(value) {
    var sequence = (value == null) ? null : GameBoard.sequences[value];
    Game.state = Board.create(GameBoard.tiles, GameBoard.players, sequence);
    return sequenceIndex = value;
  }

  var aiTurn:Bool = false;

  public function new() {
    super();
    keymap.set(VirtualKey.Number0, Action('ShowTileId'));
    keymap.set(VirtualKey.Number1, Action('QuickLoad1'));
    keymap.set(VirtualKey.Number2, Action('QuickLoad2'));
    keymap.set(VirtualKey.Number3, Action('QuickLoad3'));
    keymap.set(VirtualKey.Number7, Action('QuickSave1'));
    keymap.set(VirtualKey.Number8, Action('QuickSave2'));
    keymap.set(VirtualKey.Number9, Action('QuickSave3'));

    sequenceIndex = null;
  }

  override public function leave() {
    super.leave();
    AI.reset();
  }

  override public function update() {
    for (command in keymap.commands()) {
      switch command {
      case Action('ShowTileId'):
        Settings.showTileId = !Settings.showTileId;
      case Action('QuickLoad1'):
        Game.quickLoad(1);
      case Action('QuickLoad2'):
        Game.quickLoad(2);
      case Action('QuickLoad3'):
        Game.quickLoad(3);
      case Action('QuickSave1'):
        Game.quickSave(1);
      case Action('QuickSave2'):
        Game.quickSave(2);
      case Action('QuickSave3'):
        Game.quickSave(3);
      default:
        trace('Unknown command: $command');
      }
    }

    aiTurn = Game.state.sequence.length == 2 && Game.state.currentPlayer != null && Game.state.currentPlayer.id != 1;
    if (aiTurn) {
      AI.initialize(Game.state);
    }
  }

  override public function render(ui:UI) {
    var state = Game.state;

    ui.image({ image:Assets.images.BackgroundPlay, x:0, y:0, w:Game.WIDTH, h:Game.HEIGHT, disabled:true });

    // Board
    var radius = Game.HEIGHT * 0.027;
    var distanceX = radius * 1.25;
    var distanceY = radius * 1.25 * 1.7;
    var boardWidth = (GameBoard.WIDTH - 1) * distanceX + radius * 2;
    var boardHeight = (GameBoard.HEIGHT - 1) * distanceY + radius * 2;
    var dx = (Game.WIDTH - boardWidth) * 0.5;
    var dy = (Game.HEIGHT - boardHeight) * 0.5;
    var moves = state.allowedMoves;
    for (tile in state.tiles) {
      var tx = dx + (tile.x - 1) * distanceX;
      var ty = dy + (tile.y - 1) * distanceY;
      var selectable = false;
      for (move in moves) {
        selectable = (tile.id == move.id);
        if (selectable) {
          break;
        }
      }
      var selected = (state.selectedTile != null && state.selectedTile.id == tile.id);
      var emphasis:UITileEmphasis = None;
      if (!aiTurn && !Sequencer.busy() && selectable) {
        emphasis = (state.selectedTile == null) ? Selectable : AllowedMove;
      }
      else if (selected) {
        emphasis = Selected;
      }
      var player = (tile.piece == null) ? null : state.players[tile.piece];
      if (ui.tile({ x:tx, y:ty, w:radius * 2, h: radius * 2, emphasis:emphasis, player:player, id:(Settings.showTileId) ? Std.string(tile.id) : null, disabled:aiTurn }).hit) {
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

      var window:UIWindow = { x:Game.WIDTH * 0.2, y:Game.HEIGHT * 0.1, w:Game.WIDTH * 0.6, h:Game.HEIGHT * 0.8, title:tr.standings };
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
    else if (!Board.isRunning(state)) {
      var window:UIWindow = { x:Game.WIDTH * 0.3, y:Game.HEIGHT * 0.33, w:Game.WIDTH * 0.4, h:Game.HEIGHT * 0.34, title:tr.numberOfPlayers };
      var dimensions:Dimensions = UI.dimensions(window);
      ui.window(window);

      var sequences = GameBoard.sequences;
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

      if (ui.button({ text:tr.play, disabled:(sequenceIndex == null), x:dimensions.left, y:dimensions.bottom - Game.HEIGHT * 0.067, w:dimensions.width, h:Game.HEIGHT * 0.067 }).hit) {
        Board.start(state);
      }
    }

    if (ui.button({ text:tr.quit, x:Game.WIDTH * 0.85, y:Game.WIDTH * 0.025, w:Game.WIDTH * 0.125, h:Game.HEIGHT * 0.067 }).hit) {
      sequenceIndex = null;
      Game.scene = Game.sceneTitle;
    }
  }
}
