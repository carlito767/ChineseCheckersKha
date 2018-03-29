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
#end
import kha.System;

import Game;
import Loader;

class Main {
  // Developer Mode
  static public var DEVMODE = false;

  static public function main() {
    System.init({ title:Game.TITLE, width:Game.WIDTH, height:Game.HEIGHT, samplesPerPixel:4 }, Loader.init);
  }
}
