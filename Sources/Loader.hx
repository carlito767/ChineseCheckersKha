import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Loader {
  public static function init() {
    System.notifyOnRender(render);
    Assets.loadEverything(function() {
      System.removeRenderListener(render);
      var game = new Game();
      Scheduler.addTimeTask(game.update, 0, 1 / 60);
      System.notifyOnRender(game.render);
    });
  }

  static function render(framebuffer:Framebuffer) {
    var g = framebuffer.g2;
    g.begin(true, 0xFF2B343D);
    var w = Assets.progress * System.windowWidth();
    var h = System.windowHeight() * 0.02;
    var y = (System.windowHeight() - h) * 0.5;
    g.color = 0xFF3EE8AF;
    g.fillRect(0, y, w, h);
    g.end();
  }
}
