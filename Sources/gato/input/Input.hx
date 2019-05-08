package gato.input;

import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.input.Mouse;

class Input {
  var inputStatus:InputStatus;

  var keyboard:Null<Keyboard> = null;
  var mouse:Null<Mouse> = null;

  public function new() {
    reset();
  }

  public function reset():Void {
    inputStatus = {
      isDown:new Map(),
      wasDown:new Map(),
      x:0,
      y:0,
      movementX:0,
      movementY:0,
      delta:0,
    };
  }

  public function initialize():Void {
    keyboard = Keyboard.get();
    if (keyboard != null) {
      keyboard.notify(onKeyDown, onKeyUp, null);
    }

    mouse = Mouse.get();
    if (mouse != null) {
      mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
    }
  }

  public function terminate():Void {
    if (keyboard != null) {
      keyboard.remove(onKeyDown, onKeyUp, null);
      keyboard = null;
    }

    if (mouse != null) {
      mouse.remove(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
      mouse = null;
    }

    reset();
  }

  public function update():InputStatus {
    var currentStatus:InputStatus = {
      isDown:inputStatus.isDown,
      wasDown:inputStatus.wasDown,
      x:inputStatus.x,
      y:inputStatus.y,
      movementX:inputStatus.movementX,
      movementY:inputStatus.movementY,
      delta:inputStatus.delta,
    };

    inputStatus.wasDown = new Map();
    for (vk in inputStatus.isDown.keys()) {
      inputStatus.wasDown[vk] = inputStatus.isDown[vk];
    }
    inputStatus.movementX = 0;
    inputStatus.movementY = 0;
    inputStatus.delta = 0;

    return currentStatus;
  }

  //
  // Callbacks
  //

  // Keyboard

  var KeyCodeToVirtualKey:Map<KeyCode, VirtualKey> = [
    KeyCode.A => VirtualKey.A,
    KeyCode.B => VirtualKey.B,
    KeyCode.C => VirtualKey.C,
    KeyCode.D => VirtualKey.D,
    KeyCode.E => VirtualKey.E,
    KeyCode.F => VirtualKey.F,
    KeyCode.G => VirtualKey.G,
    KeyCode.H => VirtualKey.H,
    KeyCode.I => VirtualKey.I,
    KeyCode.J => VirtualKey.J,
    KeyCode.K => VirtualKey.K,
    KeyCode.L => VirtualKey.L,
    KeyCode.M => VirtualKey.M,
    KeyCode.N => VirtualKey.N,
    KeyCode.O => VirtualKey.O,
    KeyCode.P => VirtualKey.P,
    KeyCode.Q => VirtualKey.Q,
    KeyCode.R => VirtualKey.R,
    KeyCode.S => VirtualKey.S,
    KeyCode.T => VirtualKey.T,
    KeyCode.U => VirtualKey.U,
    KeyCode.V => VirtualKey.V,
    KeyCode.W => VirtualKey.W,
    KeyCode.X => VirtualKey.X,
    KeyCode.Y => VirtualKey.Y,
    KeyCode.Z => VirtualKey.Z,

    KeyCode.Numpad0 => VirtualKey.Number0,
    KeyCode.Numpad1 => VirtualKey.Number1,
    KeyCode.Numpad2 => VirtualKey.Number2,
    KeyCode.Numpad3 => VirtualKey.Number3,
    KeyCode.Numpad4 => VirtualKey.Number4,
    KeyCode.Numpad5 => VirtualKey.Number5,
    KeyCode.Numpad6 => VirtualKey.Number6,
    KeyCode.Numpad7 => VirtualKey.Number7,
    KeyCode.Numpad8 => VirtualKey.Number8,
    KeyCode.Numpad9 => VirtualKey.Number9,

    KeyCode.Decimal => VirtualKey.Decimal,
    KeyCode.Colon => VirtualKey.Colon,
    KeyCode.Semicolon => VirtualKey.Semicolon,

    KeyCode.Add => VirtualKey.Add,
    KeyCode.Subtract => VirtualKey.Subtract,
    KeyCode.Multiply => VirtualKey.Multiply,
    KeyCode.Divide => VirtualKey.Divide,

    KeyCode.Insert => VirtualKey.Insert,
    KeyCode.Delete => VirtualKey.Decimal,

    KeyCode.Left => VirtualKey.Left,
    KeyCode.Up => VirtualKey.Up,
    KeyCode.Right => VirtualKey.Right,
    KeyCode.Down => VirtualKey.Down,

    KeyCode.PageUp => VirtualKey.PageUp,
    KeyCode.PageDown => VirtualKey.PageDown,
    KeyCode.Home => VirtualKey.Home,
    KeyCode.End => VirtualKey.End,

    KeyCode.Return => VirtualKey.Return,
    KeyCode.Escape => VirtualKey.Escape,
    KeyCode.Space => VirtualKey.Space,
    KeyCode.Tab => VirtualKey.Tab,
    KeyCode.Backspace => VirtualKey.Backspace,

    KeyCode.Pause => VirtualKey.Pause,

    KeyCode.Alt => VirtualKey.Alt,
    KeyCode.Control => VirtualKey.Control,
    KeyCode.Shift => VirtualKey.Shift,
  ];

  function onKeyDown(key:KeyCode):Void {
    var vk = KeyCodeToVirtualKey[key];
    if (vk != null) {
      inputStatus.isDown[vk] = true;
    }
  }

  function onKeyUp(key:KeyCode):Void {
    var vk = KeyCodeToVirtualKey[key];
    if (vk != null) {
      inputStatus.isDown.remove(vk);
    }
  }

  // Mouse

  var MouseButtonToVirtualKey:Map<Int, VirtualKey> = [
    0 => VirtualKey.MouseLeftButton,
    1 => VirtualKey.MouseRightButton,
    2 => VirtualKey.MouseMiddleButton,
  ];

  function onMouseDown(button:Int, x:Int, y:Int):Void {
    var vk = MouseButtonToVirtualKey[button];
    if (vk != null) {
      inputStatus.isDown[vk] = true;
    }
    inputStatus.x = x;
    inputStatus.y = y;
  }

  function onMouseUp(button:Int, x:Int, y:Int):Void {
    var vk = MouseButtonToVirtualKey[button];
    if (vk != null) {
      inputStatus.isDown.remove(vk);
    }
    inputStatus.x = x;
    inputStatus.y = y;
  }

  function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
    inputStatus.x = x;
    inputStatus.y = y;
    inputStatus.movementX = movementX;
    inputStatus.movementY = movementY;
  }

  function onMouseWheel(delta:Int):Void {
    inputStatus.delta = delta;
  }
}
