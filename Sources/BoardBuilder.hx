import haxe.macro.Context;
import haxe.macro.Expr;

class BoardBuilder {
  public static function build(board:Array<String>, homes:Array<{owner:Int, color:Int}>, sequences:Array<Array<Int>>):Array<Field> {
    // Players
    var players = [];
    var owners = new Map();
    var id = 0;
    for (home in homes) {
      players.push({
        id:++id,
        color:home.color,
      });
      owners[id] = home.owner;
    }

    // Tiles
    var tiles = [];
    var width = board[0].length;
    var height = board.length;
    var id = 0;
    for (y in 0...height) {
      var row = board[y];
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
      access:[APublic,AStatic],
      name:'players',
      pos:Context.currentPos(),
      kind:FVar(macro:Array<{
        var id:Int;
        var color:Int;
      }>, macro $v{players}),
    });

    // tiles
    fields.push({
      access:[APublic,AStatic],
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

    // sequences
    fields.push({
      access:[APublic,AStatic],
      name:'sequences',
      pos:Context.currentPos(),
      kind:FVar(macro:Array<Array<Int>>, macro $v{sequences}),
    });

    return fields;
  }
}
