typedef UserSettings = {
  var language:String;
}

typedef DeveloperSettings = {
  var showDeveloperInfos:Bool;
  var showHitbox:Bool;
  var showTileId:Bool;
}

typedef SettingsData = {
  > UserSettings,
  > DeveloperSettings,
}
