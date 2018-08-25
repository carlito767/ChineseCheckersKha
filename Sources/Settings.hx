import gato.Storage;

@:forward
abstract Settings(SettingsData) {
  static inline var SETTINGS_FILENAME = 'settings';
  static inline var SETTINGS_FILENAME_JSON = 'settings.json';
  static inline var SETTINGS_VERSION = 1;

  public inline function new() {
    this = {
      version:SETTINGS_VERSION,
      language:'en',
      showTileId:false,
    }
  }

  public inline function load():Void {
    var data:Null<SettingsData> = Storage.loadJson(SETTINGS_FILENAME_JSON);
    if (data != null && check(data)) {
      trace('Loading local settings...');
      var fields = Reflect.fields(this);
      for (field in fields) {
        var value = Reflect.field(data, field);
        if (value != null) {
          Reflect.setField(this, field, value);
        }
      }
      return;
    }

    data = Storage.load(SETTINGS_FILENAME);
    if (data != null && check(data)) {
      trace('Loading user settings...');
      this = data;
    }
  }

  public inline function save():Void {
    Storage.save(SETTINGS_FILENAME, this);
  }

  function check(data:SettingsData):Bool {
    if (data.version != this.version) {
      trace('Version mismatch (expected:${this.version}, got:${data.version})');
      return false;
    }
    return true;
  }
}
