package gato.input;

import kha.input.Keyboard as KhaKeyboard;
import kha.input.KeyCode;

class Keyboard implements Controller {
  public var isDown(default, null):Map<KeyCode, Bool>;

  var keyboard:Null<KhaKeyboard>;

  public function new() {
    reset();
    keyboard = KhaKeyboard.get();
    if (keyboard != null) {
      keyboard.notify(onKeyDown, onKeyUp, null);
    }
  }

  public function reset():Void {
    isDown = new Map();
  }

  public function dispose():Void {
    if (keyboard != null) {
      keyboard.remove(onKeyDown, onKeyUp, null);
      keyboard = null;
      reset();
    }
  }

  //
  // Update Input
  //

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

  public function updateInput(input:Input):Void {
    for (key in isDown.keys()) {
      var vk = KeyCodeToVirtualKey.get(key);
      if (vk != null) {
        input.isDown[vk] = true;
      }
    }
  }

  //
  // Callbacks
  //

  function onKeyDown(key:KeyCode):Void {
    isDown[key] = true;
  }

  function onKeyUp(key:KeyCode):Void {
    isDown.remove(key);
  }
}
