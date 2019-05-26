import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics as Graphics2;
import kha.graphics4.Graphics as Graphics4;

import BoardChineseCheckers as GameBoard;
import Mui.MuiInput;
import board.Move;
import input.Input;
import input.InputStatus;
import input.Keymap;
import input.VirtualKey;

class Game {
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

  @:allow(Main)
  static function load():Void {
    var renderLoadingScreen = function(framebuffers:Array<Framebuffer>) {
      var g2 = framebuffers[0].g2;
      g2.begin();
      var width = Assets.progress * System.windowWidth();
      var height = System.windowHeight() * 0.02;
      var y = (System.windowHeight() - height) * 0.5;
      g2.color = Color.White;
      g2.fillRect(0, y, width, height);
      g2.end();
    }
    System.notifyOnFrames(renderLoadingScreen);
    Assets.loadEverything(function() {
      System.removeFramesListener(renderLoadingScreen);
      initialize();
      Scheduler.addTimeTask(update, 0, 1 / 60);
      System.notifyOnFrames(render);
    });
  }

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
    keymap.set(VirtualKey.L, "ChangeLanguage");
    keymap.set(VirtualKey.Number0, "ToggleTileId");
    keymap.set(VirtualKey.Number1, "QuickLoad1");
    keymap.set(VirtualKey.Number2, "QuickLoad2");
    keymap.set(VirtualKey.Number3, "QuickLoad3");
    keymap.set(VirtualKey.Number7, "QuickSave1");
    keymap.set(VirtualKey.Number8, "QuickSave2");
    keymap.set(VirtualKey.Number9, "QuickSave3");
    keymap.set(VirtualKey.Backspace, "Undo");

    ui = new UI();

    timer = new Timer();
  }

  static function update():Void {
    timer.update();

    inputStatus = input.update();
    var actions:Array<String> = keymap.update(inputStatus);
    for (action in actions) {
      handleAction(action);
    }
  }

  static function render(framebuffers:Array<Framebuffer>):Void {
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
