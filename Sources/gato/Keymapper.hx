package gato;

import gato.VirtualKey;

enum Command {
  Action(id:String);
  State(id:String);
}

typedef Keymap = Map<VirtualKey, Command>;

class Keymapper {
  public static var keymaps:Map<String, Keymap> = new Map();
  public static var commands:Map<Command, Bool> = new Map();

  static var pressed:Map<VirtualKey, Bool> = new Map();

  public static function update() {
    commands = new Map();
    for (keymap in Keymapper.keymaps) {
      for (vk in keymap.keys()) {
        var isPressed = Input.isPressed(vk);
        if (isPressed) {
          var command = keymap[vk];
          var active:Bool = switch command {
          case Action(id):
            pressed[vk] != true;
          case State(id):
            true;
          }
          if (active) {
            commands[command] = true;
          }
        }
        pressed[vk] = isPressed;
      }
    }
  }
}
