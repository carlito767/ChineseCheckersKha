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
      { keys:[KeyCode.Backspace], slot:cancelLastMove },
      { keys:[KeyCode.K], slot:changePlayerKind },
      { keys:[KeyCode.P], slot:pause },
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

  function cancelLastMove() {
    game.pause = true;
    Board.cancelLastMove(game.state);
  }

  function changePlayerKind() {
    if (game.state.currentPlayer != null && game.state.sequence.length == 2) {
      game.pause = true;
      game.state.currentPlayer.kind = (game.state.currentPlayer.kind == Human) ? AiEasy : Human;
    }
  }

  function pause() {
    game.pause = !game.pause;
  }
}
