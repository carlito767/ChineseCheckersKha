import board.Move;
import board.Player;
import board.Sequence;
import board.Tile;

typedef GamesaveData = {
  var version:Int;
  var sequence:Sequence;
  var players:Map<Int, Player>;
  var tiles:Map<Int, Tile>;
  var moves:Array<Move>;
  var standings:Array<Int>;
  var currentPlayerId:Null<Int>;
  var selectedTile:Null<Tile>;    // TODO:[carlito 20180811] store only id?
}
