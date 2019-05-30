import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import Boards.CookedBoard;

class Game {
  public static var board(default, never):CookedBoard = BoardChineseCheckers.cook();
  // public static var board(default, never):CookedBoard = BoardDebug.cook();

  public static var state:BoardState;
  public static var selectedSequenceIndex(default, set):Null<Int>;
  static function set_selectedSequenceIndex(value) {
    state = Board.newState(board, value);
    selectedTileId = null;
    return selectedSequenceIndex = value;
  }
  public static var selectedTileId:Null<Int>;

  public static var scene:UIFlow;

  static var mouse:Mouse;
  static var ui:UI;

  @:allow(Main)
  static function initialize():Void {
    Localization.initialize();

    selectedSequenceIndex = null;

    scene = Scenes.title;

    mouse = new Mouse();
    ui = new UI();

    Scheduler.addTimeTask(update, 0, 1 / 60);
    System.notifyOnFrames(render);
  }

  static function update():Void {
  }

  static function render(framebuffers:Array<Framebuffer>):Void {
    var g2 = framebuffers[0].g2;

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
