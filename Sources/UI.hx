import kha.Assets;
import kha.Color;
import kha.Font;
import kha.Image;
import kha.graphics2.Graphics;
using kha.graphics2.GraphicsExtension;

import Board.Player;
import Board.State;
import Board.Tile;
import Game;
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

typedef Dimensions = {
  var margin:Float;
  var width:Float;
  var height:Float;
  var left:Float;
  var right:Float;
  var top:Float;
  var bottom:Float;
}

typedef UIBoard = {
  > MuiObject,
  var state:State;
}

typedef UIButton = {
  > MuiObject,
  var text:String;
  @:optional var selected:Bool;
}

typedef UIImage = {
  > MuiObject,
  var image:Image;
}

typedef UILabel = {
  > MuiObject,
  var text:String;
  @:optional var titleScreen:Bool;
}

typedef UIWindow = {
  > MuiObject,
  @:optional var title:String;
}

//
// UI
//

class UI extends Mui {
  public var graphics:Graphics;

  public function new() {
    super();
  }

  static public function dimensions(?window:UIWindow):Dimensions {
    if (window == null) {
      window = { x:0, y:0, w:Game.WIDTH, h:Game.HEIGHT };
    }
    var margin = window.w * 0.05;
    var width = window.w - 2 * margin;
    var height = window.h - 2 * margin;
    var left = window.x + margin;
    var right = left + width;
    var top = window.y + margin;
    var bottom = top + height;
    return {
      margin:margin,
      width:width,
      height:height,
      left:left,
      right:right,
      top:top,
      bottom:bottom,
    }
  }

  function background<T:(MuiObject)>(object:T) {
    graphics.color = Color.fromBytes(0, 0, 0, 200);
    graphics.fillRect(object.x, object.y, object.w, object.h);

    if (object.disabled == true) {
      graphics.color = Color.fromBytes(128, 128, 128); // gray
    }
    else {
      graphics.color = Color.fromBytes(220, 20, 60); // crimson
    }
    graphics.drawRect(object.x + 2, object.y + 2, object.w - 4, object.h - 4);
  }

  //
  // Board
  //

  var radius:Int = 16;
  var distanceX:Float = 16 * 1.25;
  var distanceY:Float = 16 * 1.25 * 1.7;

  function screenCoordinates(object:UIBoard, tile:Tile):Coordinates {
    var boardWidth = ((object.state.width - 1) * distanceX) + (2 * radius);
    var boardHeight = ((object.state.height - 1) * distanceY) + (2 * radius);
    var x = (object.w - boardWidth) * 0.5;
    var y = (object.h - boardHeight) * 0.5;
    var dx = radius + ((tile.x - 1) * distanceX);
    var dy = radius + ((tile.y - 1) * distanceY);
    return {
      x:x + dx,
      y:y + dy,
    }
  }

  public function board(object:UIBoard):MuiEval {
    var eval:MuiEval = evaluate(object);

    var currentPlayer:Null<Player> = Board.currentPlayer(object.state);

    // Tiles
    for (tile in object.state.tiles) {
      var coordinates:Coordinates = screenCoordinates(object, tile);
      if (tile.piece != null) {
        graphics.color = object.state.players[tile.piece].color;
        graphics.fillCircle(coordinates.x, coordinates.y, radius);
      }
      graphics.color = Color.Black;
      graphics.drawCircle(coordinates.x, coordinates.y, radius, 2);
    }

    // Current player
    if (currentPlayer != null) {
      var window:MuiObject = {x:20, y:20, w:100, h:100};
      graphics.color = Color.fromBytes(0, 0, 0, 50);
      graphics.fillRect(window.x, window.y, window.w, window.h);
      graphics.color = Color.fromBytes(220, 20, 60); // crimson
      graphics.drawRect(window.x + 2, window.y + 2, window.w - 4, window.h - 4);
      var x:Float = window.x + (window.w * 0.5);
      var y:Float = window.y + (window.h * 0.5);
      var radius:Float = Math.min(window.w, window.h) * 0.5 * 0.7;
      graphics.color = currentPlayer.color;
      graphics.fillCircle(x, y, radius);
    }

    return eval;
  }

  //
  // Button
  //

  public function button(object:UIButton):MuiEval {
    var eval:MuiEval = evaluate(object);

    background(object);

    var color:Color = Color.White;
    if (object.disabled == true) {
      color = Color.fromBytes(128, 128, 128); // gray
    }
    else if (object.selected == true) {
      color = Color.Yellow;
    }
    graphics.color = color;
    graphics.font = Assets.fonts.Wortellina;
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
    if (object.titleScreen == true) {
      graphics.font = Assets.fonts.BatikGangster;
      graphics.fontSize = 100;
    }
    else {
      graphics.font = Assets.fonts.Wortellina;
      graphics.fontSize = 28;
    }
    graphics.drawString(object.text, object.x, object.y);

    return eval;
  }

  //
  // Window
  //

  public function window(object:UIWindow):MuiEval {
    var eval:MuiEval = evaluate(object);

    background(object);
    if (object.title != null) {
      graphics.color = Color.Purple;
      var title:MuiObject = { x:object.x + 4, y:object.y + 4, w:object.w - 8, h:30 };
      graphics.fillRect(title.x, title.y, title.w, title.h);
      graphics.color = Color.White;
      graphics.font = Assets.fonts.Wortellina;
      graphics.fontSize = 26;
      var titleX = title.x + ((title.w - graphics.font.width(graphics.fontSize, object.title)) / 2);
      var titleY = title.y + ((title.h - graphics.font.height(graphics.fontSize)) / 2);
      graphics.drawString(object.title, titleX, titleY);
    }

    return eval;
  }
}