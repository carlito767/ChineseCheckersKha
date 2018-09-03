package gato.input;

class Keymap {
  var mapping:Map<VirtualKey, Process>;
  var down:Map<VirtualKey, Bool>;

  public function new() {
    mapping = new Map();
    down = new Map();
  }

  public function set(vk:VirtualKey, process:Process):Void {
    mapping.set(vk, process);
  }

  public function remove(vk:VirtualKey):Void {
    mapping.remove(vk);
  }

  public function update(processQueue:ProcessQueue, input:Input):Void {
    var nextDown:Map<VirtualKey, Bool> = new Map();
    for (vk in mapping.keys()) {
      var process = mapping[vk];
      var isDown = input.isDown(vk);
      // TODO: allow to repeat process
      if (isDown && down[vk] != true) {
        process.finished = false;
        processQueue.add(process);
      }
      nextDown[vk] = isDown;
    }
    down = nextDown;
  }
}
