import Game.Keymap;

class Scene {
  var id:String;
  var keymap:Keymap = new Keymap();

  public function new() {
    id = Type.getClassName(Type.getClass(this));
  }

  public function enter():Void {
    Game.keymaps.set(id, keymap);
  }
  public function leave():Void {
    Game.keymaps.remove(id);
  }

  public function update():Void {
  }
  public function render(ui:UI):Void {
  }
}
