import kha.Scheduler;

import Timer;

class Sequencer<T> {
  var timer:Timer;

  var tasks:Array<T->Dynamic->Bool>;
  var parameters:Array<Dynamic>;
  var delays:Array<Float>;

  var currentTask:Null<T->Dynamic->Bool>;
  var currentParameter:Dynamic;
  var currentDelay:Float;

  public function new() {
    timer = new Timer();
    tasks = [];
    parameters = [];
    delays = [];
    currentTask = null;
    currentDelay = 0;
  }

  public function busy():Bool {
    return (currentTask != null || tasks.length > 0);
  }

  public function push(task:T->Dynamic->Bool, ?parameter:Dynamic, ?delay:Float = 0) {
    tasks.push(task);
    parameters.push(parameter);
    delays.push(delay);
  }

  public function update(object:T) {
    var dt = timer.update();
    if (!busy()) {
      return;
    }
    if (currentTask == null) {
      currentTask = tasks.shift();
      currentParameter = parameters.shift();
      currentDelay = delays.shift();
    }
    else if (currentDelay > 0) {
      currentDelay -= dt;
    }
    if (currentDelay > 0) {
      return;
    }

    if (currentTask(object, currentParameter)) {
      currentTask = null;
    }
  }
}
