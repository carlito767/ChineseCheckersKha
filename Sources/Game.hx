package;

import kha.Framebuffer;

import system.Mouse;

class Game {
  static public inline var TITLE:String = 'ChineseCheckersKha';
  static public inline var WIDTH:Int = 800;
  static public inline var HEIGHT:Int = 600;

  static var mouse:Null<Mouse> = null;

  static public function init() {
    mouse = new Mouse();
  }

  static public function update() {
  }

  static public function render(framebuffer:Framebuffer) {
    var x = mouse.x;
    var y = mouse.y;
    var select = mouse.leftClick;
    trace('x:$x, y:$y, select:$select');
  }
}
