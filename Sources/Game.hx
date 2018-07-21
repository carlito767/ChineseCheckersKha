import kha.Assets;
import kha.Framebuffer;
import kha.graphics2.Graphics as Graphics2;
import kha.graphics4.Graphics as Graphics4;

import gato.Input;
import gato.Keymapper;
import gato.Keymapper.Command;
import gato.Keymapper.Keymap;
import gato.Scaling;
import gato.Storage;
import gato.VirtualKey;

import Board.Move;
import Board.State;
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

    Keymapper.keymaps[''] = [
      VirtualKey.L => Action('ChangeLanguage'),
      VirtualKey.Decimal => Action('ShowHitbox'),
    ];

    sceneTitle = new SceneTitle();
    scenePlay = new ScenePlay();
    scene = sceneTitle;
  }

  @:allow(Main)
  static function update() {
    Keymapper.update();

    for (command in Keymapper.commands.keys()) {
      switch command {
      case Action('ChangeLanguage'):
        Game.changeLanguage();
      case Action('ShowHitbox'):
        UI.showHitbox = !UI.showHitbox;
      case Action('ShowTileId'):
        Settings.showTileId = !Settings.showTileId;
      case Action('QuickLoad1'):
        Game.quickLoad(1);
      case Action('QuickLoad2'):
        Game.quickLoad(2);
      case Action('QuickLoad3'):
        Game.quickLoad(3);
      case Action('QuickSave1'):
        Game.quickSave(1);
      case Action('QuickSave2'):
        Game.quickSave(2);
      case Action('QuickSave3'):
        Game.quickSave(3);
      default:
        trace('Unknown command: $command');
      }
    }

    Sequencer.update();
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
