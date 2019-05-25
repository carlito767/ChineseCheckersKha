class ArrayExtension {
  public static function contains<T>(array:Array<T>, item:T):Bool {
    return array.indexOf(item) != -1;
  }
}
