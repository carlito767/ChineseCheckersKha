import gato.Storage;

import types.State;

class Commands {
  public static function changeLanguage() {
    Translations.language = (Translations.language == 'en') ? 'fr' : 'en';
    Settings.language = Translations.language;
    Settings.save();
  }

  public static function quickLoad(id:Int) {
    var gamesave:Null<State> = Storage.read('gamesave$id');
    if (gamesave == null || gamesave.version != Board.GAMESAVE_VERSION) {
      return;
    }

    trace('Quick Load $id');
    Game.state = gamesave;
    Game.scene = Game.scenePlay;
  }

  public static function quickSave(id:Int) {
    if (Board.isRunning(Game.state)) {
      trace('Quick Save $id');
      Storage.write('gamesave$id', Game.state);
    }
  }

  public static function toggleHitbox() {
    UI.showHitbox = !UI.showHitbox;
  }

  public static function toggleTileId() {
    Settings.showTileId = !Settings.showTileId;
  }

  public static function undo() {
    if (Board.isRunning(Game.state)) {
      Board.cancelLastMove(Game.state);
    }
  }
}
