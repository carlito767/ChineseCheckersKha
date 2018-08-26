package process;

import gato.Process;

class QuickSaveProcess implements Process {
  public var finished:Bool = false;

  var id:Int;

  public function new(id:Int) {
    this.id = id;
  };

  public function update(dt:Float):Void {
    if (Board.isRunning(Game.gamesave)) {
      Game.gamesave.save(id);
    }
    finished = true;
  }
}
