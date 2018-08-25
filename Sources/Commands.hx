import gato.Storage;
import gato.input.Command;

class Commands {
  public static function call(commands:Array<Command>):Void {
    // @@Improvement: use strings for commands (eg: 'quickload 1' should call Commands.quickload(1))
    for (command in commands) {
      switch command {
      case Action('ChangeLanguage'):
        changeLanguage();
      case Action('ToggleHitbox'):
        toggleHitbox();
      case Action('ToggleTileId'):
        toggleTileId();
      case Action('QuickLoad1'):
        quickLoad(1);
      case Action('QuickLoad2'):
        quickLoad(2);
      case Action('QuickLoad3'):
        quickLoad(3);
      case Action('QuickSave1'):
        quickSave(1);
      case Action('QuickSave2'):
        quickSave(2);
      case Action('QuickSave3'):
        quickSave(3);
      case Action('Undo'):
        undo();
      default:
        trace('Unknown command: $command');
      }
    }
  }

  public static function changeLanguage():Void {
    Game.settings.language = (Game.settings.language == 'en') ? 'fr' : 'en';
    Game.locale.load(Game.settings.language);
    Game.settings.save();
  }

  public static function quickLoad(id:Int):Void {
    if (Game.gamesave.load(id)) {
      Game.scene = Game.scenePlay;  
    }
  }

  public static function quickSave(id:Int):Void {
    if (!Board.isRunning(Game.gamesave)) {
      return;
    }

    Game.gamesave.save(id);
  }

  public static function toggleHitbox():Void {
    UI.showHitbox = !UI.showHitbox;
  }

  public static function toggleTileId():Void {
    Game.settings.showTileId = !Game.settings.showTileId;
  }

  public static function undo():Void {
    if (Board.isRunning(Game.gamesave)) {
      Board.cancelLastMove(Game.gamesave);
    }
  }
}
