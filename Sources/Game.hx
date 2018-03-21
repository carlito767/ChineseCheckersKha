package;

import kha.Assets;
import kha.Framebuffer;

import Translations.language;
import Translations.tr;
import system.Mouse;
import ui.UI;

class Game {
  static public inline var TITLE:String = 'ChineseCheckersKha';
  static public inline var WIDTH:Int = 800;
  static public inline var HEIGHT:Int = 600;

  var mouse:Mouse = new Mouse();
  var ui:UI = new UI();
  var screen:Array<String> = [];

  public function new() {
    language = 'en';
    screen.push('title');
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
    ui.graphics = graphics;

    for (layer in screen) {
      switch layer {
        case 'title':
          ui.image({ x:0, y:0, w:0, h:0, image:Assets.images.background_title });
          ui.label({ x:350, y:50, w:0, h:0, text:tr('title1'), title:true });
          ui.label({ x:380, y:170, w:0, h:0, text:tr('title2'), title:true });
          var eval = ui.label({ x:10, y:10, w:30, h:30, text:language });
          if (eval.hit) {
            language = (language == 'en') ? 'fr' : 'en';
          }
      }
    }

    ui.end();
    graphics.end();
  }
}
