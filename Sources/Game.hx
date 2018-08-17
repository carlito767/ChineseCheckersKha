import kha.Assets;
import kha.Framebuffer;
import kha.graphics2.Graphics as Graphics2;
import kha.graphics4.Graphics as Graphics4;

import gato.Scaling;
import gato.Storage;
import gato.input.Input;

import types.Settings;
import types.State;

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  public static inline var SETTINGS_FILENAME = 'settings';
  public static inline var SETTINGS_FILENAME_JSON = 'settings.json';
  public static inline var SETTINGS_FILENAME_LOCAL_JSON = 'settings.local.json';
  public static inline var SETTINGS_VERSION = 1;

  public static var g2(default, null):Graphics2 = null;
  public static var g4(default, null):Graphics4 = null;

  public static var settings:Storage<Settings>;

  public static var scene:Scene;

  public static var sceneTitle:SceneTitle;
  public static var scenePlay:ScenePlay;

  static var ui:UI;

  public static var state:State;

  @:allow(Main)
  static function initialize() {
    settings = new Storage<Settings>();
    settings.model = {
      version:SETTINGS_VERSION,
      language:'en',
      showTileId:false,
    };
    // @@Improvement: validate settings.json at compile time
    settings.loadJson(SETTINGS_FILENAME_JSON, SETTINGS_VERSION);
    if (!settings.mergeJson(SETTINGS_FILENAME_LOCAL_JSON)) {
      settings.load(SETTINGS_FILENAME, SETTINGS_VERSION);
    }
    if (settings.data == null) {
      settings.data = settings.model;
    }
    Translations.language = settings.data.language;

    Input.initialize();

    ui = new UI();

    sceneTitle = new SceneTitle();
    scenePlay = new ScenePlay();
    scene = sceneTitle;
  }

  @:allow(Main)
  static function update() {
    scene.update();
  }

  @:allow(Main)
  static function render(framebuffers:Array<Framebuffer>) {
    g2 = framebuffers[0].g2;
    g4 = framebuffers[0].g4;

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
