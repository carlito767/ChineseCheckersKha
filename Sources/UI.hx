import kha.Assets;
import kha.Color;
import kha.Font;
import kha.Image;
import kha.graphics2.Graphics;
using kha.graphics2.GraphicsExtension;

import Board.GameState;
import Board.Tile;
import Mui;
import Mui.MuiEval;
import Mui.MuiObject;

//
// Components
//

typedef Coordinates = {
  var x:Float;
  var y:Float;
}

typedef UIBoard = {
  > MuiObject,
  var state:GameState;
}

typedef UIButton = {
  > MuiObject,
  var text:String;
}

typedef UIImage = {
  > MuiObject,
  var image:Image;
}

typedef UILabel = {
  > MuiObject,
  var text:String;
  @:optional var title:Bool;
}

//
// UI
//

class UI extends Mui {
  public var graphics:Graphics;

  public function new() {
    super();
  }

  //
  // Board
  //

  var radius:Int = 16;
  var distanceX:Float = 16 * 1.25;
  var distanceY:Float = 16 * 1.25 * 1.7;
  var segments:Int = 2 * 16;

  function screenCoordinates(object:UIBoard, tile:Tile):Coordinates {
    var boardWidth:Float = ((object.state.width - 1) * distanceX) + (2 * radius);
    var boardHeight:Float = ((object.state.height - 1) * distanceY) + (2 * radius);
    var x:Float = (object.w - boardWidth) / 2;
    var y:Float = (object.h - boardHeight) / 2;
    var dx = radius + ((tile.x - 1) * distanceX);
    var dy = radius + ((tile.y - 1) * distanceY);
    return {
      x:x + dx,
      y:y + dy,
    }
  }

  public function board(object:UIBoard):MuiEval {
    var eval:MuiEval = evaluate(object);

    // Tiles
    for (tile in object.state.tiles) {
      var coordinates:Coordinates = screenCoordinates(object, tile);
      graphics.color = Color.Black;
      graphics.drawCircle(coordinates.x, coordinates.y, radius, 2, segments);
    }

    return eval;
  }

  //
  // Button
  //

  public function button(object:UIButton):MuiEval {
    var eval:MuiEval = evaluate(object);

    graphics.color = Color.fromBytes(0, 0, 0, 200);
    graphics.fillRect(object.x, object.y, object.w, object.h);

    graphics.color = Color.White;
    graphics.font = Assets.fonts.maharani;
    graphics.fontSize = 28;
    var textX = object.x + ((object.w - graphics.font.width(graphics.fontSize, object.text)) / 2);
    var textY = object.y + ((object.h - graphics.font.height(graphics.fontSize)) / 2);
    graphics.drawString(object.text, textX, textY);

    return eval;
  }

  //
  // Image
  //

  public function image(object:UIImage):MuiEval {
    var eval:MuiEval = evaluate(object);

    graphics.color = Color.White;
    graphics.drawImage(object.image, object.x, object.y);

    return eval;
  }

  //
  // Label
  //

  public function label(object:UILabel):MuiEval {
    var eval:MuiEval = evaluate(object);

    graphics.color = Color.White;
    if (object.title != null && object.title == true) {
      graphics.font = Assets.fonts.batik_gangster;
      graphics.fontSize = 100;
    }
    else {
      graphics.font = Assets.fonts.maharani;
      graphics.fontSize = 28;
    }
    graphics.drawString(object.text, object.x, object.y);

    return eval;
  }
}