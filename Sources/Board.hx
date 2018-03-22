import kha.Color;

typedef RawPlayer = {
  var home:Int;
  var color:Color;
}

typedef RawMode = {
  var id:String;
  var order:Array<Int>;
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
