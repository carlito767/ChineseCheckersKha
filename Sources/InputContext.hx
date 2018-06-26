// Inspired by: https://www.gamedev.net/blogs/entry/2250186-designing-a-robust-input-handling-system-for-games/

typedef Command = {
  var f:Void->Void;
  var repeat:Bool;
  var active:Bool;
}

typedef Context = Map<VirtualKey, String>;

class InputContext {
  static var commands:Map<String, Command> = new Map();

  public static function isActive(id:String):Bool {
    return (commands[id] != null) ?  commands[id].active : false;
  }

  public static function map(id:String, f:Void->Void, ?repeat:Bool = false) {
    commands.set(id, { f:f, repeat:repeat, active:false });
  }

  public static function update(context:Context) {
    for (vk in context.keys()) {
      var id = context[vk];
      var command = commands[id];
      if (command == null) {
        continue;
      }
      var active = Input.isPressed(vk);
      if (active && (command.repeat || !command.active)) {
        command.f();
      }
      command.active = active;
    }
  }
}
