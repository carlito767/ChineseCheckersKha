package gato;

import kha.Scheduler;

class Timer {
  public var deltaTime(default, null):Float;
  public var elapsedTime(default, null):Float;

  var startTime:Float;
  var previousTime:Float;

  public function new() {
    reset();
  }

  public function reset():Void {
    startTime = Scheduler.realTime();
    previousTime = startTime;
    deltaTime = 0.0;
    elapsedTime = 0.0;
  }

  public function update():Void {
    var currentTime = Scheduler.realTime();
    deltaTime = currentTime - previousTime;
    elapsedTime = currentTime - startTime;
    previousTime = currentTime;
  }
}
