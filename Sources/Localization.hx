class Localization {
  public static var language(get, never):String;
  static inline function get_language() {
    return languages[0];
  }

  public static var locale(get, never):LocalizationData;
  static inline function get_locale() {
    return locales[language];
  }

  static var languages:Array<String> = ['en', 'fr'];
  static var locales:Map<String, LocalizationData> = new Map();

  public static function initialize() {
    for (id in languages) {
      var data:Null<LocalizationData> = Storage.loadJson('language_$id.json');
      if (data != null) {
        locales[id] = data;
      }
    }
  }

  public static function next():Void {
    languages.push(languages.shift());
  }
}
