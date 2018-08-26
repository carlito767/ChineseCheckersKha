package process;

import gato.Process;

class ChangeLanguageProcess implements Process {
  public var finished:Bool = false;

  public function new() {
  };

  public function update(dt:Float):Void {
    var newLanguage = (Game.settings.language == 'en') ? 'fr' : 'en';
    if (Game.locale.load(newLanguage)) {
      Game.settings.language = newLanguage;
      Game.settings.save();
    }
    finished = true;
  }
}
