@:forward
abstract Settings(SettingsData) {
  static inline var SETTINGS_FILENAME = 'settings';

  public inline function new() {
    this = {
      // User settings
      language:'en',

      // Developer settings
      showTileId:false,
    }
  }

  public inline function load():Void {
    var settings:Null<SettingsData> = Storage.load(SETTINGS_FILENAME);
    if (settings != null) {
      trace('Loading settings...');
      var fields = Reflect.fields(this);
      for (field in fields) {
        var value = Reflect.field(settings, field);
        if (value != null) {
          Reflect.setField(this, field, value);
        }
      }
    }
  }

  public inline function save():Void {
    trace('Saving settings...');
    Storage.save(SETTINGS_FILENAME, this);
  }
}
