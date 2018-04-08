import kha.Assets;
import kha.Color;
import kha.Font;
import kha.Image;
import kha.graphics2.Graphics;
using kha.graphics2.GraphicsExtension;
import kha.System;

import Board.Player;
import Board.Tile;
import Mui;
import Mui.MuiEval;
import Mui.MuiInput;
import Mui.MuiObject;

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

typedef Scaling = {
  var scale:Float;
  var dx:Float;
  var dy:Float;
}

//
// Components
//

typedef UIButton = {
  > MuiObject,
  var text:String;
  @:optional var selected:Bool;
}

typedef UIImage = {
  > MuiObject,
  var image:Image;
}

typedef UIPlayer = {
  > MuiObject,
  var player:Player;
}

typedef UIRank = {
  > MuiObject,
  var rank:String;
  @:optional var player:Player;
}

typedef UITile = {
  > MuiObject,
  var emphasis:Bool;
  @:optional var player:Player;
  @:optional var info:String;
}

typedef UITitle = {
  > MuiObject,
  var text:String;
}

typedef UIWindow = {
  > MuiObject,
  @:optional var title:String;
}

//
// UI
//

class UI extends Mui {
  static public var showBoundsRectangles = false;

  var g:Graphics;
  var scaling:Scaling;

  public function new() {
    super();
  }

  public function preRender(graphics:Graphics, gameWidth:Int, gameHeight:Int, input:MuiInput) {
    g = graphics;
    scale(gameWidth, gameHeight);
    g.scissor(Std.int(scaling.dx), Std.int(scaling.dy), Std.int(gameWidth * scaling.scale), Std.int(gameHeight * scaling.scale));
    begin(input);
  }

  public function postRender() {
    end();
    g.disableScissor();
  }

  override function evaluate<T:(MuiObject)>(object:T):MuiEval {
    scaleObject(object);
    return super.evaluate(object);
  }

  //
  // Scaling
  //

  function scale(gameWidth:Int, gameHeight:Int) {
    var width = System.windowWidth();
    var height = System.windowHeight();

    var gameAspectRatio = gameWidth / gameHeight;
    var screenAspectRatio = width / height;
    var scaleHorizontal = width / gameWidth;
    var scaleVertical = height / gameHeight;

    var scale = (gameAspectRatio > screenAspectRatio) ? scaleHorizontal : scaleVertical;
    var dx = (width - (gameWidth * scale)) * 0.5;
    var dy = (height - (gameHeight * scale)) * 0.5;

    scaling = { scale:scale, dx:dx, dy:dy };
  }

  function scaleObject(object:MuiObject) {
    object.x = object.x * scaling.scale + scaling.dx;
    object.y = object.y * scaling.scale + scaling.dy;
    object.w = object.w * scaling.scale;
    object.h = object.h * scaling.scale;
  }

  //
  // Formatting
  //

  static public function dimensions(window:UIWindow):Dimensions {
    var dy = (window.title == null) ? 0 : window.h * 0.2;
    var margin = window.w * 0.05;
    var width = window.w - margin * 2;
    var height = window.h - dy - margin * 2;
    var left = window.x + margin;
    var right = left + width;
    var top = window.y + dy + margin;
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

  function center(object:MuiObject):Coordinates {
    return {
      x:object.x + object.w * 0.5,
      y:object.y + object.h * 0.5,
    }
  }

  function centerText(text:String, object:MuiObject):Coordinates {
    var w = g.font.width(g.fontSize, Std.string(text));
    var h = g.font.height(g.fontSize);
    return {
      x:object.x + (object.w - w) * 0.5,
      y:object.y + (object.h - h) * 0.5,
    }
  }

  //
  // Background
  //

  function background<T:(MuiObject)>(object:T, ?color:Color) {
    if (color == null) {
      color = Color.fromBytes(0, 0, 0, 200);
    }

    g.color = color;
    g.fillRect(object.x, object.y, object.w, object.h);

    if (object.disabled == true) {
      g.color = Color.fromBytes(128, 128, 128); // gray
    }
    else {
      g.color = Color.fromBytes(220, 20, 60); // crimson
    }
    g.drawRect(object.x + 2, object.y + 2, object.w - 4, object.h - 4);
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
    g.color = color;
    g.font = Assets.fonts.StickRice;
    g.fontSize = Std.int(object.h * 0.7);
    var coordinates = centerText(object.text, object);
    g.drawString(object.text, coordinates.x, coordinates.y);

    if (showBoundsRectangles) {
      g.color = Color.Green;
      g.drawRect(coordinates.x, coordinates.y, g.font.width(g.fontSize, object.text), g.font.height(g.fontSize));
    }

    return eval;
  }

  //
  // Image
  //

  public function image(object:UIImage):MuiEval {
    var eval:MuiEval = evaluate(object);

    g.color = Color.White;
    g.drawScaledImage(object.image, object.x, object.y, object.w, object.h);

    return eval;
  }

  //
  // Player
  //

  public function player(object:UIPlayer):MuiEval {
    var eval:MuiEval = evaluate(object);

    background(object, Color.fromBytes(0, 0, 0, 50));
    var coordinates = center(object);
    var radius = Math.min(object.w, object.h) * 0.5 * 0.7;
    g.color = object.player.color;
    g.fillCircle(coordinates.x, coordinates.y, radius);

    return eval;
  }

  //
  // Rank
  //

  public function rank(object:UIRank):MuiEval {
    var eval:MuiEval = evaluate(object);

    // Slot
    background(object);
    // Separator
    var sw = object.w * 0.2;
    g.drawLine(object.x + sw, object.y + 2, object.x + sw, object.y + object.h - 2, 2);
    // Rank
    var coordinates = centerText(object.rank, { x:object.x, y:object.y, w:sw, h:object.h });
    g.color = Color.White;
    g.drawString(object.rank, coordinates.x, coordinates.y);
    // Player
    if (object.player != null) {
      var coordinates = center(object);
      var radius = Math.min(object.w, object.h) * 0.5 * 0.7;
      g.color = object.player.color;
      g.fillCircle(coordinates.x, coordinates.y, radius);
      g.color = Color.White;
      g.drawCircle(coordinates.x, coordinates.y, radius, 2);
    }

    return eval;
  }

  //
  // Tile
  //

  public function tile(object:UITile):MuiEval {
    var eval:MuiEval = evaluate(object);

    var radius = object.h * 0.5;
    var cx = object.x + radius;
    var cy = object.y + radius;

    if (object.player != null) {
      g.color = object.player.color;
      g.fillCircle(cx, cy, radius);
    }
    g.color = Color.Black;
    g.drawCircle(cx, cy, radius, 2);

    if (object.emphasis) {
      g.color = Color.White;
      g.drawCircle(cx, cy, radius * 1.15, 2);
    }

    if (showBoundsRectangles) {
      g.color = Color.Green;
      g.drawRect(object.x, object.y, object.w, object.h);
    }

    if (object.info != null) {
      var color = (object.player == null) ? Color.Black : object.player.color;
      g.color = Color.fromBytes(255 - color.Rb, 255 - color.Gb, 255 - color.Bb);
      g.font = Assets.fonts.StickRice;
      g.fontSize = Std.int(object.h * 0.7);
      var coordinates = centerText(object.info, object);
      g.drawString(object.info, coordinates.x, coordinates.y);
    }
    return eval;
  }

  //
  // Title
  //

  public function title(object:UITitle):MuiEval {
    var eval:MuiEval = evaluate(object);

    g.color = Color.White;
    g.font = Assets.fonts.BatikGangster;
    g.fontSize = Std.int(object.h);
    g.drawString(object.text, object.x, object.y);

    return eval;
  }

  //
  // Window
  //

  public function window(object:UIWindow):MuiEval {
    var eval:MuiEval = evaluate(object);

    background(object);
    if (object.title != null) {
      var h = object.h * 0.2;
      var margin = h * 0.15;
      var title:MuiObject = { x:object.x + margin, y:object.y + margin, w:object.w - margin * 2, h:h - margin * 2 };
      g.color = Color.Purple;
      g.fillRect(title.x, title.y, title.w, title.h);
      g.font = Assets.fonts.StickRice;
      g.fontSize = Std.int(h * 0.7);
      var coordinates = centerText(object.title, title);
      g.color = Color.White;
      g.drawString(object.title, coordinates.x, coordinates.y);
    }

    return eval;
  }
}
