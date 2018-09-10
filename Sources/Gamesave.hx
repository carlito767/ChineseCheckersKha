import gato.Storage;

@:forward
abstract Gamesave(GamesaveData) {
  static inline var GAMESAVE_FILENAME = 'gamesave';
  // TODO:[carlito 20180819] reset to 1 when the game is ready
  static inline var GAMESAVE_VERSION = 10;

  public inline function new() {
    this = {
      version:GAMESAVE_VERSION,
      sequence:[],
      players:new Map(),
      tiles:new Map(),
      moves:[],
      standings:[],
      currentPlayerId:null,
      selectedTile:null,
    }
  }

  public inline function load(id:Int):Bool {
    var data:Null<GamesaveData> = Storage.load('$GAMESAVE_FILENAME$id');
    if (data == null || data.version != this.version) {
      return false;
    }
    trace('Loading gamesave $id...');
    this = data;
    return true;
  }

  public inline function save(id:Int):Void {
    trace('Saving gamesave $id...');
    Storage.save('$GAMESAVE_FILENAME$id', this);
  }
}
