package gato.input;

import gato.input.VirtualKey;

enum Command {
  Action(id:String);
  State(id:String);
}

class Keymap {
  var mapping:Map<VirtualKey, Command>;
  var pressed:Map<VirtualKey, Bool>;

  public function new() {
    mapping = new Map();
    pressed = new Map();
  }

  public function set(vk:VirtualKey, command:Command) {
    mapping.set(vk, command);
  }

  public function remove(vk:VirtualKey) {
    mapping.remove(vk);
  }

  public function commands():Array<Command> {
    var commands = new Array<Command>();
    for (vk in mapping.keys()) {
      var isPressed = Input.isPressed(vk);
      if (isPressed) {
        var command = mapping[vk];
        var active:Bool = switch command {
        case Action(id):
          pressed[vk] != true;
        case State(id):
          true;
        }
        if (active) {
          commands.push(command);
        }
      }
      pressed[vk] = isPressed;
    }
    return commands;
  }
}
