package input;

class Keymap {
  var mapping:Map<VirtualKey, String> = new Map();

  public function new() {
  }

  public function set(vk:VirtualKey, action:String):Void {
    mapping.set(vk, action);
  }

  public function remove(vk:VirtualKey):Void {
    mapping.remove(vk);
  }

  public function update(inputStatus:InputStatus):Array<String> {
    var actions:Array<String> = [];
    for (vk in mapping.keys()) {
      // TODO:[carlito 20180826] allow to repeat process
      if (inputStatus.isDown[vk] == true && inputStatus.wasDown[vk] != true) {
        actions.push(mapping[vk]);
      }
    }
    return actions;
  }
}
