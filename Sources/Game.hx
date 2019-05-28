import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;

import BoardChineseCheckers as GameBoard;
import Mui.MuiInput;

class Game {
  public static var g2(default, null):Graphics = null;

  public static var gb(default, null):GameBoard = new GameBoard();

  public static var gamesave:Gamesave;
  public static var sequenceIndex(default, set):Null<Int>;
  static function set_sequenceIndex(value) {
    gamesave = gb.newGamesave(value);
    return sequenceIndex = value;
  }

  public static var scene:UIFlow;

  static var mouse:Mouse;
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
    Localization.initialize();

    sequenceIndex = null;

    scene = Scenes.title;

    mouse = new Mouse();
    ui = new UI();
  }

  static function update():Void {
  }

  static function render(framebuffers:Array<Framebuffer>):Void {
    g2 = framebuffers[0].g2;

    Scaling.update(WIDTH, HEIGHT);

    g2.begin();
    g2.scissor(Std.int(Scaling.dx), Std.int(Scaling.dy), Std.int(WIDTH * Scaling.scale), Std.int(HEIGHT * Scaling.scale));

    ui.begin(mouse.input);
    ui.render(g2, scene);
    ui.end();

    g2.disableScissor();
    g2.end();
  }
}
