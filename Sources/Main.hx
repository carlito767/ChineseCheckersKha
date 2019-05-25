#if kha_html5
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
#end
import kha.System;

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

    System.start({ title:TITLE, width:WIDTH, height:HEIGHT, framebuffer:{ samplesPerPixel:4 } }, function(_) {
      Game.load();
    });
  }
}
