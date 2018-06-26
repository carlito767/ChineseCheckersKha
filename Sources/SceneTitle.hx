import kha.Assets;

import Commands.InputContext;
import Translations.language;
import Translations.tr;

class SceneTitle implements IScene {
  var context:InputContext;

  public function new() {
    context = new InputContext();
    context.set(VirtualKey.L, "ChangeLanguage");
    context.set(VirtualKey.Decimal, "ShowHitbox");
    context.set(VirtualKey.Number1, "QuickLoad1");
    context.set(VirtualKey.Number2, "QuickLoad2");
    context.set(VirtualKey.Number3, "QuickLoad3");
  }

  public function enter() {
  }

  public function leave() {
  }

  public function update() {
    Commands.update(context);
  }

  public function render(ui:UI) {
    ui.image({ image:Assets.images.BackgroundTitle, x:0, y:0, w:Game.WIDTH, h:Game.HEIGHT, disabled:true });

    ui.title({ text:tr.title1, x:Game.WIDTH * 0.45, y:Game.HEIGHT * 0.13, w:0, h:Game.HEIGHT * 0.167, disabled:true });
    ui.title({ text:tr.title2, x:Game.WIDTH * 0.48, y:Game.HEIGHT * 0.3, w:0, h:Game.HEIGHT * 0.167, disabled:true });

    if (ui.button({ text:tr.newGame, x:Game.WIDTH * 0.63, y:Game.HEIGHT * 0.58, w:Game.WIDTH * 0.38, h:Game.HEIGHT * 0.08 }).hit) {
      Game.scene = 'play';
    }
    if (ui.button({ text:'${tr.language} ${language.toUpperCase()}', x:Game.WIDTH * 0.63, y:Game.HEIGHT * 0.7, w:Game.WIDTH * 0.38, h:Game.HEIGHT * 0.08 }).hit) {
      Game.changeLanguage();
    }
  }
}
