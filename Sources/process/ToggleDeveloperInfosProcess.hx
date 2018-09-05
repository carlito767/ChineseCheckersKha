package process;

import gato.Process;

class ToggleDeveloperInfosProcess implements Process {
  public var finished:Bool = false;

  public function new() {
  };

  public function update(dt:Float):Void {
    Game.settings.showDeveloperInfos = !Game.settings.showDeveloperInfos;
    finished = true;
  }
}
