// Inspired by: https://github.com/juakob/SequenceCode

import kha.Scheduler;

import Timer;

class Sequencer {
  static var timer:Timer;

  static var tasks:Array<Void->Void>;
  static var delays:Array<Float>;

  static var currentTask:Null<Void->Void>;
  static var currentDelay:Float;

  public static function initialize() {
    timer = new Timer();
    tasks = [];
    delays = [];
    currentTask = null;
    currentDelay = 0;
  }

  public static function busy():Bool {
    return (currentTask != null || tasks.length > 0);
  }

  public static function push(task:Void->Void, ?delay:Float = 0) {
    tasks.push(task);
    delays.push(delay);
  }

  public static function update() {
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

    currentTask();
    currentTask = null;
  }
}
