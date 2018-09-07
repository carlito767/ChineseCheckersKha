import board.Move;

class AI {
  // TODO: [carlito 20180907] Minimax algorithm
  public static function minimax(gamesave:Gamesave):Null<Move> {
    if (gamesave.sequence.length != 2) {
      // Works only with 2 players
      return null;
    }

    if (gamesave.currentPlayer == null) {
      // No player, no move
      return null;
    }

    // TODO:[carlito 20180907] use Board.allowedMoves instead
    var moves:Array<Move> = [];
    var player = gamesave.currentPlayer; 
    for (from in gamesave.tiles) {
      if (from.piece == player.id) {
        for (to in Board.allowedMovesForTile(gamesave, from)) {
          moves.push({ from:from.id, to:to.id });
        }
      }
    }
    if (moves.length > 0) {
      var moveIndex = Math.floor(Math.random() * moves.length);
      return moves[moveIndex];
    }

    return null;
  }
}
