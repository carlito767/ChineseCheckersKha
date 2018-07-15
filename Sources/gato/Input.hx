package gato;

import kha.input.Keyboard as KhaKeyboard;
import kha.input.KeyCode;
import kha.input.Mouse as KhaMouse;

import gato.VirtualKey;

class Input {
  static var pressed:Map<VirtualKey, Bool> = new Map();

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

  public static function isPressed(vk:VirtualKey):Bool {
    return (pressed[vk] == true);
  }

  static inline function onPressed(vk:Null<VirtualKey>) {
    if (vk != null) {
      pressed[vk] = true;
    }
  }

  static inline function onReleased(vk:Null<VirtualKey>) {
    if (vk != null) {
      pressed[vk] = false;
    }
  }

  //
  // Keyboard
  //

  static var KeyCodeToVirtualKey:Map<KeyCode, VirtualKey> = [
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

  static function onKeyDown(key:KeyCode) {
    onPressed(KeyCodeToVirtualKey.get(key));
  }

  static function onKeyUp(key:KeyCode) {
    onReleased(KeyCodeToVirtualKey.get(key));
  }

  //
  // Mouse
  //

  static public var mouseX(default, null):Float = 0.0;
  static public var mouseY(default, null):Float = 0.0;

  static function mouseButtonToVirtualKey(button:Int):Null<VirtualKey> {
    return switch button {
      case 0: VirtualKey.MouseLeftButton;
      case 1: VirtualKey.MouseRightButton;
      case 2: VirtualKey.MouseMiddleButton;
      default: null;
    }
  }

  static function onMouseDown(button:Int, x:Int, y:Int) {
    mouseX = x;
    mouseY = y;
    onPressed(mouseButtonToVirtualKey(button));
  }

  static function onMouseUp(button:Int, x:Int, y:Int) {
    mouseX = x;
    mouseY = y;
    onReleased(mouseButtonToVirtualKey(button));
  }
}
