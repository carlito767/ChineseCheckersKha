package gato.input;

class Keymap {
  var mapping:Map<VirtualKey, Command>;
  var down:Map<VirtualKey, Bool>;

  public function new() {
    mapping = new Map();
    down = new Map();
  }

  public function set(vk:VirtualKey, command:Command):Void {
    mapping.set(vk, command);
  }

  public function remove(vk:VirtualKey):Void {
    mapping.remove(vk);
  }

  public function commands(input:Input):Array<Command> {
    var commands = new Array<Command>();
    for (vk in mapping.keys()) {
      var isDown = input.isDown(vk);
      if (isDown) {
        var command = mapping[vk];
        var active:Bool = switch command {
        case Action(id):
          down[vk] != true;
        case State(id):
          true;
        }
        if (active) {
          commands.push(command);
        }
      }
      down[vk] = isDown;
    }
    return commands;
  }
}
