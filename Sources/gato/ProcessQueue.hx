package gato;

class ProcessQueue {
  var processQueue:Array<Process> = new Array();

  public function new() {
  }

  public function add(process:Process) {
    processQueue.push(process);
  }

  public function update(dt:Float) {
    if (processQueue.length == 0) {
      return;
    }

    var process = processQueue[0];
    process.update(dt);
    if (process.finished) {
      processQueue.shift();
    }
  }
}
