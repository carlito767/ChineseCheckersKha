import kha.input.Keyboard as KhaKeyboard;
import kha.input.KeyCode;
import kha.input.Mouse as KhaMouse;

import VirtualKey;

class Input {
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
  // Virtual Keys
  //

  public static function isPressed(vk:VirtualKey):Bool {
    return (pressed[vk] == true);
  }

  static var pressed:Map<VirtualKey, Bool> = new Map();

  //
  // Keyboard
  //

  // @Incomplete
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
    KeyCode.Alt => VirtualKey.Alt,
    KeyCode.Control => VirtualKey.Control,
    KeyCode.Shift => VirtualKey.Shift,
  ];

  static function onKeyDown(key:KeyCode) {
    var vk = KeyCodeToVirtualKey.get(key);
    if (vk != null) {
      pressed[vk] = true;
    }
  }

  static function onKeyUp(key:KeyCode) {
    var vk = KeyCodeToVirtualKey.get(key);
    if (vk != null) {
      pressed[vk] = false;
    }
  }

  //
  // Mouse
  //

  static public var mouseX(default, null):Float = 0.0;
  static public var mouseY(default, null):Float = 0.0;

  static function virtualKeyfromMouseButton(button:Int):Null<VirtualKey> {
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
    var vk = virtualKeyfromMouseButton(button);
    if (vk != null) {
      pressed[vk] = true;
    }
  }

  static function onMouseUp(button:Int, x:Int, y:Int) {
    mouseX = x;
    mouseY = y;
    var vk = virtualKeyfromMouseButton(button);
    if (vk != null) {
      pressed[vk] = false;
    }
  }
}
