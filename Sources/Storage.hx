typedef StorageData = {
  var version:Int;
}

class Storage {
  static public function read<T:(StorageData)>(filename:String, ?defaults:T):Null<T> {
    var file = kha.Storage.namedFile(filename);
    var data:Null<T> = file.readObject();
    if (data == null || (defaults != null && data.version != defaults.version)) {
      return defaults;
    }
    return data;
  }

  static public function write<T:(StorageData)>(filename:String, data:T) {
    var file = kha.Storage.namedFile(filename);
    file.writeObject(data);
  }
}
