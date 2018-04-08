import Board.Player;
import Board.Tile;
import Board.State;

class AI {
  static public function evaluate(state:State, player:Player):Int {
    // TODO: evaluate
    return 0;
  }

  static public function distance(state:State, tile:Tile):Int {
    if (tile.piece == null || tile.piece == tile.owner) {
      return 0;
    }
    var goal:Null<Int> = switch tile.piece {
      case 1: 1;
      case 2: 23;
      case 3: 111;
      case 4: 121;
      case 5: 99;
      case 6: 11;
      default: null;
    }
    if (goal == null) {
      return 0;
    }
    var destination = state.tiles[goal];
    if (destination == null) {
      return 0;
    }
    var dx = Math.abs(destination.x - tile.x);
    var dy = Math.abs(destination.y - tile.y);
    if (dy > dx) {
      return Std.int(dy);
    }
    else {
      return Std.int((dx - dy) * 0.5 + dy);
    }
  }
}
