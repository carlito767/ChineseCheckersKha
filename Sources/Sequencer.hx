import kha.Scheduler;

import Timer;

typedef Task = Void->Bool;

class Sequencer {
  var timer:Timer;

  var tasks:Array<Task>;
  var delays:Array<Float>;

  var currentTask:Null<Task>;
  var currentDelay:Float;

  public function new() {
    timer = new Timer();
    tasks = new Array();
    delays = new Array();
    currentTask = null;
    currentDelay = 0;
  }

  public function busy():Bool {
    return (currentTask != null || tasks.length > 0);
  }

  public function update() {
    var dt = timer.update();
    if (!busy()) {
      return;
    }
    if (currentTask == null) {
      currentTask = tasks.shift();
      currentDelay = delays.shift();
    }
    else if (currentDelay > 0) {
      currentDelay -= dt;
    }
    if (currentDelay > 0) {
      return;
    }

    if (currentTask()) {
      currentTask = null;
    }
  }

  public function addTask(task:Task, ?delay:Float = 0) {
    tasks.push(task);
    delays.push(delay);
  }
}
