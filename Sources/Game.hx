import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;

import BoardChineseCheckers as GameBoard;
import Mui.MuiInput;
import board.Move;
import input.Input;
import input.InputStatus;
import input.Keymap;
import input.VirtualKey;

class Game {
  public static var g2(default, null):Graphics = null;

  public static var language:String;
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
    language = 'en';
    locale = new Localization(language);

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
    keymap.set(VirtualKey.Backspace, "Undo");

    ui = new UI();
  }

  static function update():Void {
    inputStatus = input.update();
    var actions:Array<String> = keymap.update(inputStatus);
    for (action in actions) {
      handleAction(action);
    }
  }

  static function render(framebuffers:Array<Framebuffer>):Void {
    g2 = framebuffers[0].g2;

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
      language = (language == 'en') ? 'fr' : 'en';
      locale.load(language);
    case "Undo":
      if (Board.isRunning(gamesave)) {
        Board.cancelMove(gamesave);
      }
    case _:
      trace('Unknown action ($action)');
    }
  }
}
