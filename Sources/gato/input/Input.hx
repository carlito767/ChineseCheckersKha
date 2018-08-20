package gato.input;

class Input {
  public var keyboard(default, null):Keyboard;
  public var mouse(default, null):Mouse;

  public function new() {
    keyboard = new Keyboard();
    mouse = new Mouse();
  }

  public function start() {
    keyboard.start();
    mouse.start();
  }

  public function stop() {
    keyboard.stop();
    mouse.stop();
  }

  public function isDown(vk:VirtualKey):Bool {
    return (keyboard.isDown(vk) || mouse.isDown(vk));
  }
}
