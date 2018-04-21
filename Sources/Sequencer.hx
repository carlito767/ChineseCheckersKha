import kha.Scheduler;

import Timer;

class Sequencer<T> {
  public var speed(default, set):Float;
  function set_speed(value) {
    if (value <= 0.0) {
      value = 1.0;
    }
    trace('speed:$value');
    return speed = value;
  }

  var timer:Timer;

  var tasks:Array<T->Dynamic->Bool>;
  var parameters:Array<Dynamic>;
  var delays:Array<Float>;

  var currentTask:Null<T->Dynamic->Bool>;
  var currentParameter:Dynamic;
  var currentDelay:Float;

  var doReset:Bool;

  public function new() {
    init();
  }

  function init() {
    timer = new Timer();
    tasks = [];
    parameters = [];
    delays = [];
    currentTask = null;
    currentDelay = 0;
    doReset = false;
    speed = 1.0;
  }

  public function busy():Bool {
    return (currentTask != null || tasks.length > 0);
  }

  public function reset() {
    doReset = true;
  }

  public function push(task:T->Dynamic->Bool, ?parameter:Dynamic, ?delay:Float = 0) {
    tasks.push(task);
    parameters.push(parameter);
    delays.push(delay);
  }

  public function update(object:T) {
    var dt = timer.update();
    if (doReset) {
      init();
      return;
    }
    if (!busy()) {
      return;
    }
    if (currentTask == null) {
      currentTask = tasks.shift();
      currentParameter = parameters.shift();
      currentDelay = delays.shift();
    }
    else if (currentDelay > 0) {
      currentDelay -= dt * speed;
    }
    if (currentDelay > 0) {
      return;
    }

    if (currentTask(object, currentParameter)) {
      currentTask = null;
    }
  }
}
