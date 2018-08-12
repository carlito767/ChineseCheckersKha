package gato;

import haxe.Json;

import kha.Assets;
import kha.Storage as KhaStorage;

class Storage<T:(StorageObject)> {
  public var data:Null<T> = null;
  // @@Improvement: how to check fields without model?
  public var model:Null<T> = null;

  public function new() {
  }

  function checkFields():Bool {
    if (model == null) {
      return true;
    }

    if (data == null) {
      return false;
    }

    var fields = Reflect.fields(model);
    for (field in fields) {
      var value = Reflect.field(data, field);
      if (value == null) {
        trace('Missing field ($field)');
        return false;
      }
    }

    return true;
  }

  function checkVersion(version:Null<Int>):Bool {
    if (data == null || version == null) {
      return false;
    }

    if (data.version != version) {
      trace('Version mismatch (expected:$version, got:${data.version})');
      return false;
    }

    return true;
  }

  function normalize(filename:String):String {
    return StringTools.replace(filename, '.', '_');
  }

  //
  // Local Storage
  //

  public function load(filename:String, version:Int) {
    trace('Loading $filename...');
    var file = KhaStorage.namedFile(filename);
    data = file.readObject();
    if (!checkFields() || !checkVersion(version)) {
      data = null;
    }
  }

  public function save(filename:String) {
    trace('Saving $filename...');
    var file = KhaStorage.namedFile(filename);
    file.writeObject(data);
  }

  //
  // JSON (Assets)
  //

  public function loadJson(filename:String, version:Int) {
    trace('Loading JSON $filename...');
    data = parseJson(filename);
    if (data != null) {
      if (!checkFields() || !checkVersion(version)) {
        data = null;
      }
    }
  }

  public function mergeJson(filename:String):Bool {
    trace('Merging JSON $filename...');
    if (model == null) {
      trace('Missing model');
      return false;
    }

    if (data == null) {
      trace('Missing data');
      return false;
    }

    var merge = parseJson(filename);
    if (merge == null || !checkVersion(merge.version)) {
      return false;
    }

    var n = 0;
    var fields = Reflect.fields(model);
    for (field in fields) {
      if (field == 'version') {
        continue;
      }

      var value = Reflect.field(merge, field);
      if (value != null) {
        n++;
        Reflect.setField(data, field, value);
      }
    }
    return (n > 0);
  }

  function parseJson(filename:String):Null<T> {
    var data:Null<T> = null;
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
}
