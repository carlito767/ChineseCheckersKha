import kha.Assets;
import kha.Framebuffer;
import kha.graphics2.Graphics as Graphics2;
import kha.graphics4.Graphics as Graphics4;

import gato.Scaling;
import gato.Storage;
import gato.input.Input;
import gato.input.Keymap;
import gato.input.Keymap.Command;
import gato.input.VirtualKey;

import types.Gamestate;

import Translations.language;

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  public static var g2(default, null):Graphics2 = null;
  public static var g4(default, null):Graphics4 = null;

  public static var scene(default, set):Scene;
  static function set_scene(value) {
    if (scene != value) {
      if (scene != null) {
        scene.leave();
      }
      if (value != null) {
        value.enter();
      }
    }
    return scene = value;
  }

  public static var sceneTitle:SceneTitle;
  public static var scenePlay:ScenePlay;

  static var keymap:Keymap;

  static var ui:UI;

  public static var state:State;

  @:allow(Main)
  static function initialize() {
    // Settings
    Settings.load();
    language = Settings.language;

    Input.initialize();

    ui = new UI();

    keymap = new Keymap();
    keymap.set(VirtualKey.L, Action('ChangeLanguage'));
    keymap.set(VirtualKey.Decimal, Action('ShowHitbox'));

    sceneTitle = new SceneTitle();
    scenePlay = new ScenePlay();
    scene = sceneTitle;
  }

  @:allow(Main)
  static function update() {
    for (command in keymap.commands()) {
      switch command {
      case Action('ChangeLanguage'):
        Game.changeLanguage();
      case Action('ShowHitbox'):
        UI.showHitbox = !UI.showHitbox;
      default:
        trace('Unknown command: $command');
      }
    }

    scene.update();
  }

  @:allow(Main)
  static function render(framebuffer:Framebuffer) {
    g2 = framebuffer.g2;
    g4 = framebuffer.g4;

    Scaling.update(WIDTH, HEIGHT);

    g2.begin();
    g2.scissor(Std.int(Scaling.dx), Std.int(Scaling.dy), Std.int(WIDTH * Scaling.scale), Std.int(HEIGHT * Scaling.scale));

    ui.g = g2;
    ui.begin();
    scene.render(ui);
    ui.end();
  
    g2.disableScissor();
    g2.end();
  }

  //
  // Language
  //

  public static function changeLanguage() {
    language = (language == 'en') ? 'fr' : 'en';
    Settings.language = language;
    Settings.save();
  }

  //
  // Quick Load/Save
  //

  public static function quickLoad(id:Int) {
    var gamesave:Null<State> = Storage.read('gamesave$id');
    if (gamesave == null || gamesave.version != Board.GAMESAVE_VERSION) {
      return;
    }

    trace('Quick Load $id');
    state = gamesave;
    scene = scenePlay;
  }

  public static function quickSave(id:Int) {
    if (Board.isRunning(state)) {
      trace('Quick Save $id');
      Storage.write('gamesave$id', state);
    }
  }
}
