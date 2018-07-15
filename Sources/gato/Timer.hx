package gato;

import kha.Scheduler;

class Timer {
  var lastTime:Float;

  public function new() {
    lastTime = Scheduler.time();
  }

  public function update():Float {
    var currentTime = Scheduler.time();
    var dt = currentTime - lastTime;
    lastTime = currentTime;
    return dt;
  }
}
