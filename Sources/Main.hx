package;

#if kha_html5
import js.html.CanvasElement;
import js.Browser.document;
#end
import kha.Assets;
import kha.Scheduler;
import kha.System;

import Game;

class Main {
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

    System.init({ title:Game.TITLE, width:Game.WIDTH, height:Game.HEIGHT }, function() {
      Assets.loadEverything(function() {
        Scheduler.addTimeTask(Game.update, 0, 1 / 60);
        System.notifyOnRender(Game.render);
      });
    });
  }
}
