import board.Sequence;

interface IBoard {
  public var WIDTH(default, null):Int;
  public var HEIGHT(default, null):Int;
  public var sequences(default, null):Array<Sequence>;

  public function newGame(?sequenceIndex:Int):Gamesave;
}
