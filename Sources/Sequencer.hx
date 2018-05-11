// Inspired by: https://github.com/juakob/SequenceCode

import kha.Scheduler;

import Timer;

class Sequencer<T> {
  var timer:Timer;

  var tasks:Array<T->Dynamic->Void>;
  var parameters:Array<Dynamic>;
  var delays:Array<Float>;

  var currentDelay:Null<Float>;

  public function new() {
    timer = new Timer();
    tasks = [];
    parameters = [];
    delays = [];
    currentDelay = null;
  }

  public function busy():Bool {
    return (currentDelay != null || delays.length > 0);
  }

  public function push(task:T->Dynamic->Void, ?parameter:Dynamic, ?delay:Float = 0) {
    tasks.push(task);
    parameters.push(parameter);
    delays.push(delay);
  }

  public function update(object:T) {
    var dt = timer.update();
    if (!busy()) {
      return;
    }
    if (currentDelay == null) {
      currentDelay = delays.shift();
    }
    else if (currentDelay > 0) {
      currentDelay -= dt;
    }
    if (currentDelay > 0) {
      return;
    }

    currentDelay = null;
    var task = tasks.shift();
    var parameter = parameters.shift();
    task(object, parameter);
  }
}
