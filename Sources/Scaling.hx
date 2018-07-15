import kha.System;

class Scaling {
  static public var scale(default, null):Float = 1.0;
  static public var dx(default, null):Float = 0.0;
  static public var dy(default, null):Float = 0.0;

  static public function update(gameWidth:Int, gameHeight:Int) {
    var width = System.windowWidth();
    var height = System.windowHeight();

    var gameAspectRatio = gameWidth / gameHeight;
    var screenAspectRatio = width / height;
    var scaleHorizontal = width / gameWidth;
    var scaleVertical = height / gameHeight;

    scale = (gameAspectRatio > screenAspectRatio) ? scaleHorizontal : scaleVertical;
    dx = (width - (gameWidth * scale)) * 0.5;
    dy = (height - (gameHeight * scale)) * 0.5;
  }
}
