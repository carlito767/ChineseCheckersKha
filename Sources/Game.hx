import kha.Assets;
import kha.Framebuffer;

import Board.Move;
import Board.State;
import Translations.language;

typedef Keymap = Map<VirtualKey, String>; 

typedef Settings = {
  var version:Int;
  var language:String;
}

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  public static var keymaps:Map<String, Keymap> = new Map();
  public static var commands:Map<String, Bool> = new Map();

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

  public static var sceneTitle(default, null) = new SceneTitle();
  public static var scenePlay(default, null) = new ScenePlay();

  @:allow(Main)
  static function initialize() {
    var keymap = new Keymap();
    keymap[VirtualKey.L] = 'ChangeLanguage';
    keymap[VirtualKey.Decimal] = 'ShowHitbox';
    keymaps[''] = keymap;

    Input.initialize();
    Sequencer.initialize();

    loadSettings();

    scene = sceneTitle;
  }

  @:allow(Main)
  static function update() {
    var currentCommands:Map<String, Bool> = new Map();
    for (keymap in keymaps) {
      for (vk in keymap.keys()) {
        if (Input.isPressed(vk)) {
          var id = keymap[vk];
          var repeat = commands.exists(id);
          currentCommands[id] = repeat; 
        }
      }
    }
    commands = currentCommands;

    for (id in commands.keys()) {
      var repeat = commands[id];
      switch id {
      case 'ChangeLanguage':
        if (!repeat) {
          Game.changeLanguage();
        }
      case 'ShowHitbox':
        if (!repeat) {
          UI.showHitbox = !UI.showHitbox;
        }
      case 'ShowTileId':
        if (!repeat) {
          showTileId = !showTileId;
        }
      case 'QuickLoad1':
        if (!repeat) {
          Game.quickLoad(1);
        }
      case 'QuickLoad2':
        if (!repeat) {
          Game.quickLoad(2);
        }
      case 'QuickLoad3':
        if (!repeat) {
          Game.quickLoad(3);
        }
      case 'QuickSave1':
        if (!repeat) {
          Game.quickSave(1);
        }
      case 'QuickSave2':
        if (!repeat) {
          Game.quickSave(2);
        }
      case 'QuickSave3':
        if (!repeat) {
          Game.quickSave(3);
        }
      default:
        trace('Unknown command: $id');
      }
    }

    Sequencer.update();
    scene.update();
  }

  @:allow(Main)
  static function render(framebuffer:Framebuffer) {
    var g = framebuffer.g2;
    var x = Input.mouseX;
    var y = Input.mouseY;
    var select = Input.isPressed(VirtualKey.MouseLeftButton);
    g.begin();
    ui.preRender(g, WIDTH, HEIGHT, { x:x, y:y, select:select });
    scene.render(ui);
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

  public static function quickLoad(id:Int) {
    var gamesave:Null<State> = Board.load(Storage.read('gamesave$id'));
    if (gamesave == null) {
      return;
    }

    trace('Quick Load $id');
    state = gamesave;
    scene = scenePlay;
  }

  public static function quickSave(id:Int) {
    if (Board.isRunning(state)) {
      trace('Quick Save $id');
      Storage.write('gamesave$id', Board.save(state));
    }
  }
}
