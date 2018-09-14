package process;

import gato.Process;

class ToggleDebugOverlayProcess implements Process {
  public var finished:Bool = false;

  public function new() {
  };

  public function update(dt:Float):Void {
    Game.settings.showDebugOverlay = !Game.settings.showDebugOverlay;
    finished = true;
  }
}
