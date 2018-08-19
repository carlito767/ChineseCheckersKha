import kha.Assets;
import kha.input.KeyCode;

import gato.input.VirtualKey;

import board.Move;
import board.Player;
import board.Sequence;

import BoardChineseCheckers as GameBoard;
import Translations.tr;
import UI.Dimensions;
import UI.UITileEmphasis;
import UI.UIWindow;

class ScenePlay extends Scene {
  var sequenceIndex(default, set):Null<Int>;
  function set_sequenceIndex(value) {
    var sequence = (value == null) ? null : GameBoard.sequences[value];
    Game.gamesave = Board.create(GameBoard.tiles, GameBoard.players, sequence);
    return sequenceIndex = value;
  }

  public function new() {
    super();
    keymap.set(VirtualKey.L, Action('ChangeLanguage'));
    keymap.set(VirtualKey.Decimal, Action('ToggleHitbox'));
    keymap.set(VirtualKey.Number0, Action('ToggleTileId'));
    keymap.set(VirtualKey.Number1, Action('QuickLoad1'));
    keymap.set(VirtualKey.Number2, Action('QuickLoad2'));
    keymap.set(VirtualKey.Number3, Action('QuickLoad3'));
    keymap.set(VirtualKey.Number7, Action('QuickSave1'));
    keymap.set(VirtualKey.Number8, Action('QuickSave2'));
    keymap.set(VirtualKey.Number9, Action('QuickSave3'));
    keymap.set(VirtualKey.Backspace, Action('Undo'));

    sequenceIndex = null;
  }

  override public function render(ui:UI):Void {
    var gamesave = Game.gamesave;

    ui.image({ image:Assets.images.BackgroundPlay, x:0, y:0, w:Game.WIDTH, h:Game.HEIGHT, disabled:true });

    // Board
    var radius = Game.HEIGHT * 0.027;
    var distanceX = radius * 1.25;
    var distanceY = radius * 1.25 * 1.7;
    var boardWidth = (GameBoard.WIDTH - 1) * distanceX + radius * 2;
    var boardHeight = (GameBoard.HEIGHT - 1) * distanceY + radius * 2;
    var dx = (Game.WIDTH - boardWidth) * 0.5;
    var dy = (Game.HEIGHT - boardHeight) * 0.5;
    var moves = gamesave.allowedMoves;
    for (tile in gamesave.tiles) {
      var tx = dx + (tile.x - 1) * distanceX;
      var ty = dy + (tile.y - 1) * distanceY;
      var selectable = false;
      for (move in moves) {
        selectable = (tile.id == move.id);
        if (selectable) {
          break;
        }
      }
      var selected = (gamesave.selectedTile != null && gamesave.selectedTile.id == tile.id);
      var emphasis:UITileEmphasis = None;
      if (selectable) {
        emphasis = (gamesave.selectedTile == null) ? Selectable : AllowedMove;
      }
      else if (selected) {
        emphasis = Selected;
      }
      var player = (tile.piece == null) ? null : gamesave.players[tile.piece];
      if (ui.tile({ x:tx, y:ty, w:radius * 2, h: radius * 2, emphasis:emphasis, player:player, id:(Game.settings.showTileId) ? Std.string(tile.id) : null }).hit) {
        if (selected) {
          gamesave.selectedTile = null;
        }
        else if (!gamesave.allowedMoves.contains(tile)) {
          gamesave.selectedTile = null;
          if (tile.piece == gamesave.currentPlayer.id) {
            if (Board.allowedMovesForTile(gamesave, tile).length > 0) {
              gamesave.selectedTile = tile;
            }
          }
        }
        else if (gamesave.selectedTile == null) {
          gamesave.selectedTile = tile;
        }
        else {
          Board.applyMove(gamesave, gamesave.selectedTile, tile);
          gamesave.selectedTile = null;
        }
        Board.update(gamesave);
      }
    }

    if (Board.isOver(gamesave)) {
      var standings:Array<Player> = [];
      for (playerId in gamesave.standings) {
        standings.push(gamesave.players[playerId]);
      }
      // Who is the great loser?
      for (player in gamesave.players) {
        if (!gamesave.standings.contains(player.id)) {
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
    else if (!Board.isRunning(gamesave)) {
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
        Board.start(gamesave);
      }
    }

    if (ui.button({ text:tr.quit, x:Game.WIDTH * 0.85, y:Game.WIDTH * 0.025, w:Game.WIDTH * 0.125, h:Game.HEIGHT * 0.067 }).hit) {
      sequenceIndex = null;
      Game.scene = Game.sceneTitle;
    }
  }
}
