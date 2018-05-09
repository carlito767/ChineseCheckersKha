import kha.input.Keyboard as KhaKeyboard;
import kha.input.KeyCode;
import kha.input.Mouse as KhaMouse;

import Signal.Signal0;

typedef Command = {
  var keys:Array<KeyCode>;
  var slot:Void->Void;
  @:optional var repeat:Bool;
  @:optional var active:Bool;
}

typedef Keyboard = {
  var keys:Map<KeyCode, Bool>;
  var read:Map<KeyCode, Bool>;
}

typedef Mouse = {
  var x:Float;
  var y:Float;
  var buttons:Map<Int, Bool>;
}

class Input {
  public static var keyboard(default, null):Keyboard = { keys:new Map(), read:new Map() };
  public static var mouse(default, null):Mouse = { x:0, y:0, buttons:new Map() };

  static var commands:Map<Signal0, Command> = new Map();

  public static function init() {
    var khaKeyboard = KhaKeyboard.get();
    if (khaKeyboard != null) {
      khaKeyboard.notify(onKeyDown, onKeyUp, null);
    }

    var khaMouse = KhaMouse.get();
    if (khaMouse != null) {
      khaMouse.notify(onMouseDown, onMouseUp, null, null);
    }
  }

  public static function connect(command:Command):Signal0 {
    var signal = new Signal0();
    signal.connect(command.slot);
    commands.set(signal, command);
    return signal;
  }

  public static function disconnect(signal:Signal0) {
    var command = commands[signal];
    if (command != null) {
      signal.disconnect(command.slot);
      commands.remove(signal);
    }
  }

  //
  // Keyboard
  //

  public static function keyDown(key:KeyCode):Bool {
    return (keyboard.keys[key] == true);
  }

  public static function keyPressed(key:KeyCode, ?repeat:Bool = false):Bool {
    if (!repeat && keyboard.read[key] == true) {
      return false;
    }
    var pressed = (keyboard.keys[key] == true);
    if (pressed) {
      keyboard.read[key] = true;
    }
    return pressed;
  }

  static function onKeyDown(key:KeyCode) {
    keyboard.keys[key] = true;

    for (signal in commands.keys()) {
      var command = commands[signal];
      if (command != null && (command.active != true || command.repeat == true) && command.keys.indexOf(key) != -1) {
        var active = true;
        for (key in command.keys) {
          if (keyboard.keys[key] != true) {
            active = false;
            break;
          }
        }
        command.active = active;
        if (active) {
          signal.emit();
        }
      }
    }
  }

  static function onKeyUp(key:KeyCode) {
    keyboard.keys[key] = false;
    keyboard.read[key] = false;

    for (command in commands) {
      if (command.active == true && command.keys.indexOf(key) != -1) {
        command.active = false;
      }
    }
  }

  //
  // Mouse
  //

  static function onMouseDown(button:Int, x:Int, y:Int) {
    mouse.x = x;
    mouse.y = y;
    mouse.buttons[button] = true;
  }

  static function onMouseUp(button:Int, x:Int, y:Int) {
    mouse.x = x;
    mouse.y = y;
    mouse.buttons[button] = false;
  }
}
