import kha.Assets;
import kha.Framebuffer;
import kha.graphics2.Graphics as Graphics2;
import kha.graphics4.Graphics as Graphics4;

import gato.Process;
import gato.ProcessQueue;
import gato.Timer;
import gato.Scaling;
import gato.input.Input;
import gato.input.Keymap;
import gato.input.VirtualKey;

import process.*;

import Mui.MuiInput;

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  public static var g2(default, null):Graphics2 = null;
  public static var g4(default, null):Graphics4 = null;

  public static var timer:Timer;
  public static var processQueue:ProcessQueue;

  public static var settings:Settings;

  public static var locale:Localization;

  public static var gamesave:Gamesave;

  public static var scene:Scene;
  public static var sceneTitle:SceneTitle;
  public static var scenePlay:ScenePlay;

  public static var keymap:Keymap;
  public static var input:Input;

  static var ui:UI;

  @:allow(Main)
  static function initialize():Void {
    processQueue = new ProcessQueue();

    settings = new Settings();
    settings.load();

    locale = new Localization();
    locale.load(settings.language);

    gamesave = new Gamesave();

    sceneTitle = new SceneTitle();
    scenePlay = new ScenePlay();
    scene = sceneTitle;

    // @@TODO: load keymap at compile time using macro and json
    keymap = new Keymap();
    keymap.set(VirtualKey.L, new ChangeLanguageProcess());
    keymap.set(VirtualKey.Decimal, new ToggleHitboxProcess());
    keymap.set(VirtualKey.Number0, new ToggleTileIdProcess());
    keymap.set(VirtualKey.Number1, new QuickLoadProcess(1));
    keymap.set(VirtualKey.Number2, new QuickLoadProcess(2));
    keymap.set(VirtualKey.Number3, new QuickLoadProcess(3));
    keymap.set(VirtualKey.Number7, new QuickSaveProcess(1));
    keymap.set(VirtualKey.Number8, new QuickSaveProcess(2));
    keymap.set(VirtualKey.Number9, new QuickSaveProcess(3));
    keymap.set(VirtualKey.Backspace, new UndoProcess());

    input = new Input();
    input.start();

    ui = new UI();

    timer = new Timer();
  }

  @:allow(Main)
  static function update() {
    var dt = timer.update();
    keymap.update(processQueue, input);
    processQueue.update(dt);
    scene.update();
  }

  @:allow(Main)
  static function render(framebuffers:Array<Framebuffer>):Void {
    g2 = framebuffers[0].g2;
    g4 = framebuffers[0].g4;

    Scaling.update(WIDTH, HEIGHT);

    g2.begin();
    g2.scissor(Std.int(Scaling.dx), Std.int(Scaling.dy), Std.int(WIDTH * Scaling.scale), Std.int(HEIGHT * Scaling.scale));

    ui.g = g2;
    ui.begin({
      x:input.mouse.x,
      y:input.mouse.y,
      select:input.isDown(VirtualKey.MouseLeftButton),
    });
    scene.render(ui);
    ui.end();
  
    g2.disableScissor();
    g2.end();
  }
}
