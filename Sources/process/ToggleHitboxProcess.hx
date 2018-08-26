package process;

import gato.Process;

class ToggleHitboxProcess implements Process {
  public var finished:Bool = false;

  public function new() {
  };

  public function update(dt:Float):Void {
    UI.showHitbox = !UI.showHitbox;
    finished = true;
  }
}
