typedef StorageData = {
  var version:Int;
}

class Storage {
  static public function read<T:(StorageData)>(filename:String, defaults:T):T {
    var file = kha.Storage.namedFile(filename);
    var data:Null<T> = file.readObject();
    if (data == null || data.version != defaults.version) {
      return defaults;
    }
    return data;
  }

  static public function save<T:(StorageData)>(filename:String, data:T) {
    var file = kha.Storage.namedFile(filename);
    file.writeObject(data);
  }
}
