#if kha_html5
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
#end
import kha.Scheduler;
import kha.System;

import gato.Loader;

class Main {
  public static function main() {
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

    Loader.onDone = function() {
      Game.initialize();
      Scheduler.addTimeTask(Game.update, 0, 1 / 60);
      System.notifyOnFrames(Game.render);
    }
    System.start({ title:Game.TITLE, width:Game.WIDTH, height:Game.HEIGHT, framebuffer:{ samplesPerPixel:4 } }, Loader.load);
  }
}
