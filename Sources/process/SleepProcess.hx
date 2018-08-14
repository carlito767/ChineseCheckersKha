package process;

import gato.Process;

class SleepProcess implements Process {
  public var finished:Bool = false;

  var duration:Float;

  public function new(duration:Float) {
    this.duration = duration;
  };

  public function update(dt:Float) {
    duration -= dt;
    if (duration <= 0) {
      finished = true;
    }
  }
}
