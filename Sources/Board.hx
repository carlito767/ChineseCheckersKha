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
  var color:Int;
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
  var version:Int;
  var sequence:Sequence;
  var players:Map<Int, Player>;
  var tiles:Map<Int, Tile>;
  var moves:Array<Move>;
  var standings:Array<Int>;
  var currentPlayer:Null<Player>; // @StoreOnlyId
  var allowedMoves:Array<Tile>;   // @StoreOnlyId
  var selectedTile:Null<Tile>;    // @StoreOnlyId
}

//
// Board
//

class Board {
  public static inline var GAMESAVE_VERSION = 9;

  public static function create(sourceTiles:Array<Tile>, sourcePlayers:Array<Player>, ?sourceSequence:Sequence):State {
    var sequence:Sequence = (sourceSequence == null) ? [] : sourceSequence;
    var players:Map<Int, Player> = new Map();
    var tiles:Map<Int, Tile> = new Map();
    var moves:Array<Move> = [];
    var standings:Array<Int> = [];
    var currentPlayer:Null<Player> = null;
    var allowedMoves:Array<Tile> = [];
    var selectedTile:Null<Tile> = null;

    // Players
    if (sequence.length > 0) {
      for (player in sourcePlayers) {
        if (sequence.indexOf(player.id) != -1) {
          players[player.id] = {
            id:player.id,
            color:player.color,
          }
        }
      }
    }

    // Tiles
    for (tile in sourceTiles) {
      tiles[tile.id] = {
        id:tile.id,
        x:tile.x,
        y:tile.y,
        owner:tile.owner,
        piece:(tile.piece != null && players[tile.piece] != null) ? tile.piece : null,
      }
    }

    return {
      version:GAMESAVE_VERSION,
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

  public static function victory(state:State, id:Int):Bool {
    return (state.standings.indexOf(id) != -1);
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
