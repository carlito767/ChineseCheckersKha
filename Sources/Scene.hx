import gato.Keymapper;
import gato.Keymapper.Keymap;

class Scene {
  var id:String;
  var keymap:Keymap = new Keymap();

  public function new() {
    id = Type.getClassName(Type.getClass(this));
  }

  public function enter():Void {
    Keymapper.keymaps.set(id, keymap);
  }
  public function leave():Void {
    Keymapper.keymaps.remove(id);
  }

  public function update():Void {
  }
  public function render(ui:UI):Void {
  }
}
