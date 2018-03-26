import kha.Color;

//
// State
//

typedef Move = {
  var from:Int;
  var to:Int;
}

typedef Player = {
  var id:Int;
  var color:Color;
}

typedef Tile = {
  var id:Int;
  var x:Int;
  var y:Int;
  var owner:Null<Int>;
  var piece:Null<Int>;
}

typedef State = {
  var ready:Bool;
  var width:Int;
  var height:Int;
  var order:Array<Int>;
  var players:Map<Int, Player>;
  var tiles:Map<Int, Tile>;
  var moves:Array<Move>;
  var standings:Array<Int>;
}

//
// Raw Board
//

typedef RawMode = {
  var id:String;
  var order:Array<Int>;
}

typedef RawPlayer = {
  var home:Int;
  var color:Color;
}

class ChineseCheckers {
  static public var board(default, null):Array<String> = [
    '            4            ',
    '           4 4           ',
    '          4 4 4          ',
    '         4 4 4 4         ',
    '3 3 3 3 * * * * * 5 5 5 5',
    ' 3 3 3 * * * * * * 5 5 5 ',
    '  3 3 * * * * * * * 5 5  ',
    '   3 * * * * * * * * 5   ',
    '    * * * * * * * * *    ',
    '   2 * * * * * * * * 6   ',
    '  2 2 * * * * * * * 6 6  ',
    ' 2 2 2 * * * * * * 6 6 6 ',
    '2 2 2 2 * * * * * 6 6 6 6',
    '         1 1 1 1         ',
    '          1 1 1          ',
    '           1 1           ',
    '            1            ',
  ];

  static public var players(default, null):Array<RawPlayer> = [
    { home:4, color:Color.Black },
    { home:5, color:Color.fromBytes(  0, 128, 128) }, // teal
    { home:6, color:Color.fromBytes(  0, 128,   0) }, // green
    { home:1, color:Color.Red },
    { home:2, color:Color.Purple },
    { home:3, color:Color.Yellow },
  ];

  static public var modes(default, null):Array<RawMode> = [
    { id:"2", order:[ 1, 4 ] },
    { id:"3", order:[ 1, 3, 5 ] },
    { id:"4", order:[ 1, 3, 4, 6 ] },
    { id:"6", order:[ 1, 2, 3, 4, 5, 6 ] },
  ];
}

//
// Board
//

class Board {
  static public function create(modeIndex:Null<Int>):State {
    var width:Int = ChineseCheckers.board[0].length;
    var height:Int = ChineseCheckers.board.length;
    var order:Array<Int> = [];
    var players:Map<Int, Player> = new Map<Int, Player>();
    var tiles:Map<Int, Tile> = new Map<Int, Tile>();
    var moves:Array<Move> = [];
    var standings:Array<Int> = [];

    // Players
    var owners:Map<Int, Int> = new Map<Int, Int>();
    if (modeIndex != null) {
      var mode:RawMode = ChineseCheckers.modes[modeIndex];
      order = mode.order;
      for (id in order) {
        var player:RawPlayer = ChineseCheckers.players[id-1];
        players[id] = {
          id:id,
          color:player.color,
        };
        owners[player.home] = id;
      }
    }

    // Tiles
    var id:Int = 0;
    for (y in 0...height) {
      var row:String = ChineseCheckers.board[y];
      for (x in 0...width) {
        var value:String = row.charAt(x);
        if (value != ' ') {
          var player:Null<Int> = Std.parseInt(value);
          tiles[++id] = {
            id:id,
            x:x + 1,
            y:y + 1,
            owner:(player != null) ? owners[player] : null,
            piece:(player != null && players[player] != null) ? player : null,
          };
        } 
      }
    }

    return {
      ready:false,
      width:width,
      height:height,
      order:order,
      players:players,
      tiles:tiles,
      moves:moves,
      standings:standings,
    }
  }

  //
  // Players
  //

  static public function currentPlayer(state:State):Null<Player> {
    if (!state.ready || isOver(state)) {
      return null;
    }
    if (state.moves.length == 0) {
      return state.players[state.order[0]];
    }
    var move:Move = state.moves[state.moves.length-1];
    var index:Int = state.order.indexOf(state.tiles[move.to].piece);
    if (index == -1) {
      return null;
    }
    var player:Null<Player>;
    do {
      index++;
      if (index == state.order.length) {
        index = 0;
      }
      player = state.players[state.order[index]];
    } while(state.standings.indexOf(player.id) > -1);
    return player;
  }

  static public function isOver(state:State):Bool {
    return (state.standings.length == state.order.length);
  }

  //
  // Allowed moves
  //

  static function neighbors(state:State, tile:Tile):Array<Tile> {
    //    (1) (2)
    //      \ /
    //  (3)- * -(4)
    //      / \
    //    (5) (6)
    var tiles:Array<Tile> = [];
    for (neighbor in state.tiles) {
      if (
        ((neighbor.x == tile.x - 1) && (neighbor.y == tile.y - 1)) || // (1)
        ((neighbor.x == tile.x + 1) && (neighbor.y == tile.y - 1)) || // (2)
        ((neighbor.x == tile.x - 2) && (neighbor.y == tile.y    )) || // (3)
        ((neighbor.x == tile.x + 2) && (neighbor.y == tile.y    )) || // (4)
        ((neighbor.x == tile.x - 1) && (neighbor.y == tile.y + 1)) || // (5)
        ((neighbor.x == tile.x + 1) && (neighbor.y == tile.y + 1))    // (6)
      ) {
        tiles.push(neighbor);
      }
    }

    return tiles;
  }

  static function jump(state:State, from:Tile, via:Tile):Null<Tile> {
    var x:Int = via.x + (via.x - from.x);
    var y:Int = via.y + (via.y - from.y);
    for (tile in state.tiles) {
      if (tile.x == x && tile.y == y) {
        return tile;
      }
    }
    return null;
  }

  static function jumps(state:State, tile:Tile, tiles:Array<Tile>) {
    for (neighbor in neighbors(state, tile)) {
      if (neighbor.piece != null) {
        var jumpTile:Null<Tile> = jump(state, tile, neighbor);
        if (jumpTile != null && jumpTile.piece == null && tiles.indexOf(jumpTile) == -1) {
          tiles.push(jumpTile);
          jumps(state, jumpTile, tiles);
        }
      }
    }
  }

  static public function allowedMoves(state:State, tile:Tile):Array<Tile> {
    var moves:Array<Tile> = [];
    if (currentPlayer(state) == null || tile.piece != currentPlayer(state).id) {
      return moves;
    }

    jumps(state, tile, moves);
    for (neighbor in neighbors(state, tile)) {
      if (neighbor.piece == null) {
        moves.push(neighbor);
      }
    }

    // Once a peg has reached his home, it may not leave it
    var currentPlayerId = currentPlayer(state).id;
    if (tile.owner == currentPlayerId) {
      var i:Int = 0;      
      while (i < moves.length) {
        var moveTile = moves[i];
        if (moveTile.owner != currentPlayerId) {
            moves.splice(i, 1);
        }
        else {
          ++i;
        }
      }
    }

    return moves;
  }

  //
  // Movements
  //

  static public function move(state:State, from:Tile, to:Tile):Bool {
    if (allowedMoves(state, from).indexOf(to) == -1) {
      return false;
    }
    to.piece = from.piece;
    from.piece = null;
    state.moves.push({from:from.id, to:to.id});

    // TODO : victory
    // TODO : standings

    return true;
  }

  // TODO : cancel last move
}
