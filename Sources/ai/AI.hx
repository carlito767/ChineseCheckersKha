package ai;

import board.Move;

interface AI {
  public function search(gamesave:Gamesave):Null<Move>;
}
