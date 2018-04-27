import haxe.macro.Context;
import haxe.macro.Expr;

class BoardBuilder {
  static public function build():Array<Field> {
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

    var fields = Context.getBuildFields();

    // WIDTH
    fields.push({
      access:[APublic,AStatic,AInline],
      name:'WIDTH',
      pos:Context.currentPos(),
      kind:FVar(macro:Int, macro $v{data.board[0].length}),
    });

    // HEIGHT
    fields.push({
      access:[APublic,AStatic,AInline],
      name:'HEIGHT',
      pos:Context.currentPos(),
      kind:FVar(macro:Int, macro $v{data.board.length}),
    });

    // BOARD
    fields.push({
      access:[AStatic],
      name:'BOARD',
      pos:Context.currentPos(),
      kind:FVar(macro:Array<String>, macro $v{data.board}),
    });

    // PLAYERS
    fields.push({
      access:[AStatic],
      name:'PLAYERS',
      pos:Context.currentPos(),
      kind:FVar(macro:Array<{var home:Int;var color:Int;}>, macro $v{data.players}),
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
