class Storage {
  static public function read(filename:String):Dynamic {
    var file = kha.Storage.namedFile(filename);
    return file.readObject();
  }

  static public function write(filename:String, object:Dynamic) {
    var file = kha.Storage.namedFile(filename);
    file.writeObject(object);
  }
}
