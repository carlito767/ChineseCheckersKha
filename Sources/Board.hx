import kha.Color;

import Boards.CookedBoard;
import board.Move;
import board.Tile;

// TODO:[carlito 20180907] implement anti-spoiling rule (https://www.mastersofgames.com/rules/chinese-checkers-rules.htm)
class Board {
  public static function newGame(board:CookedBoard, ?sequenceIndex:Int):Gamesave {
    var gamesave:Gamesave = {
      sequence:[],
      players:new Map(),
      tiles:new Map(),
      moves:[],
      standings:[],
      currentPlayerId:null,
      selectedTileId:null,
    };

    // Players
    var sequence = board.sequences[sequenceIndex];
    if (sequence != null) {
      gamesave.sequence = sequence.copy();
      for (player in board.players) {
        if (sequence.contains(player.id)) {
          gamesave.players[player.id] = {
            id:player.id,
            color:player.color,
          }
        }
      }
    }

    // Tiles
    for (tile in board.tiles) {
      gamesave.tiles[tile.id] = {
        id:tile.id,
        x:tile.x,
        y:tile.y,
        owner:tile.owner,
        piece:(tile.piece != null && gamesave.players[tile.piece] != null) ? tile.piece : null,
      }
    }

    return gamesave;
  }

  //
  // State
  //

  public static function start(gamesave:Gamesave):Void {
    gamesave.currentPlayerId = gamesave.sequence.shift();
  }

  public static function isOver(gamesave:Gamesave):Bool {
    return (gamesave.standings.length > 0 && gamesave.sequence.length == 1);
  }

  public static function isRunning(gamesave:Gamesave):Bool {
    return (gamesave.currentPlayerId != null);
  }

  //
  // Moves
  //

  public static function move(gamesave:Gamesave, from:Tile, to:Tile):Void {
    to.piece = from.piece;
    from.piece = null;
    gamesave.moves.push({from:from.id, to:to.id});

    // Update Standings
    var victory = true;
    for (tile in gamesave.tiles) {
      if (tile.piece == to.piece && tile.owner != to.piece) {
        victory = false;
        break;
      }
    }
    if (victory) {
      gamesave.standings.push(to.piece);
    }
    else {
      gamesave.sequence.push(to.piece);
    }

    // Update Selected Tile
    gamesave.selectedTileId = null;

    // Update Current Player
    gamesave.currentPlayerId = gamesave.sequence.shift();
  }

  public static function cancelMove(gamesave:Gamesave):Void {
    if (gamesave.moves.length == 0) {
      return;
    }

    var move = gamesave.moves.pop();
    var from = gamesave.tiles[move.from];
    var to = gamesave.tiles[move.to];
    from.piece = to.piece;
    to.piece = null;

    // Update Standings
    if (gamesave.currentPlayerId != null) {
      gamesave.sequence.unshift(gamesave.currentPlayerId);
    }
    if (gamesave.standings.length > 0 && gamesave.standings[gamesave.standings.length-1] == from.piece) {
      gamesave.standings.pop();
    }

    // Update Selected Tile
    gamesave.selectedTileId = null;

    // Update Current Player
    gamesave.currentPlayerId = gamesave.sequence.pop();
  }

  //
  // Allowed moves
  //

  public static function allowedMoves(gamesave:Gamesave):Array<Move> {
    var moves:Array<Move> = [];
    if (gamesave.currentPlayerId == null) {
      return moves;
    }

    var playerId = gamesave.currentPlayerId; 
    for (from in gamesave.tiles) {
      if (from.piece == playerId) {
        for (move in Board.allowedMovesForTile(gamesave, from)) {
          moves.push(move);
        }
      }
    }
    return moves;
  }

  public static function allowedMovesForTile(gamesave:Gamesave, tile:Tile):Array<Move> {
    var tiles:Array<Tile> = [];
    jumps(gamesave, tile, tiles);
    for (neighbor in neighbors(gamesave, tile)) {
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

  static function neighbors(gamesave:Gamesave, tile:Tile):Array<Tile> {
    //    (1) (2)
    //      \ /
    //  (3)- * -(4)
    //      / \
    //    (5) (6)
    var tiles:Array<Tile> = [];
    for (neighbor in gamesave.tiles) {
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

  static function jump(gamesave:Gamesave, from:Tile, via:Tile):Null<Tile> {
    var x = via.x + (via.x - from.x);
    var y = via.y + (via.y - from.y);
    for (tile in gamesave.tiles) {
      if (tile.x == x && tile.y == y) {
        return tile;
      }
    }
    return null;
  }

  static function jumps(gamesave:Gamesave, tile:Tile, tiles:Array<Tile>):Void {
    for (neighbor in neighbors(gamesave, tile)) {
      if (neighbor.piece != null) {
        var jumpTile = jump(gamesave, tile, neighbor);
        if (jumpTile != null && jumpTile.piece == null && !tiles.contains(jumpTile)) {
          tiles.push(jumpTile);
          jumps(gamesave, jumpTile, tiles);
        }
      }
    }
  }
}
