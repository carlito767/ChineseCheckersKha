package gato.input;

typedef InputStatus = {
  var isDown:Map<VirtualKey, Bool>;
  var wasDown:Map<VirtualKey, Bool>;
  var x:Int;
  var y:Int;
  var movementX:Int;
  var movementY:Int;
  var delta:Int;
}
