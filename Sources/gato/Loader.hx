// Inspired by: https://github.com/FuzzyWuzzie/tundra

package gato;

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

  static function render(framebuffer:Framebuffer) {
    var g2 = framebuffer.g2;
    g2.begin();
    var width = Assets.progress * System.windowWidth();
    var height = System.windowHeight() * 0.02;
    var y = (System.windowHeight() - height) * 0.5;
    g2.color = Color.White;
    g2.fillRect(0, y, width, height);
    g2.end();
  }
}
