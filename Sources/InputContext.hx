// Inspired by: https://www.gamedev.net/blogs/entry/2250186-designing-a-robust-input-handling-system-for-games/

import VirtualKey;

typedef Command = {
  @:optional var f:Void->Void;
  @:optional var repeat:Bool;
  @:optional var active:Bool;
}

class InputContext {
  var commands:Map<VirtualKey, Command>;

  public function new() {
    commands = new Map();
  }

  public function map(key:VirtualKey, command:Command) {
    commands.set(key, command);
  }

  public function update() {
    for (key in commands.keys()) {
      var command = commands[key];
      var active = Input.isPressed(key);
      if (active && command.f != null && (command.repeat == true || command.active != true)) {
        command.f();
      }
      command.active = active;
    }
  }
}
