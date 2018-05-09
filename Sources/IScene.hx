interface IScene {
  public function enter():Void;
  public function leave():Void;

  public function update():Void;
  public function render(ui:UI):Void;
}
