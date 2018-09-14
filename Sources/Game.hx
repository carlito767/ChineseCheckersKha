import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.graphics2.Graphics as Graphics2;
import kha.graphics4.Graphics as Graphics4;

import gato.Process;
import gato.ProcessQueue;
import gato.Scaling;
import gato.Timer;
import gato.input.Input;
import gato.input.Keymap;
import gato.input.VirtualKey;

import Mui.MuiInput;
import ai.*;
import process.*;

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
  public static var sequenceIndex(default, set):Null<Int>;
  static function set_sequenceIndex(value) {
    Game.processQueue.add(new SelectSequenceProcess(value));
    return sequenceIndex = value;
  }

  public static var scene:UIFlow;

  public static var keymap:Keymap;
  public static var input:Input;

  static var ui:UI;

  static var frames:Int;
  static var fps:Int;

  @:allow(Main)
  static function initialize():Void {
    processQueue = new ProcessQueue();

    settings = new Settings();
    settings.load();

    locale = new Localization();
    locale.load(settings.language);

    gamesave = new Gamesave();
    sequenceIndex = null;

    scene = Scenes.title;

    // TODO:[carlito 20180826] load keymap at compile time using macro and json
    // TODO:[carlito 20180905] allow developer actions only in debug mode
    keymap = new Keymap();
    keymap.set(VirtualKey.D, new ToggleDebugOverlayProcess());
    keymap.set(VirtualKey.L, new ChangeLanguageProcess());
    keymap.set(VirtualKey.S, new SearchMoveProcess(new MinimaxAI()));
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
    UI.showHitbox = settings.showHitbox;

    frames = 0;
    fps = 0;

    timer = new Timer();
  }

  @:allow(Main)
  static function update() {
    timer.update();
    keymap.update(processQueue, input);
    processQueue.update(timer.deltaTime);
  }

  @:allow(Main)
  static function render(framebuffers:Array<Framebuffer>):Void {
    // FPS
    if (timer.elapsedTime >= 1.0) {
      fps = frames;
      frames = 0;
      timer.reset();
    }
    frames++;

    g2 = framebuffers[0].g2;
    g4 = framebuffers[0].g4;

    Scaling.update(WIDTH, HEIGHT);

    g2.begin();
    g2.scissor(Std.int(Scaling.dx), Std.int(Scaling.dy), Std.int(WIDTH * Scaling.scale), Std.int(HEIGHT * Scaling.scale));

    ui.begin({
      x:input.mouse.x,
      y:input.mouse.y,
      select:input.isDown(VirtualKey.MouseLeftButton),
    });
    ui.render(g2, scene);
    ui.end();

    g2.disableScissor();

    // Debug Overlay
    if (settings.showDebugOverlay) {
      g2.color = Color.White;
      g2.font = Assets.fonts.PaytoneOne;
      g2.fontSize = 25;
      g2.drawString('FPS: $fps', 10, 10);
      g2.drawString('Mouse:', 10, 30);
      g2.drawString('x: ${input.mouse.x}, y: ${input.mouse.y}', 15, 50);
      g2.drawString('movementX: ${input.mouse.movementX}, movementY: ${input.mouse.movementY}', 15, 70);
      g2.drawString('delta: ${input.mouse.delta}', 15, 90);
    }

    g2.end();
  }
}
