package gato.input;

import kha.input.Mouse as KhaMouse;

class Mouse implements Controller {
  public var buttons(default, null):Map<Int, Bool>;
  public var x(default, null):Int;
  public var y(default, null):Int;
  public var movementX(default, null):Int;
  public var movementY(default, null):Int;
  public var delta(default, null):Int;

  var mouse:Null<KhaMouse> = null;

  public function new() {
    reset();
    mouse = KhaMouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  public function reset():Void {
    buttons = new Map();
    x = 0;
    y = 0;
    movementX = 0;
    movementY = 0;
    delta = 0;
  }

  public function dispose():Void {
    if (mouse != null) {
      mouse.remove(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
      mouse = null;
      reset();
    }
  }

  //
  // Update Input Status
  //

  function mouseButtonToVirtualKey(button:Int):Null<VirtualKey> {
    return switch button {
      case 0: VirtualKey.MouseLeftButton;
      case 1: VirtualKey.MouseRightButton;
      case 2: VirtualKey.MouseMiddleButton;
      default: null;
    }
  }

  public function updateInputStatus(inputStatus:InputStatus):Void {
    for (button in buttons.keys()) {
      var vk = mouseButtonToVirtualKey(button);
      if (vk != null) {
        inputStatus.isDown[vk] = true;
      }
    }
    inputStatus.x = x;
    inputStatus.y = y;
    inputStatus.movementX = movementX;
    inputStatus.movementY = movementY;
    inputStatus.delta = delta;
  }

  //
  // Callbacks
  //

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    buttons[button] = true;
    this.x = x;
    this.y = y;
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
    buttons.remove(button);
    this.x = x;
    this.y = y;
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
