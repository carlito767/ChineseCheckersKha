import board.Player;
import board.Sequence;
import board.Tile;

class BoardChineseCheckers implements IBoard {
  public var WIDTH(default, null):Int = 0;
  public var HEIGHT(default, null):Int = 0;
  public var sequences(default, null):Array<Sequence> = [];

  var players:Array<Player> = [];
  var tiles:Array<Tile> = [];

  public function new() {
    var data = {
      board:[
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
      ],
      homes:[
        { owner:4, color:0xff000000 }, // black
        { owner:5, color:0xff008080 }, // teal
        { owner:6, color:0xff008000 }, // green
        { owner:1, color:0xffff0000 }, // red
        { owner:2, color:0xff800080 }, // purple
        { owner:3, color:0xffffff00 }, // yellow
      ],
      sequences:[
        [ 1, 4 ],
        [ 1, 3, 5 ],
        [ 1, 3, 4, 6 ],
        [ 1, 2, 3, 4, 5, 6 ],
      ]
    };

    // Players
    var owners = new Map();
    var id = 0;
    for (home in data.homes) {
      players.push({
        id:++id,
        color:home.color,
      });
      owners[id] = home.owner;
    }

    // Tiles
    WIDTH = data.board[0].length;
    HEIGHT = data.board.length;
    var id = 0;
    for (y in 0...HEIGHT) {
      var row = data.board[y];
      for (x in 0...WIDTH) {
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
    sequences = data.sequences;
  }

  public function newGame(?sequenceIndex:Int):Gamesave {
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
    var sequence = sequences[sequenceIndex];
    if (sequence != null) {
      gamesave.sequence = sequence.copy();
      for (player in players) {
        if (sequence.contains(player.id)) {
          gamesave.players[player.id] = {
            id:player.id,
            color:player.color,
          }
        }
      }
    }

    // Tiles
    for (tile in tiles) {
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
}
