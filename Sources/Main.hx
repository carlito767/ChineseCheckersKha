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
  static public function main() {
    // https://github.com/Kode/Kha/issues/94
    #if kha_html5
    document.documentElement.style.padding = '0';
    document.documentElement.style.margin = '0';
    document.body.style.padding = '0';
    document.body.style.margin = '0';
    var canvas = cast(document.getElementById('khanvas'), CanvasElement);
    canvas.style.verticalAlign = 'middle';

    var resize = function() {
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
