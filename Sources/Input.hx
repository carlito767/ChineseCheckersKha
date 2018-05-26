import kha.input.Keyboard as KhaKeyboard;
import kha.input.KeyCode;
import kha.input.Mouse as KhaMouse;

typedef Keyboard = {
  var keys:Map<KeyCode, Bool>;
}

typedef Mouse = {
  var x:Float;
  var y:Float;
  var buttons:Map<Int, Bool>;
}

class Input {
  public static var keyboard(default, null):Keyboard = { keys:new Map() };
  public static var mouse(default, null):Mouse = { x:0, y:0, buttons:new Map() };

  public static function initialize() {
    var khaKeyboard = KhaKeyboard.get();
    if (khaKeyboard != null) {
      khaKeyboard.notify(onKeyDown, onKeyUp, null);
    }

    var khaMouse = KhaMouse.get();
    if (khaMouse != null) {
      khaMouse.notify(onMouseDown, onMouseUp, null, null);
    }
  }

  //
  // Keyboard
  //

  static function onKeyDown(key:KeyCode) {
    keyboard.keys[key] = true;
  }

  static function onKeyUp(key:KeyCode) {
    keyboard.keys[key] = false;
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
