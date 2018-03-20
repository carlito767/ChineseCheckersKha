package;

import kha.Framebuffer;

import system.Mouse;
import ui.Mui;

class Game {
  static public inline var TITLE:String = 'ChineseCheckersKha';
  static public inline var WIDTH:Int = 800;
  static public inline var HEIGHT:Int = 600;

  var layers:Array<String> = [];
  var mouse:Mouse = new Mouse();
  var ui:Mui = new Mui();

  public function new() {
    layers.push('test');
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

    for (layer in layers) {
      switch layer {
        case 'test':
          graphics.color = 0xffff0000;
          graphics.fillRect(0, 0, WIDTH/2, HEIGHT/2);
          var eval = ui.evaluate({x:0.0, y:0.0, w:WIDTH/2, h:HEIGHT/2});
          if (eval.hit) layers.push('test2');
        case 'test2':
          graphics.color = 0xff00ff00;
          graphics.fillRect(WIDTH/2, HEIGHT/2, WIDTH/2, HEIGHT/2);
      }
    }

    ui.end();
    graphics.end();
  }
}
