package board;

typedef RawBoard = {
  var board:Array<String>;
  var homes:Array<{owner:Int, color:Int}>;
  var sequences:Array<Array<Int>>;
}

class Boards {
  public static function cook(data:RawBoard):CookedBoard {
    // Players
    var players:Array<Player> = [];
    var owners = new Map<Int, Int>();
    var id = 0;
    for (home in data.homes) {
      players.push({
        id:++id,
        color:home.color,
      });
      owners[id] = home.owner;
    }

    // Tiles
    var tiles:Array<Tile> = [];
    var width = data.board[0].length;
    var height = data.board.length;
    var id = 0;
    for (y in 0...height) {
      var row = data.board[y];
      for (x in 0...width) {
        var value = row.charAt(x);
        if (value != ' ') {
          var player = Std.parseInt(value);
          tiles.push({
            id:++id,
            x:x + 1,
            y:y + 1,
            owner:(player != null) ? owners[player] : null,
            piece:(player != null) ? player : null,
          });
        } 
      }
    }

    // Sequences
    var sequences:Array<Sequence> = data.sequences;

    return {
      WIDTH:width,
      HEIGHT:height,
      players:players,
      tiles:tiles,
      sequences:sequences,
    };
  }
}
