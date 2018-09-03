package process;

import gato.Process;

class ToggleFPSProcess implements Process {
  public var finished:Bool = false;

  public function new() {
  };

  public function update(dt:Float):Void {
    Game.settings.showFPS = !Game.settings.showFPS;
    finished = true;
  }
}
