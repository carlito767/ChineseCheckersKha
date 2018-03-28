import kha.Assets;
import kha.Color;
import kha.Font;
import kha.Image;
import kha.graphics2.Graphics;
using kha.graphics2.GraphicsExtension;

import Board.Player;
import Board.State;
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
  var selectedTile:Null<Tile>;
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

typedef UIRank = {
  > MuiObject,
  var rank:String;
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

class UI extends Mui {
  public var g:Graphics;

  public function new() {
    super();
  }

  //
  // Formatting
  //

  static public function dimensions(window:UIWindow):Dimensions {
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

  function background<T:(MuiObject)>(object:T) {
    g.color = Color.fromBytes(0, 0, 0, 200);
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
  // Board
  //

  var radius = 16;
  var distanceX = 16 * 1.25;
  var distanceY = 16 * 1.25 * 1.7;

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

  function drawSelection(board:UIBoard, tile:Tile) {
    var coordinates:Coordinates = screenCoordinates(board, tile);
    g.color = Color.White;
    g.drawCircle(coordinates.x, coordinates.y, radius * 1.15, 2);
  }

  public function screenTile(board:UIBoard):Null<Tile> {
    for (tile in board.state.tiles) {
      var coordinates:Coordinates = screenCoordinates(board, tile);
      var okX = (x >= coordinates.x - radius) && (x <= coordinates.x + radius);
      var okY = (y >= coordinates.y - radius) && (y <= coordinates.y + radius);
      if (okX && okY) {
        return tile;
      }
    }
    return null;
  }

  public function board(object:UIBoard):MuiEval {
    var eval:MuiEval = evaluate(object);

    var currentPlayer:Null<Player> = Board.currentPlayer(object.state);

    // Tiles
    for (tile in object.state.tiles) {
      var coordinates:Coordinates = screenCoordinates(object, tile);
      if (tile.piece != null) {
        g.color = object.state.players[tile.piece].color;
        g.fillCircle(coordinates.x, coordinates.y, radius);
      }
      g.color = Color.Black;
      g.drawCircle(coordinates.x, coordinates.y, radius, 2);
    }

    // Selected Tile
    if (object.selectedTile != null) {
      drawSelection(object, object.selectedTile);
      for (move in Board.allowedMoves(object.state, object.selectedTile)) {
        drawSelection(object, move);
      }
    }

    // Current player
    if (currentPlayer != null) {
      var window:MuiObject = {x:20, y:20, w:100, h:100};
      g.color = Color.fromBytes(0, 0, 0, 50);
      g.fillRect(window.x, window.y, window.w, window.h);
      g.color = Color.fromBytes(220, 20, 60); // crimson
      g.drawRect(window.x + 2, window.y + 2, window.w - 4, window.h - 4);
      var x = window.x + (window.w * 0.5);
      var y = window.y + (window.h * 0.5);
      var radius = Math.min(window.w, window.h) * 0.5 * 0.7;
      g.color = currentPlayer.color;
      g.fillCircle(x, y, radius);
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
    g.color = color;
    g.font = Assets.fonts.Wortellina;
    g.fontSize = 28;
    var textX = object.x + ((object.w - g.font.width(g.fontSize, object.text)) * 0.5);
    var textY = object.y + ((object.h - g.font.height(g.fontSize)) * 0.5);
    g.drawString(object.text, textX, textY);

    return eval;
  }

  //
  // Image
  //

  public function image(object:UIImage):MuiEval {
    var eval:MuiEval = evaluate(object);

    g.color = Color.White;
    g.drawImage(object.image, object.x, object.y);

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
    g.color = Color.White;
    var coordinates = centerText(object.rank, { x:object.x, y:object.y, w:sw, h:object.h });
    g.drawString(object.rank, coordinates.x, coordinates.y);
    // Player
    if (object.player != null) {
      var px = object.x + object.w * 0.5;
      var py = object.y + object.h * 0.5;
      g.color = object.player.color;
      g.fillCircle(px, py, radius);
      g.color = Color.White;
      g.drawCircle(px, py, radius, 2);
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
    g.fontSize = 100;
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
      g.color = Color.Purple;
      var title:MuiObject = { x:object.x + 4, y:object.y + 4, w:object.w - 8, h:30 };
      g.fillRect(title.x, title.y, title.w, title.h);
      g.color = Color.White;
      g.font = Assets.fonts.Wortellina;
      g.fontSize = 26;
      var titleX = title.x + ((title.w - g.font.width(g.fontSize, object.title)) * 0.5);
      var titleY = title.y + ((title.h - g.font.height(g.fontSize)) * 0.5);
      g.drawString(object.title, titleX, titleY);
    }

    return eval;
  }
}
