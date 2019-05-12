import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.graphics2.Graphics as Graphics2;
import kha.graphics4.Graphics as Graphics4;

import gato.Scaling;
import gato.Timer;
import gato.input.Input;
import gato.input.InputStatus;
import gato.input.Keymap;
import gato.input.VirtualKey;

import BoardChineseCheckers as GameBoard;
import Mui.MuiInput;
import ai.*;
import board.Move;

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  public static var g2(default, null):Graphics2 = null;
  public static var g4(default, null):Graphics4 = null;

  public static var timer:Timer;

  public static var settings:Settings;

  public static var locale:Localization;

  public static var gamesave:Gamesave;
  public static var sequenceIndex(default, set):Null<Int>;
  static function set_sequenceIndex(value) {
    var sequence = (value == null) ? null : GameBoard.sequences[value].copy();
    gamesave = Board.create(GameBoard.tiles, GameBoard.players, sequence);
    return sequenceIndex = value;
  }

  public static var scene:UIFlow;

  public static var input:Input;
  public static var inputStatus:InputStatus;
  public static var keymap:Keymap;

  static var ui:UI;

  static var frames:Int;
  static var fps:Int;

  @:allow(Main)
  static function initialize():Void {
    settings = new Settings();
    settings.load();

    locale = new Localization();
    locale.load(settings.language);

    gamesave = new Gamesave();
    sequenceIndex = null;

    scene = Scenes.title;

    input = new Input();
    input.initialize();
    inputStatus = input.update();

    // TODO:[carlito 20180826] load keymap at compile time using macro and json
    // TODO:[carlito 20180905] allow developer actions only in debug mode
    keymap = new Keymap();
    keymap.set(VirtualKey.D, "ToggleDebugOverlay");
    keymap.set(VirtualKey.L, "ChangeLanguage");
    keymap.set(VirtualKey.S, "SearchMove");
    keymap.set(VirtualKey.Decimal, "ToggleHitbox");
    keymap.set(VirtualKey.Number0, "ToggleTileId");
    keymap.set(VirtualKey.Number1, "QuickLoad1");
    keymap.set(VirtualKey.Number2, "QuickLoad2");
    keymap.set(VirtualKey.Number3, "QuickLoad3");
    keymap.set(VirtualKey.Number7, "QuickSave1");
    keymap.set(VirtualKey.Number8, "QuickSave2");
    keymap.set(VirtualKey.Number9, "QuickSave3");
    keymap.set(VirtualKey.Backspace, "Undo");

    ui = new UI();
    UI.showHitbox = settings.showHitbox;

    frames = 0;
    fps = 0;

    timer = new Timer();
  }

  @:allow(Main)
  static function update() {
    timer.update();

    inputStatus = input.update();
    var actions:Array<String> = keymap.update(inputStatus);
    for (action in actions) {
      handleAction(action);
    }
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
      x:inputStatus.x,
      y:inputStatus.y,
      select:(inputStatus.isDown[VirtualKey.MouseLeftButton] == true && inputStatus.wasDown[VirtualKey.MouseLeftButton] != true),
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
      g2.drawString('x: ${inputStatus.x}, y: ${inputStatus.y}', 15, 50);
      g2.drawString('movementX: ${inputStatus.movementX}, movementY: ${inputStatus.movementY}', 15, 70);
      g2.drawString('delta: ${inputStatus.delta}', 15, 90);

      g2.drawString('current player: ${gamesave.currentPlayerId}', 10, 130);
      g2.drawString('sequence: ${gamesave.sequence.toString()}', 10, 150);
      g2.drawString('standings: ${gamesave.standings.toString()}', 10, 170);
    }

    g2.end();
  }

  @:allow(Scenes)
  static function handleAction(action:String):Void {
    switch action {
    case "ChangeLanguage":
      var newLanguage = (settings.language == 'en') ? 'fr' : 'en';
      if (locale.load(newLanguage)) {
        settings.language = newLanguage;
        settings.save();
      }
    case "QuickLoad1" | "QuickLoad2" | "QuickLoad3":
      var id = Std.parseInt(action.charAt(action.length - 1));
      if (gamesave.load(id)) {
        scene = Scenes.play;
      }
    case "QuickSave1" | "QuickSave2" | "QuickSave3":
      var id = Std.parseInt(action.charAt(action.length - 1));
      if (Board.isRunning(gamesave)) {
        gamesave.save(id);
      }
    case "SearchMove":
      var timer = new Timer();
      var ai = new MinimaxAI();
      var move:Null<Move> = ai.search(Game.gamesave);
      timer.update();
      trace('[in ${timer.elapsedTime} seconds] move:$move');
    case "ToggleDebugOverlay":
      settings.showDebugOverlay = !settings.showDebugOverlay;
    case "ToggleHitbox":
      settings.showHitbox = !settings.showHitbox;
      UI.showHitbox = settings.showHitbox;
    case "ToggleTileId":
      settings.showTileId = !settings.showTileId;
    case "Undo":
      if (Board.isRunning(gamesave)) {
        Board.cancelMove(gamesave);
      }
    case _:
      trace('Unknown action ($action)');
    }
  }
}
