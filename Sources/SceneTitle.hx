import kha.Assets;

import Translations.language;
import Translations.tr;

class SceneTitle implements IScene {
  var inputContext:InputContext;

  public function new() {
    inputContext = new InputContext();
    inputContext.map(VirtualKey.L, Game.changeLanguage);
    inputContext.map(VirtualKey.Decimal, function() { UI.showHitbox = !UI.showHitbox; });
    inputContext.map(VirtualKey.Number1, function() { Game.quickLoad(1); });
    inputContext.map(VirtualKey.Number2, function() { Game.quickLoad(2); });
    inputContext.map(VirtualKey.Number3, function() { Game.quickLoad(3); });
  }

  public function enter() {
  }

  public function leave() {
  }

  public function update() {
    inputContext.update();
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
