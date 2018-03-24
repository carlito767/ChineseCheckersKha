typedef Translation = {
  var play:String;
  var quit:String;
  var title1:String;
  var title2:String;
}

class Translations {
  static public function tr(id:String):String {
    var value:Null<String> = Reflect.field(translation, id);
    return (value == null) ? id : value;
  }

  static public var language(default, set):String;

  static function set_language(iso) {
    translation = switch(iso) {
      case 'fr': {
        play:'Jouer',
        quit:'Quitter',
        title1:'Dames',
        title2:'Chinoises',
      }
      default: {
        play:'Play',
        quit:'Quit',
        title1:'Chinese',
        title2:'Checkers',
      }
    }
    return language = iso;
  }

  static var translation:Translation;
}
