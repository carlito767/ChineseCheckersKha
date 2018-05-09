import kha.input.KeyCode;

import Input.Command;
import Signal.Signal0;

class ScenePlay implements IScene {
  var game:Game;

  // Signals
  var signalCancelMove = new Signal0();
  var signalKind = new Signal0();
  var signalPause = new Signal0();
  var signalTileId = new Signal0();

  var commands:Map<Signal0, Command>;

  public function new(game:Game) {
    this.game = game;
  
    commands = [
      signalCancelMove => { keys:[KeyCode.Backspace], slot:slotCancelMove },
      signalKind => { keys:[KeyCode.K], slot:slotKind },
      signalPause => { keys:[KeyCode.P], slot:slotPause },
      signalTileId => { keys:[KeyCode.Numpad0], slot:slotTileId },
    ];
  }

  public function enter() {
    for (signal in commands.keys()) {
      Input.connect(signal, commands[signal]);
    }
  }

  public function leave() {
    for (signal in commands.keys()) {
      Input.disconnect(signal);
    }
  }

  // Slots
  function slotCancelMove() {
    game.pause = true;
    Board.cancelLastMove(game.state);
  }

  function slotKind() {
    if (game.state.currentPlayer != null && game.state.sequence.length == 2) {
      game.pause = true;
      game.state.currentPlayer.kind = (game.state.currentPlayer.kind == Human) ? AiEasy : Human;
    }
  }

  function slotPause() {
    game.pause = !game.pause;
  }

  function slotTileId() {
    game.showTileId = !game.showTileId;
  }
}
