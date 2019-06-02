package board;

typedef RawBoard = {
  var board:Array<String>;
  var homes:Array<{owner:Int, color:Int}>;
  var sequences:Array<Array<Int>>;
}

// TODO:[carlito 20180907] implement anti-spoiling rule (https://www.mastersofgames.com/rules/chinese-checkers-rules.htm)
class Board {
  public static function newBoard(data:RawBoard):CookedBoard {
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

  public static function newState(board:CookedBoard, ?sequenceIndex:Int):BoardState {
    // Players
    var players = new Map<Int, Player>();
    var sequence = board.sequences[sequenceIndex];
    if (sequence != null) {
      for (player in board.players) {
        if (sequence.contains(player.id)) {
          players[player.id] = {
            id:player.id,
            color:player.color,
          }
        }
      }
    }

    // Tiles
    var tiles = new Map<Int, Tile>();
    for (tile in board.tiles) {
      tiles[tile.id] = {
        id:tile.id,
        x:tile.x,
        y:tile.y,
        owner:tile.owner,
        piece:(tile.piece != null && players[tile.piece] != null) ? tile.piece : null,
      }
    }

    return {
      sequence:(sequence == null) ? [] : sequence.copy(),
      players:players,
      tiles:tiles,
      moves:[],
      standings:[],
      currentPlayerId:null,
    };
  }

  //
  // State
  //

  public static function start(state:BoardState):Void {
    state.currentPlayerId = state.sequence.shift();
  }

  public static function isRunning(state:BoardState):Bool {
    return (state.currentPlayerId != null);
  }

  // We assume that there are at least two players
  public static function isOver(state:BoardState):Bool {
    return (state.currentPlayerId != null && state.sequence.length == 0);
  }

  //
  // Moves
  //

  public static function move(state:BoardState, from:Tile, to:Tile):Void {
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
    else {
      state.sequence.push(to.piece);
    }

    // Update Current Player
    state.currentPlayerId = state.sequence.shift();
  }

  public static function cancelMove(state:BoardState):Void {
    if (state.moves.length == 0) {
      return;
    }

    var move = state.moves.pop();
    var from = state.tiles[move.from];
    var to = state.tiles[move.to];
    from.piece = to.piece;
    to.piece = null;

    // Update Standings
    if (state.currentPlayerId != null) {
      state.sequence.unshift(state.currentPlayerId);
    }
    if (state.standings.length > 0 && state.standings[state.standings.length-1] == from.piece) {
      state.standings.pop();
    }

    // Update Current Player
    state.currentPlayerId = state.sequence.pop();
  }

  //
  // Allowed moves
  //

  public static function allowedMoves(state:BoardState):Array<Move> {
    var moves:Array<Move> = [];
    if (state.currentPlayerId == null) {
      return moves;
    }

    var playerId = state.currentPlayerId; 
    for (from in state.tiles) {
      if (from.piece == playerId) {
        for (move in Board.allowedMovesForTile(state, from)) {
          moves.push(move);
        }
      }
    }
    return moves;
  }

  public static function allowedMovesForTile(state:BoardState, tile:Tile):Array<Move> {
    var tiles:Array<Tile> = [];
    jumps(state, tile, tiles);
    for (neighbor in neighbors(state, tile)) {
      if (neighbor.piece == null) {
        tiles.push(neighbor);
      }
    }

    // Once a peg has reached his home, it may not leave it
    if (tile.piece == tile.owner) {
      var i = 0;
      while (i < tiles.length) {
        if (tiles[i].owner != tile.owner) {
          tiles.splice(i, 1);
        }
        else {
          ++i;
        }
      }
    }

    var moves:Array<Move> = [];
    for (allowedTile in tiles) {
      moves.push({ from:tile.id, to:allowedTile.id });
    }
    return moves;
  }

  static function neighbors(state:BoardState, tile:Tile):Array<Tile> {
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

  static function jump(state:BoardState, from:Tile, via:Tile):Null<Tile> {
    var x = via.x + (via.x - from.x);
    var y = via.y + (via.y - from.y);
    for (tile in state.tiles) {
      if (tile.x == x && tile.y == y) {
        return tile;
      }
    }
    return null;
  }

  static function jumps(state:BoardState, tile:Tile, tiles:Array<Tile>):Void {
    for (neighbor in neighbors(state, tile)) {
      if (neighbor.piece != null) {
        var jumpTile = jump(state, tile, neighbor);
        if (jumpTile != null && jumpTile.piece == null && !tiles.contains(jumpTile)) {
          tiles.push(jumpTile);
          jumps(state, jumpTile, tiles);
        }
      }
    }
  }
}
