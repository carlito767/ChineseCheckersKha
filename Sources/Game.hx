import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import board.Board;
import board.BoardChineseCheckers;
import board.BoardDebug;
import board.BoardState;
import board.CookedBoard;
import localization.Localization;
import ui.UI;
import ui.UIFlow;

class Game {
  public static var ME:Game;

  public var board(default, never):CookedBoard = BoardChineseCheckers.cook();
  // public static var board(default, never):CookedBoard = BoardDebug.cook();

  public var state:BoardState;
  public var selectedSequenceIndex(default, set):Null<Int>;
  function set_selectedSequenceIndex(value) {
    state = Board.newState(board, value);
    selectedTileId = null;
    return selectedSequenceIndex = value;
  }
  public var selectedTileId:Null<Int>;

  public var scene:UIFlow;

  var mouse:Mouse;
  var ui:UI;

  @:allow(Main)
  function new() {
    ME = this;

    Localization.initialize();

    selectedSequenceIndex = null;

    scene = Scenes.title;

    mouse = new Mouse();
    ui = new UI();

    Scheduler.addTimeTask(update, 0, 1 / 60);
    System.notifyOnFrames(render);
  }

  function update():Void {
  }

  function render(framebuffers:Array<Framebuffer>):Void {
    var g2 = framebuffers[0].g2;

    Scaling.update(WIDTH, HEIGHT);

    g2.begin();
    g2.scissor(Std.int(Scaling.dx), Std.int(Scaling.dy), Std.int(WIDTH * Scaling.scale), Std.int(HEIGHT * Scaling.scale));

    ui.begin({ x:mouse.x, y:mouse.y, select:mouse.isPressed(0) });
    ui.render(g2, scene);
    ui.end();

    g2.disableScissor();
    g2.end();
  }
}
