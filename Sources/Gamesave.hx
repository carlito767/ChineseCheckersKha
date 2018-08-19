import gato.Storage;

@:forward(sequence, players, tiles, moves, standings, currentPlayer, allowedMoves, selectedTile)
abstract Gamesave(GamesaveData) {
  // @@TODO: reset to 1 when the game is ready
  public static inline var GAMESAVE_VERSION = 9;

  public inline function new() {
    this = {
      version:GAMESAVE_VERSION,
      sequence:[],
      players:new Map(),
      tiles:new Map(),
      moves:[],
      standings:[],
      currentPlayer:null,
      allowedMoves:[],
      selectedTile:null,
    }
  }

  public inline function load(id:Int):Bool {
    var data:Null<GamesaveData> = Storage.load('gamesave$id');
    if (data == null || data.version != this.version) {
      return false;
    }
    trace('Loading gamesave $id...');
    this = data;
    return true;
  }

  public inline function save(id:Int):Void {
    trace('Saving gamesave $id...');
    Storage.save('gamesave$id', this);
  }
}
