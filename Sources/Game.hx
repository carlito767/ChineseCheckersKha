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

import types.State;

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  public static var g2(default, null):Graphics2 = null;
  public static var g4(default, null):Graphics4 = null;

  public static var scene:Scene;

  public static var sceneTitle:SceneTitle;
  public static var scenePlay:ScenePlay;

  static var keymap:Keymap;

  static var ui:UI;

  public static var state:State;

  @:allow(Main)
  static function initialize() {
    // Settings
    Settings.load();
    Translations.language = Settings.language;

    Input.initialize();

    ui = new UI();

    keymap = new Keymap();
    keymap.set(VirtualKey.L, Action('ChangeLanguage'));
    keymap.set(VirtualKey.Decimal, Action('ToggleHitbox'));

    sceneTitle = new SceneTitle();
    scenePlay = new ScenePlay();
    scene = sceneTitle;
  }

  @:allow(Main)
  static function update() {
    for (command in keymap.commands()) {
      switch command {
      case Action('ChangeLanguage'):
        Commands.changeLanguage();
      case Action('ToggleHitbox'):
        Commands.toggleHitbox();
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
}
