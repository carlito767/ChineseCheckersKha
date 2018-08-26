import kha.Assets;

import gato.input.VirtualKey;

import process.ChangeLanguageProcess;

class SceneTitle extends Scene {
  public function new() {
    super();
  }

  override public function render(ui:UI):Void {
    var locale = Game.locale;

    ui.image({ image:Assets.images.BackgroundTitle, x:0, y:0, w:Game.WIDTH, h:Game.HEIGHT, disabled:true });

    ui.title({ text:locale.title1, x:Game.WIDTH * 0.45, y:Game.HEIGHT * 0.13, w:0, h:Game.HEIGHT * 0.167, disabled:true });
    ui.title({ text:locale.title2, x:Game.WIDTH * 0.48, y:Game.HEIGHT * 0.3, w:0, h:Game.HEIGHT * 0.167, disabled:true });

    if (ui.button({ text:locale.newGame, x:Game.WIDTH * 0.63, y:Game.HEIGHT * 0.58, w:Game.WIDTH * 0.38, h:Game.HEIGHT * 0.08 }).hit) {
      Game.scene = Game.scenePlay;
    }
    if (ui.button({ text:'${locale.language} ${Game.settings.language.toUpperCase()}', x:Game.WIDTH * 0.63, y:Game.HEIGHT * 0.7, w:Game.WIDTH * 0.38, h:Game.HEIGHT * 0.08 }).hit) {
      Game.processQueue.add(new ChangeLanguageProcess());
    }
  }
}
