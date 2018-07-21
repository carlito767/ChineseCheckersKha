import kha.Assets;

import gato.VirtualKey;

import Translations.language;
import Translations.tr;

class SceneTitle extends Scene {
  public function new() {
    super();
    keymap = [
      VirtualKey.Number1 => Action('QuickLoad1'),
      VirtualKey.Number2 => Action('QuickLoad2'),
      VirtualKey.Number3 => Action('QuickLoad3'),
    ];
  }

  override public function update() {
  }

  override public function render(ui:UI) {
    ui.image({ image:Assets.images.BackgroundTitle, x:0, y:0, w:Game.WIDTH, h:Game.HEIGHT, disabled:true });

    ui.title({ text:tr.title1, x:Game.WIDTH * 0.45, y:Game.HEIGHT * 0.13, w:0, h:Game.HEIGHT * 0.167, disabled:true });
    ui.title({ text:tr.title2, x:Game.WIDTH * 0.48, y:Game.HEIGHT * 0.3, w:0, h:Game.HEIGHT * 0.167, disabled:true });

    if (ui.button({ text:tr.newGame, x:Game.WIDTH * 0.63, y:Game.HEIGHT * 0.58, w:Game.WIDTH * 0.38, h:Game.HEIGHT * 0.08 }).hit) {
      Game.scene = Game.scenePlay;
    }
    if (ui.button({ text:'${tr.language} ${language.toUpperCase()}', x:Game.WIDTH * 0.63, y:Game.HEIGHT * 0.7, w:Game.WIDTH * 0.38, h:Game.HEIGHT * 0.08 }).hit) {
      Game.changeLanguage();
    }
  }
}
