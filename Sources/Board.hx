import kha.Color;

//
// Game State
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

typedef GameState = {
  var width:Int;
  var height:Int;
  var order:Array<Int>;
  var players:Map<Int, Player>;
  var tiles:Array<Tile>;
  var moves:Array<Move>;
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
    { home:5, color:0xff008080 }, // teal
    { home:6, color:Color.Green },
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
  static public function create(modeIndex:Int):GameState {
    // Size
    var width:Int = ChineseCheckers.board[0].length;
    var height:Int = ChineseCheckers.board.length;

    // Players
    var mode:RawMode = ChineseCheckers.modes[modeIndex];
    var players:Map<Int, Player> = new Map<Int, Player>();
    var owners:Map<Int, Int> = new Map<Int, Int>();
    for (id in mode.order) {
      var player:RawPlayer = ChineseCheckers.players[id-1];
      players[id] = {
        id:id,
        color:player.color,
      };
      owners[player.home] = id;
    }

    // Tiles
    var tiles:Array<Tile> = [];
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
            piece:(player != null) ? player : null,
          });
        } 
      }
    }

    // Moves
    var moves:Array<Move> = [];

    return {
      width:width,
      height:height,
      order:mode.order,
      players:players,
      tiles:tiles,
      moves:moves,
    }
  }
}
