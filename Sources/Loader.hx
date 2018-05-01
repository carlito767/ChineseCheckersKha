// Inspired by: https://github.com/BlazingMammothGames/tundra

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.System;

class Loader {
  @:allow(Main)
  static var onDone:Void->Void = null;

  @:allow(Main)
  static function load() {
    System.notifyOnRender(render);
    Assets.loadEverything(function() {
      System.removeRenderListener(render);
      onDone();
    });
  }

  static var backgroundColor:Color = 0xFF2B343D;
  static var barColor:Color = 0xFF3EE8AF;

  static function render(framebuffer:Framebuffer) {
    var g = framebuffer.g2;
    g.begin(true, backgroundColor);
    var w = Assets.progress * System.windowWidth();
    var h = System.windowHeight() * 0.02;
    var y = (System.windowHeight() - h) * 0.5;
    g.color = barColor;
    g.fillRect(0, y, w, h);
    g.end();
  }
}
