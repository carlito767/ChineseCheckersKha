package process;

import gato.Process;

class ToggleTileIdProcess implements Process {
  public var finished:Bool = false;

  public function new() {
  };

  public function update(dt:Float):Void {
    Game.settings.showTileId = !Game.settings.showTileId;
    finished = true;
  }
}
