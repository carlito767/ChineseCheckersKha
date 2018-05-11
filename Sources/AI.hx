import Board.Move;
import Board.Tile;
import Board.State;

// Minimax (2 players)
class AI {
  public static var started:Bool = false;
  public static var played:Bool = false;

  static var depth:UInt;
  static var maximizer:Int;
  static var minimizer:Int;

  static var allowedMoves:Array<Tile>;
  static var tile:Null<Tile>;
  static var tileMoves:Null<Array<Tile>>;
  static var tileMove:Null<Tile>;
  static var bestScore:Null<Int>;
  static var bestMoves:Array<Move>;

  public static function update(state:State) {
    if (played) {
      return;
    }

    if (!started) {
      started = true;

      depth = 0;
      maximizer = state.currentPlayer.id;
      minimizer = (state.sequence[0] == maximizer) ? state.sequence[1] : state.sequence[0];

      allowedMoves = Board.allowedMoves(state);
      tile = null;
      tileMoves = [];
      bestScore = null;
      bestMoves = [];
    }

    if (tile == null) {
      tile = allowedMoves.shift();
      tileMoves = null;
    }
    if (tile == null) {
      played = true;
      if (bestMoves.length > 0) {
        var i = Math.floor(Math.random() * bestMoves.length);
        var move = bestMoves[i];
        trace('bestMove:$move');
        Game.sequencer.push(Game.aiSelectTile, move.from, 0.3);
        Game.sequencer.push(Game.aiMove, move, 0.3);
      }
    }
    else {
      if (tileMoves == null) {
        tileMoves = Board.allowedMovesForTile(state, tile);
      }
      var move = tileMoves.shift();
      if (move == null) {
        tile = null;
      }
      else {
        trace('Search from ${tile.id} to ${move.id}...');
        Board.move(state, tile, move);
        var score:Null<Int> = explore(state);
        if (score != null) {
          if (bestScore == null || score > bestScore) {
            bestScore = score;
            bestMoves = [{ from:tile.id, to:move.id }];
          }
          else if (bestScore == score) {
            bestMoves.push({ from:tile.id, to:move.id });
          }
        }
        Board.cancelLastMove(state);
      }
    }
  }

  static function explore(state:State):Null<Int> {
    if (depth == 0 || state.currentPlayer == null) {
      return evaluate(state);
    }

    var isMaximizer = (state.currentPlayer.id == maximizer);
    if (isMaximizer) {
      depth--;
    }

    var f = (isMaximizer) ? Math.max : Math.min;

    var bestScore:Null<Int> = null;
    for (tile in state.allowedMoves) {
      var moves = Board.allowedMovesForTile(state, tile);
      for (move in moves) {
        Board.move(state, tile, move);
        var score:Null<Int> = (depth == 0) ? evaluate(state) : explore(state);
        if (score != null) {
          bestScore = (bestScore == null) ? score : Std.int(f(score, bestScore));
        }
        Board.cancelMove(state);
      }
    }

    if (isMaximizer) {
      depth++;
    }
    return bestScore;
  }

  static function evaluate(state:State):Int {
    return distances(state, minimizer) - distances(state, maximizer);
  }

  static function distances(state:State, id:Int) {
    var distances = 0;
    for (tile in state.tiles) {
      if (tile.piece == id && tile.owner != id) {
        for (goal in state.tiles) {
          if (goal.owner == id && goal.piece != id) {
            distances += distance(tile, goal);
          }
        }
      }
    }
    return distances;
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
