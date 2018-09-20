package gato.input;

import kha.input.KeyCode;

import gato.input.Keyboard;
import gato.input.Mouse;

class Keymap {
  var mapping:Map<VirtualKey, Process> = new Map();
  var isDown:Map<VirtualKey, Bool> = new Map();
  var wasDown:Map<VirtualKey, Bool> = new Map();

  public function new() {
  }

  public function set(vk:VirtualKey, process:Process):Void {
    mapping.set(vk, process);
  }

  public function remove(vk:VirtualKey):Void {
    mapping.remove(vk);
  }

  public function update(processQueue:ProcessQueue):Void {
    for (vk in mapping.keys()) {
      // TODO:[carlito 20180826] allow to repeat process
      if (isDown[vk] == true && wasDown[vk] != true) {
        var process = mapping[vk];
        process.finished = false;
        processQueue.add(process);
      }
    }
    wasDown = isDown;
    isDown = new Map();
  }

  //
  // Keyboard
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

  public function updateFromKeyboard(keyboard:Keyboard):Void {
    for (key in keyboard.isDown.keys()) {
      if (keyboard.isDown[key]) {
        var vk = KeyCodeToVirtualKey.get(key);
        if (vk != null) {
          isDown[vk] = true;
        }
      }
    }
  }

  //
  // Mouse
  //

  function mouseButtonToVirtualKey(button:Int):Null<VirtualKey> {
    return switch button {
      case 0: VirtualKey.MouseLeftButton;
      case 1: VirtualKey.MouseRightButton;
      case 2: VirtualKey.MouseMiddleButton;
      default: null;
    }
  }

  public function updateFromMouse(mouse:Mouse):Void {
    for (button in mouse.buttons.keys()) {
      if (mouse.buttons[button]) {
        var vk = mouseButtonToVirtualKey(button);
        if (vk != null) {
          isDown[vk] = true;
        }
      }
    }
  }
}
