package gato.input;

class Keymap {
  var mapping:Map<VirtualKey, Process> = new Map();

  public function new() {
  }

  public function set(vk:VirtualKey, process:Process):Void {
    mapping.set(vk, process);
  }

  public function remove(vk:VirtualKey):Void {
    mapping.remove(vk);
  }

  public function updateProcessQueue(inputStatus:InputStatus, processQueue:ProcessQueue):Void {
    for (vk in mapping.keys()) {
      // TODO:[carlito 20180826] allow to repeat process
      if (inputStatus.isDown[vk] == true && inputStatus.wasDown[vk] != true) {
        var process = mapping[vk];
        process.finished = false;
        processQueue.add(process);
      }
    }
  }
}
