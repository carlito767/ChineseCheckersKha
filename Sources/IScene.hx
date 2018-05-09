interface IScene {
  private var game:Game;

  public function enter():Void;
  public function leave():Void;

  public function update():Void;
  public function render():Void;
}
