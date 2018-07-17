package gato;

import gato.VirtualKey;

typedef Keymap = Map<VirtualKey, String>;

class Keymapper {
  public static var keymaps:Map<String, Keymap> = new Map();
}
