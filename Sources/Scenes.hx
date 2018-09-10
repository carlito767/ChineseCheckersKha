import kha.Assets;
import kha.input.KeyCode;

import gato.input.VirtualKey;

import board.Move;
import board.Player;
import board.Sequence;

import BoardChineseCheckers as GameBoard;
import UI.Dimensions;
import UI.UITileEmphasis;
import UI.UIWindow;
import process.ChangeLanguageProcess;
import process.SelectSequenceProcess;

class Scenes {
  public static function title(ui:UI):Void {
    var locale = Game.locale;

    ui.image({ image:Assets.images.BackgroundTitle, x:0, y:0, w:Game.WIDTH, h:Game.HEIGHT });

    ui.title({ text:locale.title1, x:Game.WIDTH * 0.45, y:Game.HEIGHT * 0.13, w:0, h:Game.HEIGHT * 0.167 });
    ui.title({ text:locale.title2, x:Game.WIDTH * 0.48, y:Game.HEIGHT * 0.3, w:0, h:Game.HEIGHT * 0.167 });

    if (ui.button({ text:locale.newGame, x:Game.WIDTH * 0.63, y:Game.HEIGHT * 0.58, w:Game.WIDTH * 0.38, h:Game.HEIGHT * 0.08 }).hit) {
      Game.scene = play;
    }
    if (ui.button({ text:'${locale.language} ${Game.settings.language.toUpperCase()}', x:Game.WIDTH * 0.63, y:Game.HEIGHT * 0.7, w:Game.WIDTH * 0.38, h:Game.HEIGHT * 0.08 }).hit) {
      Game.processQueue.add(new ChangeLanguageProcess());
    }
  }

  public static function play(ui:UI):Void {
    var gamesave = Game.gamesave;
    var locale = Game.locale;

    ui.image({ image:Assets.images.BackgroundPlay, x:0, y:0, w:Game.WIDTH, h:Game.HEIGHT });

    // Board
    var radius = Game.HEIGHT * 0.027;
    var distanceX = radius * 1.25;
    var distanceY = radius * 1.25 * 1.7;
    var boardWidth = (GameBoard.WIDTH - 1) * distanceX + radius * 2;
    var boardHeight = (GameBoard.HEIGHT - 1) * distanceY + radius * 2;
    var dx = (Game.WIDTH - boardWidth) * 0.5;
    var dy = (Game.HEIGHT - boardHeight) * 0.5;

    var selectableTiles:Array<Int> = [];
    if (gamesave.selectedTileId == null) {
      for (move in Board.allowedMoves(gamesave)) {
        if (!selectableTiles.contains(move.from)) {
          selectableTiles.push(move.from);
        }
      }
    }
    else {
      var selectedTile = gamesave.tiles[gamesave.selectedTileId];
      for (move in Board.allowedMovesForTile(gamesave, selectedTile)) {
        if (!selectableTiles.contains(move.to)) {
          selectableTiles.push(move.to);
        }
      }
    }

    for (tile in gamesave.tiles) {
      var tx = dx + (tile.x - 1) * distanceX;
      var ty = dy + (tile.y - 1) * distanceY;
      var selected = (gamesave.selectedTileId == tile.id);
      var selectable = selectableTiles.contains(tile.id);
      var emphasis:UITileEmphasis = None;
      if (selectable) {
        emphasis = (gamesave.selectedTileId == null) ? Selectable : AllowedMove;
      }
      else if (selected) {
        emphasis = Selected;
      }
      var player = (tile.piece == null) ? null : gamesave.players[tile.piece];
      if (ui.tile({ x:tx, y:ty, w:radius * 2, h: radius * 2, emphasis:emphasis, player:player, id:(Game.settings.showTileId) ? Std.string(tile.id) : null }).hit) {
        if (selected) {
          gamesave.selectedTileId = null;
        }
        else if (!selectable) {
          gamesave.selectedTileId = null;
          if (tile.piece != null && tile.piece == gamesave.currentPlayerId) {
            if (Board.allowedMovesForTile(gamesave, tile).length > 0) {
              gamesave.selectedTileId = tile.id;
            }
          }
        }
        else if (gamesave.selectedTileId == null) {
          gamesave.selectedTileId = tile.id;
        }
        else {
          var selectedTile = gamesave.tiles[gamesave.selectedTileId];
          Board.move(gamesave, selectedTile, tile);
        }
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

      var window:UIWindow = { x:Game.WIDTH * 0.2, y:Game.HEIGHT * 0.1, w:Game.WIDTH * 0.6, h:Game.HEIGHT * 0.8, title:locale.standings };
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
      var window:UIWindow = { x:Game.WIDTH * 0.3, y:Game.HEIGHT * 0.33, w:Game.WIDTH * 0.4, h:Game.HEIGHT * 0.34, title:locale.numberOfPlayers };
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
          selected:(Game.sequenceIndex == i),
          x:dimensions.left + dx * i,
          y:dimensions.top,
          w:w,
          h:w,
        }).hit) {
          Game.sequenceIndex = i;
        }
      }

      if (ui.button({ text:locale.play, disabled:(Game.sequenceIndex == null), x:dimensions.left, y:dimensions.bottom - Game.HEIGHT * 0.067, w:dimensions.width, h:Game.HEIGHT * 0.067 }).hit) {
        Board.start(gamesave);
      }
    }

    if (ui.button({ text:locale.quit, x:Game.WIDTH * 0.85, y:Game.WIDTH * 0.025, w:Game.WIDTH * 0.125, h:Game.HEIGHT * 0.067 }).hit) {
      Game.scene = title;
      Game.sequenceIndex = null;
    }
  }
}
