typedef UserSettings = {
  var language:String;
}

typedef DeveloperSettings = {
  var showFPS:Bool;
  var showHitbox:Bool;
  var showTileId:Bool;
}

typedef SettingsData = {
  > UserSettings,
  > DeveloperSettings,
}
