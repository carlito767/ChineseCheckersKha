package process;

import gato.Process;

import BoardChineseCheckers as GameBoard;

class SelectSequenceProcess implements Process {
  public var finished:Bool = false;

  var sequenceIndex:Null<Int>;

  public function new(sequenceIndex:Null<Int>) {
    this.sequenceIndex = sequenceIndex;
  };

  public function update(dt:Float):Void {
    var sequence = (sequenceIndex == null) ? null : GameBoard.sequences[sequenceIndex].copy();
    Game.gamesave = Board.create(GameBoard.tiles, GameBoard.players, sequence);
    finished = true;
  }
}
