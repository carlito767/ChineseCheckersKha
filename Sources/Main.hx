// TODO: Full screen mode
// TODO: Saveslots
// TODO: UI refresh
// TODO: Android target
// TODO: Windows target
// TODO: AI
// TODO: Online

#if kha_html5
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
#end
import kha.System;

import Game;
import Loader;

class Main {
  // Developer Mode
  static public var DEVMODE = false;

  static public function main() {
    #if kha_html5
    var resize = function() {
      var canvas = cast(document.getElementById('khanvas'), CanvasElement);
      canvas.width = Std.int(window.innerWidth * window.devicePixelRatio);
      canvas.height = Std.int(window.innerHeight * window.devicePixelRatio);
      canvas.style.width = document.documentElement.clientWidth + 'px';
      canvas.style.height = document.documentElement.clientHeight + 'px';
    }
    window.onresize = resize;
    resize();
    #end

    System.init({ title:Game.TITLE, width:Game.WIDTH, height:Game.HEIGHT, samplesPerPixel:4 }, Loader.init);
  }
}
