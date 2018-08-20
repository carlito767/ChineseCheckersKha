package gato.input;

class Controller {
  var down:Map<VirtualKey, Bool>;

  public function new() {
    down = new Map();
  }

  public function isDown(vk:VirtualKey):Bool {
    return (down[vk] == true);
  }

  //
  // Internal
  //

  function onPressed(vk:Null<VirtualKey>):Void {
    if (vk != null) {
      down[vk] = true;
    }
  }

  function onReleased(vk:Null<VirtualKey>):Void {
    if (vk != null) {
      down[vk] = false;
    }
  }
}
