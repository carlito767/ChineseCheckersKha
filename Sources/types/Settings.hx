package types;

import gato.StorageObject;

typedef Settings = {
  > StorageObject,
  var language:String;
  var showTileId:Bool;
}
