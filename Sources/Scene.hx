import gato.input.Keymap;

class Scene {
  // @@Improvement: Game should not access to Scene fields
  @:allow(Game)
  var keymap:Keymap;

  public function new() {
    keymap = new Keymap();
  }

  public function update():Void {
  }

  public function render(ui:UI):Void {
  }
}
