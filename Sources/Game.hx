import kha.Assets;
import kha.Framebuffer;

import Board.Move;
import Board.State;
import Translations.language;

typedef Keymap = Map<VirtualKey, String>;

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  public static var keymaps:Map<String, Keymap>;
  public static var commands:Map<String, Bool>;

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

  static var ui:UI;

  public static var state:State;

  @:allow(Main)
  static function initialize() {
    // Settings
    Settings.load();
    language = Settings.language;

    Input.initialize();
    Sequencer.initialize();

    ui = new UI();

    keymaps = new Map();
    commands = new Map();
    var keymap = new Keymap();
    keymap[VirtualKey.L] = 'ChangeLanguage';
    keymap[VirtualKey.Decimal] = 'ShowHitbox';
    keymaps[''] = keymap;

    sceneTitle = new SceneTitle();
    scenePlay = new ScenePlay();
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
          Settings.showTileId = !Settings.showTileId;
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
    g.begin();
    ui.preRender(g, WIDTH, HEIGHT);
    scene.render(ui);
    ui.postRender();
    g.end();
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
