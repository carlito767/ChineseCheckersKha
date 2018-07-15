package gato;

import kha.Storage as KhaStorage;

class Storage {
  public static function read(filename:String):Dynamic {
    var file = KhaStorage.namedFile(filename);
    return file.readObject();
  }

  public static function write(filename:String, object:Dynamic) {
    var file = KhaStorage.namedFile(filename);
    file.writeObject(object);
  }
}
