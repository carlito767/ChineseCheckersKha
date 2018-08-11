package gato;

import kha.Storage as KhaStorage;

class Storage<T:(StorageObject)> {
  public var data:Null<T> = null;

  public function new() {
  }

  public function load(filename:String, version:Int) {
    var file = KhaStorage.namedFile(filename);
    data = file.readObject();
    if (data != null && data.version != version) {
      trace('Unable to load $filename: version mismatch (expected:$version, got:${data.version})');
      data = null;
    }
  }

  public function save(filename:String) {
    var file = KhaStorage.namedFile(filename);
    file.writeObject(data);
  }
}
