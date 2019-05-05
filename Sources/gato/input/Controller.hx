package gato.input;

interface Controller {
  public function reset():Void;
  public function dispose():Void;
  public function updateInput(input:Input):Void;
}
