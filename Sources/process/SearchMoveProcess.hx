package process;

import gato.Process;
import gato.Timer;

import board.Move;

class SearchMoveProcess implements Process {
  public var finished:Bool = false;

  var searchFunction:Gamesave->Null<Move>;

  public function new(searchFunction:Gamesave->Null<Move>) {
    this.searchFunction = searchFunction;
  };

  public function update(dt:Float):Void {
    var timer = new Timer();
    var move:Null<Move> = searchFunction(Game.gamesave);
    timer.update();
    trace('[in ${timer.elapsedTime} seconds] move:$move');
    finished = true;
  }
}
