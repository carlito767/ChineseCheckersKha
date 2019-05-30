package board;

class BoardDebug {
  static public function cook():CookedBoard {
    return Boards.cook({
      board:[
        '  2  ',
        ' * * ',
        '1 * 3',
      ],
      homes:[
        { owner:2, color:0xff000000 }, // black
        { owner:3, color:0xff008080 }, // teal
        { owner:1, color:0xff008000 }, // green
      ],
      sequences:[
        [ 1, 2, 3 ],
      ]
    });
  }
}
