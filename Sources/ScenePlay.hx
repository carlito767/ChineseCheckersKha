import kha.input.KeyCode;

import Input.Command;
import Signal.Signal0;

class ScenePlay implements IScene {
  var game:Game;

  var commands:Array<Command>;
  var signals:Array<Signal0>;

  public function new(game:Game) {
    this.game = game;
  
    commands = [
      { keys:[KeyCode.Backspace], slot:slotCancelMove },
      { keys:[KeyCode.K], slot:slotKind },
      { keys:[KeyCode.P], slot:slotPause },
      { keys:[KeyCode.Numpad0], slot:slotTileId },
    ];

    signals = [];
  }

  public function enter() {
    for (command in commands) {
      var signal = Input.connect(command);
      signals.push(signal);
    }
  }

  public function leave() {
    for (signal in signals) {
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
