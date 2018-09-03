package process;

import gato.Process;

class ToggleHitboxProcess implements Process {
  public var finished:Bool = false;

  public function new() {
  };

  public function update(dt:Float):Void {
    Game.settings.showHitbox = !Game.settings.showHitbox;
    UI.showHitbox = Game.settings.showHitbox;
    finished = true;
  }
}
