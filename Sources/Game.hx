import kha.Assets;
import kha.Framebuffer;

import Board.Move;
import Board.State;
import Translations.language;
import VirtualKey;

typedef Settings = {
  var version:Int;
  var language:String;
}

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  @:allow(Main)
  static function initialize() {
    Input.initialize();
    Sequencer.initialize();

    loadSettings();

    scenes = [
      "title" => new SceneTitle(),
      "play" => new ScenePlay(),
    ];

    scene = 'title';
  }

  @:allow(Main)
  static function update() {
    Sequencer.update();
    var currentScene = scenes[scene];
    if (currentScene != null) {
      currentScene.update();
    }
  }

  @:allow(Main)
  static function render(framebuffer:Framebuffer) {
    var g = framebuffer.g2;
    var x = Input.mouseX;
    var y = Input.mouseY;
    var select = Input.isPressed(VirtualKey.MouseLeftButton);
    g.begin();
    ui.preRender(g, WIDTH, HEIGHT, { x:x, y:y, select:select });
    var currentScene = scenes[scene];
    if (currentScene != null) {
      currentScene.render(ui);
    }
    ui.postRender();
    g.end();
  }

  //
  // Language
  //

  public static function changeLanguage() {
    language = (language == 'en') ? 'fr' : 'en';
    saveSettings();
  }

  //
  // State
  //

  public static var state:State;

  //
  // Scene
  //

  static var scenes:Map<String, IScene>;
  public static var scene(default, set):String;
  static function set_scene(value) {
    if (scene != value) {
      var currentScene = scenes[scene];
      if (currentScene != null) {
        currentScene.leave();
      }
      var newScene = scenes[value];
      if (newScene != null) {
        newScene.enter();
      }
    }
    return scene = value;
  }

  //
  // UI
  //

  static var ui:UI = new UI();

  //
  // Settings
  //

  static inline var SETTINGS_VERSION = 1;

  static function checkSettings(settings:Null<Settings>):Settings {
    var defaults:Settings = { version:SETTINGS_VERSION, language:'en' };

    if (settings == null) {
      return defaults;
    }

    switch settings.version {
    case SETTINGS_VERSION:
    default:
      trace('Settings: unknown version');
      return defaults;
    }

    return settings;
  }

  static function loadSettings() {
    var settings:Settings = checkSettings(Storage.read('settings'));
    language = settings.language;
  }

  static function saveSettings() {
    var settings:Settings = { version:SETTINGS_VERSION, language:language };
    Storage.write('settings', settings);
  }

  //
  // Quick Load/Save
  //

  public static function quickLoad(id:Int) {
    var gamesave:Null<State> = Board.load(Storage.read('gamesave$id'));
    if (gamesave == null) {
      return;
    }

    trace('Quick Load $id');
    state = gamesave;
    scene = 'play';
  }

  public static function quickSave(id:Int) {
    if (Board.isRunning(state)) {
      trace('Quick Save $id');
      Storage.write('gamesave$id', Board.save(state));
    }
  }
}
