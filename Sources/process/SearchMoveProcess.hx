package process;

import gato.Process;
import gato.Timer;

import ai.AI;
import board.Move;

class SearchMoveProcess implements Process {
  public var finished:Bool = false;

  var ai:AI;

  public function new<T:(AI)>(ai:AI) {
    this.ai = ai;
  };

  public function update(dt:Float):Void {
    var timer = new Timer();
    var move:Null<Move> = ai.search(Game.gamesave);
    timer.update();
    trace('[in ${timer.elapsedTime} seconds] move:$move');
    finished = true;
  }
}
