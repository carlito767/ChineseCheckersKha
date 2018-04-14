class Storage {
  static public function read<T>(filename:String, ?defaults:T):Null<T> {
    var file = kha.Storage.namedFile(filename);
    var data:Null<T> = file.readObject();
    if (data == null && defaults != null) {
      return defaults;
    }
    return data;
  }

  static public function write<T>(filename:String, data:T) {
    var file = kha.Storage.namedFile(filename);
    file.writeObject(data);
  }
}
