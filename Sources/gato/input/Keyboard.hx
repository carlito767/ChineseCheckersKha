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
  // Callbacks
  //

  function onKeyDown(key:KeyCode):Void {
    isDown.set(key, true);
  }

  function onKeyUp(key:KeyCode):Void {
    isDown.remove(key);
  }
}
