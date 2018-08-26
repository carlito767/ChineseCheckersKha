package process;

import gato.Process;

class QuickLoadProcess implements Process {
  public var finished:Bool = false;

  var id:Int;

  public function new(id:Int) {
    this.id = id;
  };

  public function update(dt:Float):Void {
    if (Game.gamesave.load(id)) {
      Game.scene = Game.scenePlay;  
    }
    finished = true;
  }
}
