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
    var note = 0;
    for (tile in state.tiles) {
      if (tile.piece == player.id) {
        note += distance(state, tile);
      }
    }
    return note;
  }

  static public function distance(state:State, tile:Tile):Int {
    if (tile.piece == null || tile.piece == tile.owner) {
      return 0;
    }
    var goal:Null<Int> = switch tile.piece {
      case 1: 1;
      case 2: 23;
      case 3: 111;
      case 4: 121;
      case 5: 99;
      case 6: 11;
      default: null;
    }
    if (goal == null) {
      return 0;
    }
    var destination = state.tiles[goal];
    if (destination == null) {
      return 0;
    }
    var dx = Math.abs(destination.x - tile.x);
    var dy = Math.abs(destination.y - tile.y);
    if (dy > dx) {
      return Std.int(dy);
    }
    else {
      return Std.int((dx - dy) * 0.5 + dy);
    }
  }
}
