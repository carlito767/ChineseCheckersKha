typedef UserSettings = {
  var language:String;
}

typedef DeveloperSettings = {
  var showDebugOverlay:Bool;
  var showHitbox:Bool;
  var showTileId:Bool;
}

typedef SettingsData = {
  > UserSettings,
  > DeveloperSettings,
}
