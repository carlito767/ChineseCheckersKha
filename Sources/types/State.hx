package types;

typedef State = {
  var version:Int;
  var sequence:Sequence;
  var players:Map<Int, Player>;
  var tiles:Map<Int, Tile>;
  var moves:Array<Move>;
  var standings:Array<Int>;
  var currentPlayer:Null<Player>; // @@Improvement: store only id?
  var allowedMoves:Array<Tile>;   // @@Improvement: store only id?
  var selectedTile:Null<Tile>;    // @@Improvement: store only id?
}
