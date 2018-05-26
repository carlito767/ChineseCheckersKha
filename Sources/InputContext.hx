// Inspired by: https://www.gamedev.net/blogs/entry/2250186-designing-a-robust-input-handling-system-for-games/

import kha.input.KeyCode;

typedef Action = {
  var key:KeyCode;
  var command:Void->Void;
  @:optional var active:Bool;
}

class InputContext {
  var actions:Map<KeyCode, Action>;

  public function new() {
    actions = new Map();
  }

  public function map(key:KeyCode, command:Void->Void) {
    actions.set(key, {
      key:key,
      command:command,
    });
  }

  public function unmap(key:KeyCode) {
    actions.remove(key);
  }

  public function update() {
    for (action in actions) {
      var active = check(action);
      if (active && action.active != true) {
        action.command();
      }
      action.active = active;
    }
  }

  function check(action:Action):Bool {
    return Input.keyboard.keys[action.key] == true;
  }
}
