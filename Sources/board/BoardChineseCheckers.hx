package board;

class BoardChineseCheckers {
  static public function cook():CookedBoard {
    return Board.newBoard({
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
    });
  }
}
