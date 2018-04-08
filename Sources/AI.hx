import Board;
import Board.Move;
import Board.Player;
import Board.Tile;
import Board.State;

class AI {
  static public function search(state:State, ?depth:Int = 1):Null<Move> {
    var currentPlayer = Board.currentPlayer(state);
    if (currentPlayer == null) {
      return null;
    }

    var bestEvaluation:Null<Int> = null;
    var bestMoves:Array<Move> = [];
    for (tile in state.tiles) {
      if (tile.piece == currentPlayer.id) {
        var moves = Board.allowedMoves(state, tile);
        for (move in moves) {
          Board.move(state, tile, move);
          var evaluation = evaluate(state, currentPlayer);
          if (bestEvaluation == null || bestEvaluation > evaluation) {
            bestEvaluation = evaluation;
            bestMoves = [{ from:tile.id, to:move.id }];
          }
          else if (bestEvaluation == evaluation) {
            bestMoves.push({ from:tile.id, to:move.id });
          }
          Board.cancelLastMove(state);
        }
      }
    }
    trace('bestEvaluation:$bestEvaluation');
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
    var note = 0;
    for (tile in state.tiles) {
      if (tile.piece == player.id && tile.owner != player.id) {
        for (goal in state.tiles) {
          if (goal.owner == player.id && goal.piece != player.id && used.indexOf(goal.id) == -1) {
            used.push(goal.id);
            note += distance(tile, goal);
            break;
          }
        }
      }
    }
    return note;
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
