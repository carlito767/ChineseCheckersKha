import kha.System;

typedef ScalingObject = {
  var x:Float;
  var y:Float;
  var w:Float;
  var h:Float;
}

typedef ScalingData = {
  var scale:Float;
  var dx:Float;
  var dy:Float;
}

class Scaling {
  static public function scaling(gameWidth:Int, gameHeight:Int):ScalingData {
    var width = System.windowWidth();
    var height = System.windowHeight();

    var gameAspectRatio = gameWidth / gameHeight;
    var screenAspectRatio = width / height;
    var scaleHorizontal = width / gameWidth;
    var scaleVertical = height / gameHeight;

    var scale = (gameAspectRatio > screenAspectRatio) ? scaleHorizontal : scaleVertical;
    var dx = (width - (gameWidth * scale)) * 0.5;
    var dy = (height - (gameHeight * scale)) * 0.5;

    return {
      scale:scale,
      dx:dx,
      dy:dy,
    }
  }

  static public function scaleObject(sd:ScalingData, object:ScalingObject) {
    object.x = object.x * sd.scale + sd.dx;
    object.y = object.y * sd.scale + sd.dy;
    object.w = object.w * sd.scale;
    object.h = object.h * sd.scale;
  }
}
