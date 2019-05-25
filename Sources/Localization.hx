@:forward
abstract Localization(LocalizationData) {
  static inline var LOCALIZATION_DEFAULT = 'en';

  public inline function new() {
    this = Storage.loadJson('language_${LOCALIZATION_DEFAULT}.json');
  }

  // TODO:[carlito 20180825] check language_*.json files at compile time
  public inline function load(id:String):Bool {
    trace('Loading localization ($id)...');
    var data:Null<LocalizationData> = Storage.loadJson('language_$id.json');
    if (data == null) {
      trace('Localization not found ($id)');
      return false;
    }
    this = data;
    return true;
  }
}
