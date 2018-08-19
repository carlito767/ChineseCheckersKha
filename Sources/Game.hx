import kha.Assets;
import kha.Framebuffer;
import kha.graphics2.Graphics as Graphics2;
import kha.graphics4.Graphics as Graphics4;

import gato.Scaling;
import gato.input.Input;

class Game {
  public static inline var TITLE = 'ChineseCheckersKha';
  public static inline var WIDTH = 800;
  public static inline var HEIGHT = 600;

  public static var g2(default, null):Graphics2 = null;
  public static var g4(default, null):Graphics4 = null;

  public static var settings:Settings;

  public static var gamesave:Gamesave;

  public static var scene:Scene;
  public static var sceneTitle:SceneTitle;
  public static var scenePlay:ScenePlay;

  static var ui:UI;

  @:allow(Main)
  static function initialize():Void {
    settings = new Settings();
    settings.load();
    Translations.language = settings.language;

    gamesave = new Gamesave();

    sceneTitle = new SceneTitle();
    scenePlay = new ScenePlay();
    scene = sceneTitle;

    ui = new UI();

    Input.initialize();
  }

  @:allow(Main)
  static function update() {
    scene.update();
  }

  @:allow(Main)
  static function render(framebuffers:Array<Framebuffer>):Void {
    g2 = framebuffers[0].g2;
    g4 = framebuffers[0].g4;

    Scaling.update(WIDTH, HEIGHT);

    g2.begin();
    g2.scissor(Std.int(Scaling.dx), Std.int(Scaling.dy), Std.int(WIDTH * Scaling.scale), Std.int(HEIGHT * Scaling.scale));

    ui.g = g2;
    ui.begin();
    scene.render(ui);
    ui.end();
  
    g2.disableScissor();
    g2.end();
  }
}
