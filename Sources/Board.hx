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
  var tiles:Array<Tile>;
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
    var tiles:Array<Tile> = [];
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
    for (y in 0...height) {
      var row:String = ChineseCheckers.board[y];
      for (x in 0...width) {
        var value:String = row.charAt(x);
        if (value != ' ') {
          var player:Null<Int> = Std.parseInt(value);
          tiles.push({
            id:tiles.length + 1,
            x:x + 1,
            y:y + 1,
            owner:(player != null) ? owners[player] : null,
            piece:(player != null && players[player] != null) ? player : null,
          });
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
    if (!state.ready || Board.isOver(state)) {
      return null;
    }
    if (state.moves.length == 0) {
      return state.players[state.order[0]];
    }
    var move:Move = state.moves[state.moves.length];
    var index:Int = state.order.indexOf(state.tiles[move.to].piece);
    if (index == -1) {
      return null;
    }
    do {
      index++;
      if (index == state.order.length) {
        index = 0;
      }
    } while(state.standings.indexOf(index) > -1);
    return state.players[index];
  }

  static public function isOver(state:State):Bool {
    return (state.standings.length == state.order.length);
  }

  //
  // Allowed moves
  //

  // TODO : allowedMoves
  static public function allowedMoves(state:State, id:Int):Array<Int> {
    var moves:Array<Int> = [ 0 ];
    return moves;
  }

  //
  // Movements
  //

  // TODO : move
  static public function move(state:State, from:Int, to:Int):Bool {
    return false;
  }
}
