import kha.input.Mouse as KhaMouse;

import Mui.MuiInput;

class Mouse {
  public var input(default, null):MuiInput = { x:0, y:0, select:false };

  var mouse:Null<KhaMouse> = null;

  public function new() {
    mouse = KhaMouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  //
  // Callbacks
  //

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    input.x = x;
    input.y = y;
    if (button == 0) {
      input.select = true;
    }
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
    if (button == 0) {
      input.select = false;
    }
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
    input.x = x;
    input.y = y;
  }

  function onMouseWheel(delta:Int):Void {
  }
}
