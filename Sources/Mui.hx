//
// Minimal UI
//
// Inspired by: Immediate Mode GUI: https://mollyrocket.com/861
//

import kha.Scheduler;

import gato.input.Input;
import gato.input.VirtualKey;

typedef MuiEval = {
  var hot:Bool;
  var active:Bool;
  var hit:Bool;
  var longPress:Bool;
  var longPressRatio:Float;
}

typedef MuiId = Int;

typedef MuiInput = {
  var x:Float;
  var y:Float;
  var select:Bool;
}

typedef MuiObject = {
  var x:Float;
  var y:Float;
  var w:Float;
  var h:Float;
  @:optional var disabled:Bool;
}

class Mui {
  static inline var LONG_PRESS_BEGIN = 0.2;
  static inline var LONG_PRESS_END = 0.6;

  // Time
  var lastTime:Float = Scheduler.time();

  // Objects counter
  var idCounter:Int = 0;

  // Current frame
  var hot:Null<MuiId> = null;
  var active:Null<MuiId> = null;
  var hit:Null<MuiId> = null;
  var longPress:Null<MuiId> = null;
  var longPressDuration:Float = 0.0;

  // Next frame
  var next:Null<MuiId> = null;

  // Input
  var x:Float = 0.0;
  var y:Float = 0.0;
  var select:Bool = false;

  public function begin() {
    x = Input.mouseX;
    y = Input.mouseY;
    select = Input.isPressed(VirtualKey.MouseLeftButton);

    idCounter = 0;
    next = null;
  }

  public function new() {
  }

  public function end() {
    var currentTime = Scheduler.time();
    var dt = currentTime - lastTime;
    lastTime = currentTime;

    hot = null;
    hit = null;
    longPress = null;

    if (next != null) {
      hot = next;
      if (select) {
        if (active != next) {
          active = next;
          longPressDuration = 0.0;
        }
        else if (longPressDuration < LONG_PRESS_END) {
          longPressDuration = longPressDuration + dt;
          if (longPressDuration >= LONG_PRESS_END) {
            longPress = next;
          }
        }
      }
      else if (active == next && longPressDuration < LONG_PRESS_BEGIN) {
        hit = next;
      }
    }
    if (!select) {
      active = null;
    }
  }

  public function evaluate<T:(MuiObject)>(object:T):MuiEval {
    if (object.disabled == true) {
      return {
        hot:false,
        active:false,
        hit:false,
        longPress:false,
        longPressRatio:0.0,
      }
    }

    var id:MuiId = ++idCounter;

    // Next frame
    if (x >= object.x && y >= object.y && x <= object.x + object.w && y <= object.y + object.h) {
      next = id;
    }

    // Current frame
    var longPressRatio:Float = 0.0;
    if (id == active && longPressDuration > LONG_PRESS_BEGIN) {
      longPressRatio = Math.min(longPressDuration / LONG_PRESS_END, 1.0);
    }

    return {
      hot:(id == hot),
      active:(id == active),
      hit:(id == hit),
      longPress:(id == longPress),
      longPressRatio:longPressRatio,
    }
  }
}
