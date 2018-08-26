package process;

import gato.Process;

class UndoProcess implements Process {
  public var finished:Bool = false;

  public function new() {
  };

  public function update(dt:Float):Void {
    if (Board.isRunning(Game.gamesave)) {
      Board.cancelLastMove(Game.gamesave);
    }
    finished = true;
  }
}
