package;

import kha.Framebuffer;

import system.Mouse;
import ui.Mui;

class Game {
  static public inline var TITLE:String = 'ChineseCheckersKha';
  static public inline var WIDTH:Int = 800;
  static public inline var HEIGHT:Int = 600;

  var mouse:Mouse = new Mouse();
  var ui:Mui = new Mui();

  public function new() {
  }

  public function update() {
  }

  public function render(framebuffer:Framebuffer) {
    var x = mouse.x * 1.0;
    var y = mouse.y * 1.0;
    var select = mouse.leftClick;

    var graphics = framebuffer.g2;
    graphics.begin();
    ui.begin(x, y, select);

    // Test
    graphics.color = 0xffff0000;
    graphics.fillRect(0, 0, WIDTH/2, HEIGHT/2);
    var eval = ui.evaluate({x:0.0, y:0.0, w:WIDTH/2, h:HEIGHT/2});
    if (eval.longPress) trace('longPress');
    else if (eval.hit) trace('hit');
    else if (eval.active) trace('active');
    else if (eval.hot) trace('hot');

    ui.end();
    graphics.end();
  }
}
