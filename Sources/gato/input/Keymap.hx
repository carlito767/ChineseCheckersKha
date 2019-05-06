package gato.input;

class Keymap {
  var mapping:Map<VirtualKey, Process> = new Map();
  var isDown:Map<VirtualKey, Bool> = new Map();
  var wasDown:Map<VirtualKey, Bool> = new Map();

  public function new() {
  }

  public function set(vk:VirtualKey, process:Process):Void {
    mapping.set(vk, process);
  }

  public function remove(vk:VirtualKey):Void {
    mapping.remove(vk);
  }

  public function update(inputStatus:InputStatus):Void {
    for (vk in inputStatus.isDown.keys()) {
      isDown[vk] = true;
    }
  }

  public function updateProcessQueue(processQueue:ProcessQueue):Void {
    for (vk in mapping.keys()) {
      // TODO:[carlito 20180826] allow to repeat process
      if (isDown[vk] == true && wasDown[vk] != true) {
        var process = mapping[vk];
        process.finished = false;
        processQueue.add(process);
      }
    }
    wasDown = isDown;
    isDown = new Map();
  }
}
