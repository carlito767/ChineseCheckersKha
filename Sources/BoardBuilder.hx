import haxe.macro.Context;
import haxe.macro.Expr;

class BoardBuilder {
  public static function build():Array<Field> {
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
      players:[
        { home:4, color:0xff000000 }, // black
        { home:5, color:0xff008080 }, // teal
        { home:6, color:0xff008000 }, // green
        { home:1, color:0xffff0000 }, // red
        { home:2, color:0xff800080 }, // purple
        { home:3, color:0xffffff00 }, // yellow
      ],
      sequences:[
        [ 1, 4 ],
        [ 1, 3, 5 ],
        [ 1, 3, 4, 6 ],
        [ 1, 2, 3, 4, 5, 6 ],
      ]
    }

    // Players
    var players = [];
    var owners = new Map();
    var id = 0;
    for (player in data.players) {
      players.push({
        id:++id,
        color:player.color,
      });
      owners[player.home] = id;
    }

    // Tiles
    var tiles = [];
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

    //
    // Fields
    //

    var fields = Context.getBuildFields();

    // WIDTH
    fields.push({
      access:[APublic,AStatic,AInline],
      name:'WIDTH',
      pos:Context.currentPos(),
      kind:FVar(macro:Int, macro $v{width}),
    });

    // HEIGHT
    fields.push({
      access:[APublic,AStatic,AInline],
      name:'HEIGHT',
      pos:Context.currentPos(),
      kind:FVar(macro:Int, macro $v{height}),
    });

    // players
    fields.push({
      access:[AStatic],
      name:'players',
      pos:Context.currentPos(),
      kind:FVar(macro:Array<{
        var id:Int;
        var color:Int;
      }>, macro $v{players}),
    });

    // tiles
    fields.push({
      access:[AStatic],
      name:'tiles',
      pos:Context.currentPos(),
      kind:FVar(macro:Array<{
        var id:Int;
        var x:Int;
        var y:Int;
        var owner:Null<Int>;
        var piece:Null<Int>;
      }>, macro $v{tiles}),
    });

    // SEQUENCES
    fields.push({
      access:[APublic,AStatic],
      name:'SEQUENCES',
      pos:Context.currentPos(),
      kind:FVar(macro:Array<Array<Int>>, macro $v{data.sequences}),
    });

    return fields;
  }
}
