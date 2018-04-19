import Board;
import Board.Move;
import Board.Player;
import Board.Tile;
import Board.State;

class AI {
  static public function search(state:State, ?depth:Int = 1):Null<Move> {
    if (!Board.isRunning(state)) {
      return null;
    }

    var player = state.currentPlayer;
    var bestScore:Null<Int> = null;
    var bestMoves:Array<Move> = [];
    for (tile in state.allowedMoves) {
      var moves = Board.allowedMovesForTile(state, tile);
      for (move in moves) {
        Board.applyMove(state, tile, move);
        var score = evaluate(state, player);
        trace('from:${tile.id}, to:${move.id}, score:$score');
        if (bestScore == null || bestScore > score) {
          bestScore = score;
          bestMoves = [{ from:tile.id, to:move.id }];
        }
        else if (bestScore == score) {
          bestMoves.push({ from:tile.id, to:move.id });
        }
        Board.cancelMove(state);
      }
    }
    trace('bestScore:$bestScore');
    trace('bestMoves:$bestMoves');
    if (bestMoves.length == 0) {
      return null;
    }
    var i = Math.floor(Math.random() * bestMoves.length);
    var bestMove = bestMoves[i];
    trace('bestMove:$bestMove');
    return bestMove;
  }

  static function evaluate(state:State, player:Player):Int {
    var used:Array<Int> = [];
    var score = 0;
    for (goal in state.tiles) {
      if (goal.owner == player.id && goal.piece != player.id) {
        var bestScore:Null<Int> = null;
        var bestTile:Null<Int> = null;
        for (tile in state.tiles) {
          if (tile.piece == player.id && tile.owner != player.id && used.indexOf(tile.id) == -1) {
            var score = distance(tile, goal);
            if (bestScore == null || bestScore > score) {
              bestScore = score;
              bestTile = tile.id;
            }
          }
        }
        score += bestScore;
        used.push(bestTile);
      }
    }
    return score;
  }

  static function distance(from:Tile, to:Tile):Int {
    var dx = Math.abs(to.x - from.x);
    var dy = Math.abs(to.y - from.y);
    if (dy > dx) {
      return Std.int(dy);
    }
    else {
      return Std.int((dx - dy) * 0.5 + dy);
    }
  }
}
