import kha.Assets;

import Localization.language;
import Localization.locale;
import board.Board;
import board.Move;
import board.Player;
import board.Sequence;
import ui.UI;

class Scenes {
  public static function title(ui:UI):Void {
    ui.image({ image:Assets.images.BackgroundTitle, x:0, y:0, w:WIDTH, h:HEIGHT });

    ui.title({ text:locale.title1, x:WIDTH * 0.45, y:HEIGHT * 0.13, w:0, h:HEIGHT * 0.167 });
    ui.title({ text:locale.title2, x:WIDTH * 0.48, y:HEIGHT * 0.3, w:0, h:HEIGHT * 0.167 });

    if (ui.button({ text:locale.newGame, x:WIDTH * 0.63, y:HEIGHT * 0.58, w:WIDTH * 0.38, h:HEIGHT * 0.08 }).hit) {
      Game.ME.scene = play;
    }
    if (ui.button({ text:'${locale.language} ${language.toUpperCase()}', x:WIDTH * 0.63, y:HEIGHT * 0.7, w:WIDTH * 0.38, h:HEIGHT * 0.08 }).hit) {
      Localization.next();
    }
  }

  public static function play(ui:UI):Void {
    var state = Game.ME.state;

    ui.image({ image:Assets.images.BackgroundPlay, x:0, y:0, w:WIDTH, h:HEIGHT });

    // Board
    var radius = HEIGHT * 0.027;
    var distanceX = radius * 1.25;
    var distanceY = radius * 1.25 * 1.7;
    var boardWidth = (Game.ME.board.WIDTH - 1) * distanceX + radius * 2;
    var boardHeight = (Game.ME.board.HEIGHT - 1) * distanceY + radius * 2;
    var dx = (WIDTH - boardWidth) * 0.5;
    var dy = (HEIGHT - boardHeight) * 0.5;

    var selectableTiles:Array<Int> = [];
    if (Game.ME.selectedTileId == null) {
      for (move in Board.allowedMoves(state)) {
        if (!selectableTiles.contains(move.from)) {
          selectableTiles.push(move.from);
        }
      }
    }
    else {
      var selectedTile = state.tiles[Game.ME.selectedTileId];
      for (move in Board.allowedMovesForTile(state, selectedTile)) {
        if (!selectableTiles.contains(move.to)) {
          selectableTiles.push(move.to);
        }
      }
    }

    for (tile in state.tiles) {
      var tx = dx + (tile.x - 1) * distanceX;
      var ty = dy + (tile.y - 1) * distanceY;
      var selected = (Game.ME.selectedTileId == tile.id);
      var selectable = selectableTiles.contains(tile.id);
      var emphasis:UITileEmphasis = None;
      if (selectable) {
        emphasis = (Game.ME.selectedTileId == null) ? Selectable : AllowedMove;
      }
      else if (selected) {
        emphasis = Selected;
      }
      var color = (tile.piece == null) ? null : state.players[tile.piece].color;
      if (ui.tile({ x:tx, y:ty, w:radius * 2, h: radius * 2, emphasis:emphasis, color:color }).hit) {
        if (selected) {
          Game.ME.selectedTileId = null;
        }
        else if (!selectable) {
          Game.ME.selectedTileId = null;
          if (tile.piece != null && tile.piece == state.currentPlayerId) {
            if (Board.allowedMovesForTile(state, tile).length > 0) {
              Game.ME.selectedTileId = tile.id;
            }
          }
        }
        else if (Game.ME.selectedTileId == null) {
          Game.ME.selectedTileId = tile.id;
        }
        else {
          var selectedTile = state.tiles[Game.ME.selectedTileId];
          Board.move(state, selectedTile, tile);
          Game.ME.selectedTileId = null;
        }
      }
    }

    if (Board.isOver(state)) {
      Game.ME.selectedTileId = null;

      var standings:Array<Player> = [];
      for (playerId in state.standings) {
        standings.push(state.players[playerId]);
      }
      // Who is the great loser?
      for (player in state.players) {
        if (!state.standings.contains(player.id)) {
          standings.push(player);
        }
      }

      var window:UIWindow = { x:WIDTH * 0.2, y:HEIGHT * 0.1, w:WIDTH * 0.6, h:HEIGHT * 0.8, title:locale.standings };
      var dimensions:Dimensions = UI.dimensions(window);
      ui.window(window);

      var n = standings.length;
      var h = dimensions.height / n;
      for (i in 0...n) {
        ui.rank({
          rank:Std.string(i+1),
          color:standings[i].color,
          x:dimensions.left,
          y:dimensions.top + h * i,
          w:dimensions.width,
          h:h,
        });
      }
    }
    else if (!Board.isRunning(state)) {
      var window:UIWindow = { x:WIDTH * 0.3, y:HEIGHT * 0.33, w:WIDTH * 0.4, h:HEIGHT * 0.25, title:locale.numberOfPlayers };
      var dimensions:Dimensions = UI.dimensions(window);
      ui.window(window);

      var sequences = Game.ME.board.sequences;
      var n = sequences.length;
      var spacing = 0.3;
      var w = dimensions.width / (n + spacing * (n + 1));
      var h = Math.min(dimensions.height * 0.9, w);
      var margin = w * spacing;
      var dx = margin;
      var dy = (dimensions.height - h) * 0.45;
      for (i in 0...n) {
        var sequence:Sequence = sequences[i];
        if (ui.button({
          text:Std.string(sequence.length),
          selected:(Game.ME.selectedSequenceIndex == i),
          x:dimensions.left + dx + ((w + margin) * i),
          y:dimensions.top + dy,
          w:w,
          h:h,
        }).hit) {
          Game.ME.selectedSequenceIndex = i;
        }
      }

      if (ui.button({ text:locale.play, disabled:(Game.ME.selectedSequenceIndex == null), x:dimensions.left, y:dimensions.bottom + HEIGHT * 0.01, w:dimensions.width, h:HEIGHT * 0.067 }).hit) {
        Board.start(state);
      }
    }

    if (ui.button({ text:locale.quit, x:WIDTH * 0.85, y:WIDTH * 0.025, w:WIDTH * 0.125, h:HEIGHT * 0.067 }).hit) {
      Game.ME.scene = title;
      Game.ME.selectedSequenceIndex = null;
    }
  }
}
