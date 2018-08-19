import kha.Assets;
import kha.Color;
import kha.Font;
import kha.Image;
import kha.graphics2.Graphics as Graphics2;
using kha.graphics2.GraphicsExtension;
import kha.System;

import gato.Scaling;

import board.Player;

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

enum UITileEmphasis {
  None;
  Selectable;
  Selected;
  AllowedMove;
}

typedef UITile = {
  > MuiObject,
  var emphasis:UITileEmphasis;
  @:optional var id:String;
  @:optional var player:Player;
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

@:build(UIBuilder.build())
class UI extends Mui {
  public static var showHitbox = false;

  public var g:Graphics2;

  //
  // Scaling
  //

  function scaleObject(object:MuiObject):Void {
    object.x = object.x * Scaling.scale + Scaling.dx;
    object.y = object.y * Scaling.scale + Scaling.dy;
    object.w = object.w * Scaling.scale;
    object.h = object.h * Scaling.scale;
  }

  //
  // Formatting
  //

  public static function dimensions(window:UIWindow):Dimensions {
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

  function background<T:(MuiObject)>(object:T, ?color:Color):Void {
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

  @ui
  function button(object:UIButton):MuiEval {
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

    if (showHitbox) {
      g.color = Color.Green;
      g.drawRect(coordinates.x, coordinates.y, g.font.width(g.fontSize, object.text), g.font.height(g.fontSize));
    }
  }

  //
  // Image
  //

  @ui
  function image(object:UIImage):MuiEval {
    g.color = Color.White;
    g.drawScaledImage(object.image, object.x, object.y, object.w, object.h);
  }

  //
  // Rank
  //

  @ui
  function rank(object:UIRank):MuiEval {
    // Slot
    background(object);
    // Separator
    var sw = object.w * 0.2;
    g.drawLine(object.x + sw, object.y + 2, object.x + sw, object.y + object.h - 2, 2);
    // Rank
    g.font = Assets.fonts.StickRice;
    g.fontSize = Std.int(object.h * 0.7);
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
  }

  //
  // Tile
  //

  @ui
  function tile(object:UITile):MuiEval {
    var radius = object.h * 0.5;
    var cx = object.x + radius;
    var cy = object.y + radius;

    if (object.player != null) {
      g.color = object.player.color;
      g.fillCircle(cx, cy, radius);
    }

    if (object.emphasis == Selectable) {
      g.color = Color.Black;
      g.drawCircle(cx, cy, radius, radius * 0.1);
      var duration = 2;
      var delta = ((System.time % duration) + 1) / duration;
      var alpha = 0.7 + 0.3 * Math.cos(delta * 2 * Math.PI);
      var color = Color.White;
      g.color = Color.fromBytes(color.Rb, color.Gb, color.Bb, Std.int(alpha * 255));
      g.drawCircle(cx, cy, radius * 1.1, radius * 0.1);
    }
    else if (object.emphasis == Selected || object.emphasis == AllowedMove) {
      g.color = Color.White;
      g.drawCircle(cx, cy, radius * 1.1, radius * 0.1);
    }
    else {
      g.color = Color.Black;
      g.drawCircle(cx, cy, radius, radius * 0.1);
    }

    if (object.id != null) {
      var color = (object.player == null) ? Color.Black : object.player.color;
      g.color = Color.fromBytes(255 - color.Rb, 255 - color.Gb, 255 - color.Bb);
      g.font = Assets.fonts.StickRice;
      g.fontSize = Std.int(object.h * 0.7);
      var coordinates = centerText(object.id, object);
      g.drawString(object.id, coordinates.x, coordinates.y);
    }
  }

  //
  // Title
  //

  @ui
  function title(object:UITitle):MuiEval {
    g.color = Color.White;
    g.font = Assets.fonts.BatikGangster;
    g.fontSize = Std.int(object.h);
    g.drawString(object.text, object.x, object.y);
  }

  //
  // Window
  //

  @ui
  function window(object:UIWindow):MuiEval {
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
  }
}
