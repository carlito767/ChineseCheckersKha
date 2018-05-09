import kha.input.KeyCode;

import Signal.Signal0;

class ScenePlay implements IScene {
  var game:Game;

  // Signals
  var signalCancelMove = new Signal0();
  var signalKind = new Signal0();
  var signalPause = new Signal0();
  var signalTileId = new Signal0();

  public function new(game:Game) {
    this.game = game;

    Input.commands.push({ keys:[KeyCode.Backspace], signal:signalCancelMove });
    Input.commands.push({ keys:[KeyCode.K], signal:signalKind });
    Input.commands.push({ keys:[KeyCode.P], signal:signalPause });
    Input.commands.push({ keys:[KeyCode.Numpad0], signal:signalTileId });
  }

  public function enter() {
    signalCancelMove.connect(slotCancelMove);
    signalKind.connect(slotKind);
    signalPause.connect(slotPause);
    signalTileId.connect(slotTileId);
  }

  public function leave() {
    signalCancelMove.disconnect();
    signalKind.disconnect();
    signalPause.disconnect();
    signalTileId.disconnect();
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
