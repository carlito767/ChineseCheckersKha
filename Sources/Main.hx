// TODO: Loader
// TODO: Full screen mode
// TODO: Cancel last move
// TODO: Saveslots
// TODO: Formating functions
// TODO: UI refresh
// TODO: AI
// TODO: Android target
// TODO: Windows target
// TODO: Debugging tools
// TODO: Performance check (HTML5)

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

    System.init({ title:Game.TITLE, width:Game.WIDTH, height:Game.HEIGHT, samplesPerPixel:4 }, function() {
      #if debug
      var message:String = '*** Debug Mode ***';
      #if kha_html5
      js.Browser.console.info(message); 
      #else
      trace(message);
      #end
      #end
      Assets.loadEverything(function() {
        var game = new Game();
        Scheduler.addTimeTask(game.update, 0, 1 / 60);
        System.notifyOnRender(game.render);
      });
    });
  }
}
