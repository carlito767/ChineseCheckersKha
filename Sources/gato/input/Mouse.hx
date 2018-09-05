package gato.input;

import kha.input.Mouse as KhaMouse;

class Mouse extends Controller {
  public var x(default, null):Int = 0;
  public var y(default, null):Int = 0;
  public var movementX(default, null):Int = 0;
  public var movementY(default, null):Int = 0;
  public var delta(default, null):Int = 0;

  var mouse:Null<KhaMouse> = null;

  public function start():Void {
    if (mouse != null) {
      stop();
    }

    mouse = KhaMouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  public function stop():Void {
    if (mouse != null) {
      mouse.remove(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
      mouse = null;
      down = new Map();
    }
  }

  //
  // Callbacks
  //

  function mouseButtonToVirtualKey(button:Int):Null<VirtualKey> {
    return switch button {
      case 0: VirtualKey.MouseLeftButton;
      case 1: VirtualKey.MouseRightButton;
      case 2: VirtualKey.MouseMiddleButton;
      default: null;
    }
  }

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    this.x = x;
    this.y = y;
    onPressed(mouseButtonToVirtualKey(button));
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
    this.x = x;
    this.y = y;
    onReleased(mouseButtonToVirtualKey(button));
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
    this.x = x;
    this.y = y;
    this.movementX = movementX;
    this.movementY = movementY;
  }

  function onMouseWheel(delta:Int):Void {
    this.delta = delta;
  }
}
