import kha.Assets;
import kha.Color;
import kha.Font;
import kha.Image;
import kha.graphics2.Graphics;
using kha.graphics2.GraphicsExtension;

import Mui;
import Mui.MuiEval;
import Mui.MuiObject;

//
// Components
//

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