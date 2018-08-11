import gato.input.Keymap;

class Scene {
  var keymap:Keymap;

  public function new() {
    keymap = new Keymap();
  }

  public function update():Void {
    Commands.call(keymap.commands());
  }

  public function render(ui:UI):Void {
  }
}
