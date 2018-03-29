// TODO: Debugging tools (including "cancel last move")
// TODO: Scaling and full screen mode
// TODO: Saveslots
// TODO: UI refresh
// TODO: Android target
// TODO: Windows target
// TODO: AI
// TODO: Online

#if kha_html5
import js.html.CanvasElement;
import js.Browser.document;
#end
import kha.System;

import Game;
import Loader;

class Main {
  // Developer Mode
  static public var DEVMODE = false;

  static public function main() {
    // https://github.com/Kode/Kha/issues/94
    #if kha_html5
    document.documentElement.style.padding = "0";
    document.documentElement.style.margin = "0";
    document.body.style.padding = "0";
    document.body.style.margin = "0";
    var canvas = cast(document.getElementById("khanvas"), CanvasElement);
    canvas.style.display = "block";
    canvas.width = Game.WIDTH;
    canvas.height = Game.HEIGHT;
    #end

    System.init({ title:Game.TITLE, width:Game.WIDTH, height:Game.HEIGHT, samplesPerPixel:4 }, Loader.init);
  }
}
