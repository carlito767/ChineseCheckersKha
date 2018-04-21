class Storage {
  public static function read(filename:String):Dynamic {
    var file = kha.Storage.namedFile(filename);
    return file.readObject();
  }

  public static function write(filename:String, object:Dynamic) {
    var file = kha.Storage.namedFile(filename);
    file.writeObject(object);
  }
}
