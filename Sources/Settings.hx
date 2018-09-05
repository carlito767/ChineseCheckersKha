import gato.Storage;

import SettingsData.DeveloperSettings;
import SettingsData.UserSettings;

@:forward
abstract Settings(SettingsData) {
  static inline var USER_SETTINGS_FILENAME = 'settings';
  static inline var DEVELOPER_SETTINGS_FILENAME_JSON = 'developer.settings.json';

  public inline function new() {
    this = {
      // User settings
      language:'en',

      // Developer settings
      showDeveloperInfos:false,
      showHitbox:false,
      showTileId:false,
    }
  }

  public inline function load():Void {
    var developerSettings:Null<DeveloperSettings> = Storage.loadJson(DEVELOPER_SETTINGS_FILENAME_JSON);
    if (developerSettings != null) {
      trace('Loading developer settings...');
      var fields = Reflect.fields(this);
      for (field in fields) {
        var value = Reflect.field(developerSettings, field);
        if (value != null) {
          Reflect.setField(this, field, value);
        }
      }
    }

    var userSettings:Null<UserSettings> = Storage.load(USER_SETTINGS_FILENAME);
    if (userSettings != null) {
      trace('Loading user settings...');
      var fields = Reflect.fields(this);
      for (field in fields) {
        var value = Reflect.field(userSettings, field);
        if (value != null) {
          Reflect.setField(this, field, value);
        }
      }
    }
  }

  public inline function save():Void {
    trace('Saving user settings...');
    var userSettings:UserSettings = {
      language:this.language,
    };
    Storage.save(USER_SETTINGS_FILENAME, userSettings);
  }
}
