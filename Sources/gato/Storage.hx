package gato;

import haxe.Json;
import kha.Assets;
import kha.Storage as KhaStorage;

class Storage {

  //
  // Local Storage
  //

  public static function load(filename:String):Dynamic {
    var file = KhaStorage.namedFile(filename);
    return file.readObject();
  }

  public static function save(filename:String, data:Dynamic):Void {
    var file = KhaStorage.namedFile(filename);
    file.writeObject(data);
  }

  //
  // JSON (Assets)
  //

  public static function loadJson(filename:String):Dynamic {
    var data = null;
    var blob = Assets.blobs.get(normalize(filename));
    if (blob != null) {
      try {
        data = haxe.Json.parse(blob.toString());
      }
      catch (e:Dynamic) {
        trace('Parsing error: $e');
      }
    }
    return data;
  }

  static function normalize(filename:String):String {
    return StringTools.replace(filename, '.', '_');
  }
}
