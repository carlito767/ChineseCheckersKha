import kha.Assets;
import kha.Framebuffer;
import kha.input.KeyCode;

import Board.Move;
import Board.State;
import Translations.language;

typedef Settings = {
  var version:Int;
  var language:String;
}

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  static var inputContext:InputContext = new InputContext();

  @:allow(Main)
  static function initialize() {
    Input.initialize();
    Sequencer.initialize();

    loadSettings();

    inputContext.map(KeyCode.L, changeLanguage);
    inputContext.map(KeyCode.Decimal, function() { UI.showHitbox = !UI.showHitbox; });
    inputContext.map(KeyCode.Numpad0, function() { showTileId = !showTileId; });
    inputContext.map(KeyCode.Numpad1, function() { quickLoad(1); });
    inputContext.map(KeyCode.Numpad2, function() { quickLoad(2); });
    inputContext.map(KeyCode.Numpad3, function() { quickLoad(3); });
    inputContext.map(KeyCode.Numpad7, function() { quickSave(1); });
    inputContext.map(KeyCode.Numpad8, function() { quickSave(2); });
    inputContext.map(KeyCode.Numpad9, function() { quickSave(3); });

    scenes = [
      "title" => new SceneTitle(),
      "play" => new ScenePlay(),
    ];

    scene = 'title';
  }

  @:allow(Main)
  static function update() {
    inputContext.update();
    Sequencer.update();
    var currentScene = scenes[scene];
    if (currentScene != null) {
      currentScene.update();
    }
  }

  @:allow(Main)
  static function render(framebuffer:Framebuffer) {
    var g = framebuffer.g2;
    var x = Input.mouse.x;
    var y = Input.mouse.y;
    var select = (Input.mouse.buttons[0] == true);
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

  public static var showTileId:Bool = false;

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

  static function quickLoad(id:Int) {
    var gamesave:Null<State> = Board.load(Storage.read('gamesave$id'));
    if (gamesave == null) {
      return;
    }

    trace('Quick Load $id');
    state = gamesave;
    scene = 'play';
  }

  static function quickSave(id:Int) {
    if (Board.isRunning(state)) {
      trace('Quick Save $id');
      Storage.write('gamesave$id', Board.save(state));
    }
  }
}
