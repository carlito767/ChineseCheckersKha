import kha.Color;

typedef Gamesave = {
  var version:Int;
  var width:Int;
  var height:Int;
  var sequence:Sequence;
  var players:Map<Int, Player>;
  var tiles:Map<Int, Tile>;
  var moves:Array<Move>;
  var standings:Array<Int>;
}

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

typedef Sequence = Array<Int>;

typedef State = {
  var width:Int;
  var height:Int;
  var sequence:Sequence;
  var players:Map<Int, Player>;
  var tiles:Map<Int, Tile>;
  var moves:Array<Move>;
  var standings:Array<Int>;
  var currentPlayer:Null<Player>;
  var allowedMoves:Array<Tile>;
  var selectedTile:Null<Tile>;
}

//
// Raw Board
//

typedef RawPlayer = {
  var home:Int;
  var color:Color;
}

class ChineseCheckers {
  public static var board(default, null):Array<String> = [
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

  public static var players(default, null):Array<RawPlayer> = [
    { home:4, color:Color.Black },
    { home:5, color:Color.fromBytes(  0, 128, 128) }, // teal
    { home:6, color:Color.fromBytes(  0, 128,   0) }, // green
    { home:1, color:Color.Red },
    { home:2, color:Color.Purple },
    { home:3, color:Color.Yellow },
  ];

  public static var sequences(default, null):Array<Sequence> = [
    [ 1, 4 ],
    [ 1, 3, 5 ],
    [ 1, 3, 4, 6 ],
    [ 1, 2, 3, 4, 5, 6 ],
  ];
}

//
// Board
//

class Board {
  static inline var GAMESAVE_VERSION = 4;

  public static function sequences():Array<Sequence> {
    return ChineseCheckers.sequences;
  }

  public static function create(?sequenceIndex:Int):State {
    var width:Int = ChineseCheckers.board[0].length;
    var height:Int = ChineseCheckers.board.length;
    var sequence:Sequence = [];
    var players:Map<Int, Player> = new Map<Int, Player>();
    var tiles:Map<Int, Tile> = new Map<Int, Tile>();
    var moves:Array<Move> = [];
    var standings:Array<Int> = [];
    var currentPlayer:Null<Player> = null;
    var allowedMoves:Array<Tile> = [];
    var selectedTile:Null<Tile> = null;

    // Players
    var owners = new Map<Int, Int>();
    if (sequenceIndex != null) {
      sequence = ChineseCheckers.sequences[sequenceIndex];
      for (id in sequence) {
        var player = ChineseCheckers.players[id-1];
        players[id] = {
          id:id,
          color:player.color,
        };
        owners[player.home] = id;
      }
    }

    // Tiles
    var id = 0;
    for (y in 0...height) {
      var row = ChineseCheckers.board[y];
      for (x in 0...width) {
        var value = row.charAt(x);
        if (value != ' ') {
          var player = Std.parseInt(value);
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
      width:width,
      height:height,
      sequence:sequence,
      players:players,
      tiles:tiles,
      moves:moves,
      standings:standings,
      currentPlayer:currentPlayer,
      selectedTile:selectedTile,
      allowedMoves:allowedMoves,
    }
  }

  public static function start(state:State) {
    update(state);
  }

  public static function isOver(state:State):Bool {
    return (state.standings.length > 0 && state.standings.length == state.sequence.length - 1);
  }

  public static function isRunning(state:State):Bool {
    return (state.currentPlayer != null);
  }

  //
  // Gamesave
  //

  public static function load(gamesave:Null<Gamesave>):Null<State> {
    if (gamesave == null) {
      return null;
    }

    var state:State = {
      width:gamesave.width,
      height:gamesave.height,
      sequence:gamesave.sequence,
      players:gamesave.players,
      tiles:gamesave.tiles,
      moves:gamesave.moves,
      standings:gamesave.standings,

      selectedTile:null,
      currentPlayer:null,
      allowedMoves:[],
    };

    switch gamesave.version {
    case 1:
    case 2:
    case 3:
    case GAMESAVE_VERSION:
    default:
      trace('Gamesave: unknown version');
      return null;
    }

    start(state);

    return state;
  }

  public static function save(state:State):Gamesave {
    return {
      version:GAMESAVE_VERSION,
      width:state.width,
      height:state.height,
      sequence:state.sequence,
      players:state.players,
      tiles:state.tiles,
      moves:state.moves,
      standings:state.standings,
    };
  }

  //
  // Moves
  //

  public static function move(state:State, from:Tile, to:Tile) {
    applyMove(state, from, to);
    state.selectedTile = null;
    update(state);
  }

  public static function cancelLastMove(state:State) {
    if (state.selectedTile != null) {
      state.selectedTile = null;
      return;
    }

    cancelMove(state);
    update(state);
  }

  public static function applyMove(state:State, from:Tile, to:Tile) {
    to.piece = from.piece;
    from.piece = null;
    state.moves.push({from:from.id, to:to.id});

    // Update Standings
    var victory = true;
    for (tile in state.tiles) {
      if (tile.piece == to.piece && tile.owner != to.piece) {
        victory = false;
        break;
      }
    }
    if (victory) {
      state.standings.push(to.piece);
    }
  }

  public static function cancelMove(state:State) {
    if (state.moves.length == 0) {
      return;
    }

    var move = state.moves.pop();
    var from = state.tiles[move.from];
    var to = state.tiles[move.to];
    from.piece = to.piece;
    to.piece = null;

    // Update Standings
    if (state.standings.length > 0 && state.standings[state.standings.length-1] == from.piece) {
      state.standings.pop();
    }
  }

  //
  // Allowed moves
  //

  public static function allowedMoves(state:State):Array<Tile> {
    var moves:Array<Tile> = [];
    if (state.currentPlayer == null) {
      return moves;
    }

    var player = state.currentPlayer; 
    for (tile in state.tiles) {
      if (tile.piece == player.id && allowedMovesForTile(state, tile).length > 0) {
        moves.push(tile);
      }
    }
    return moves;
  }

  public static function allowedMovesForTile(state:State, tile:Tile) {
    var moves:Array<Tile> = [];

    jumps(state, tile, moves);
    for (neighbor in neighbors(state, tile)) {
      if (neighbor.piece == null) {
        moves.push(neighbor);
      }
    }

    // Once a peg has reached his home, it may not leave it
    if (tile.piece == tile.owner) {
      var i = 0;
      while (i < moves.length) {
        var moveTile = moves[i];
        if (moveTile.owner != tile.owner) {
          moves.splice(i, 1);
        }
        else {
          ++i;
        }
      }
    }

    return moves;
  }

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
    var x = via.x + (via.x - from.x);
    var y = via.y + (via.y - from.y);
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
        var jumpTile = jump(state, tile, neighbor);
        if (jumpTile != null && jumpTile.piece == null && tiles.indexOf(jumpTile) == -1) {
          tiles.push(jumpTile);
          jumps(state, jumpTile, tiles);
        }
      }
    }
  }

  //
  // Update
  //

  public static function update(state:State) {
    updateCurrentPlayer(state);
    updateAllowedMoves(state);
  }

  static function updateCurrentPlayer(state:State) {
    var player:Null<Player> = null;
    if (!isOver(state)) {
      if (state.moves.length == 0) {
        player = state.players[state.sequence[0]];
      }
      else {
        var move = state.moves[state.moves.length-1];
        var index = state.sequence.indexOf(state.tiles[move.to].piece);
        if (index > -1) {
          do {
            index++;
            if (index == state.sequence.length) {
              index = 0;
            }
            player = state.players[state.sequence[index]];
          } while(state.standings.indexOf(player.id) > -1);
        }
      }
    }
    state.currentPlayer = player;
  }

  static function updateAllowedMoves(state:State) {
    state.allowedMoves = (state.selectedTile == null) ? allowedMoves(state) : allowedMovesForTile(state, state.selectedTile);
  }
}
