import gato.Storage;

@:forward
abstract Localization(LocalizationData) {
  public static inline var LOCALIZATION_DEFAULT = 'en';

  public inline function new() {
    load();
  }

  // @@TODO: check language_*.json files at compile time
  public inline function load(?id:String):String {
    var data:Null<LocalizationData> = null;
    if (id != null) {
      trace('Loading user localization ($id)...');
      data = Storage.loadJson('language_$id.json');
    }
    if (data == null) {
      id = LOCALIZATION_DEFAULT;
      trace('Loading default localization ($id)...');
      data = Storage.loadJson('language_$id.json');
    }
    this = data;
    return id;
  }
}
