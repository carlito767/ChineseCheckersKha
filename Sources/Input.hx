import kha.input.Mouse as KhaMouse;

typedef Mouse = {
  var x:Float;
  var y:Float;
  var buttons:Map<Int, Bool>;
}

class Input {
  static public var mouse(default, null):Mouse = { x:0, y:0, buttons:new Map<Int, Bool>() };

  static public function init() {
    var khaMouse = KhaMouse.get();
    if (khaMouse != null) {
      khaMouse.notify(onMouseDown, onMouseUp, null, null);
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
