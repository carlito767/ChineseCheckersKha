import kha.Assets;
import kha.Framebuffer;

import Board;
import Board.ChineseCheckers;
import Board.RawMode;
import Board.State;
import Mouse;
import Translations.language;
import Translations.tr;
import UI;
import UI.Dimensions;

class Game {
  static public inline var TITLE:String = 'ChineseCheckersKha';
  static public inline var WIDTH:Int = 800;
  static public inline var HEIGHT:Int = 600;

  var mouse:Mouse = new Mouse();
  var ui:UI = new UI();

  var screen(default, set):String;
  function set_screen(id) {
    screenState = '';
    return screen = id;
  }
  var screenState:String;

  var modeIndex(default, set):Null<Int>;
  function set_modeIndex(value) {
    state = Board.create(value);
    return modeIndex = value;
  }
  var state:Null<State>;

  public function new() {
    language = 'en';
    screen = 'title';
    modeIndex = null;
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

    switch screen {
    case 'play':
      ui.image({ image:Assets.images.BackgroundPlay, x:0, y:0, w:0, h:0 });
      ui.board({ state:state, x:0, y:0, w:WIDTH, h:HEIGHT });
      if (ui.button({ text:tr('quit'), x:680, y:20, w:100, h:40 }).hit) {
        modeIndex = null;
        screen = 'title';
      }

      switch screenState {
      case '':
        var window:UIWindow = { x:250, y:200, w:300, h:200 };
        var dimensions:Dimensions = UI.dimensions(window);
        ui.window(window);

        ui.label({ text:tr('numberOfPlayers'), x:dimensions.left, y:dimensions.top, w:dimensions.width, h:40 });

        for (i in 0...ChineseCheckers.modes.length) {
          var mode:RawMode = ChineseCheckers.modes[i];
          if (ui.button({
            text:Std.string(mode.id),
            x:dimensions.left + (i * 60),
            y:dimensions.top + 50,
            w:40,
            h:40,
            selected:(modeIndex == i),
          }).hit) {
            modeIndex = i;
          }
        }

        if (ui.button({ text:tr('play'), disabled:(modeIndex == null), x:dimensions.left, y:dimensions.bottom - 40, w:dimensions.width, h:40 }).hit) {
          screenState = 'play';
        }
      case 'play':
        state.ready = true;
      }
    case 'title':
      ui.image({ image:Assets.images.BackgroundTitle, x:0, y:0, w:0, h:0 });

      ui.label({ text:tr('title1'), x:350, y:50, w:0, h:0, title:true });
      ui.label({ text:tr('title2'), x:380, y:170, w:0, h:0, title:true });

      if (ui.button({ text:tr('newGame'), x:WIDTH - 300, y:350, w:300, h:50 }).hit) {
        screen = 'play';
      }
      if (ui.button({ text:'${tr('language')} ${language.toUpperCase()}', x:WIDTH - 300, y:420, w:300, h:50 }).hit) {
        language = (language == 'en') ? 'fr' : 'en';
      }
    }

    ui.end();
    graphics.end();
  }
}
