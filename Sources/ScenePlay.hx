import kha.Assets;
import kha.input.KeyCode;

import Board.Move;
import Board.Player;
import Board.Sequence;
import Board.State;
import Input.Command;
import Signal.Signal0;
import Translations.language;
import Translations.tr;
import UI.Dimensions;
import UI.UITileEmphasis;
import UI.UIWindow;

class ScenePlay implements IScene {
  var commands:Array<Command>;
  var signals:Array<Signal0>;

  public function new() {
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

  public function update() {
  }

  public function render(ui:UI) {
    var state = Game.state;
    var sequencer = Game.sequencer;

    ui.image({ image:Assets.images.BackgroundPlay, x:0, y:0, w:Game.WIDTH, h:Game.HEIGHT, disabled:true });

    // Board
    var radius = Game.HEIGHT * 0.027;
    var distanceX = radius * 1.25;
    var distanceY = radius * 1.25 * 1.7;
    var boardWidth = (Board.WIDTH - 1) * distanceX + radius * 2;
    var boardHeight = (Board.HEIGHT - 1) * distanceY + radius * 2;
    var dx = (Game.WIDTH - boardWidth) * 0.5;
    var dy = (Game.HEIGHT - boardHeight) * 0.5;
    var moves = state.allowedMoves;
    var human = Board.isRunning(state) && state.currentPlayer.kind == Human;
    for (tile in state.tiles) {
      var tx = dx + (tile.x - 1) * distanceX;
      var ty = dy + (tile.y - 1) * distanceY;
      var selectable = (moves.indexOf(tile) > -1);
      var selected = (state.selectedTile == tile);
      var emphasis:UITileEmphasis = None;
      if (human && !sequencer.busy() && selectable) {
        emphasis = (state.selectedTile == null) ? Selectable : AllowedMove;
      }
      else if (selected) {
        emphasis = Selected;
      }
      var player = (tile.piece == null) ? null : state.players[tile.piece];
      if (ui.tile({ x:tx, y:ty, w:radius * 2, h: radius * 2, emphasis:emphasis, player:player, id:(Game.showTileId) ? Std.string(tile.id) : null, disabled:!human }).hit) {
        if (tile == state.selectedTile) {
          state.selectedTile = null;
        }
        else if (state.allowedMoves.indexOf(tile) == -1) {
          state.selectedTile = null;
          if (tile.piece == state.currentPlayer.id) {
            if (Board.allowedMovesForTile(state, tile).length > 0) {
              state.selectedTile = tile;
            }
          }
        }
        else if (state.selectedTile == null) {
          state.selectedTile = tile;
        }
        else {
          Board.applyMove(state, state.selectedTile, tile);
          state.selectedTile = null;
        }
        Board.update(state);
      }
    }

    if (Board.isOver(state)) {
      var standings:Array<Player> = [];
      for (playerId in state.standings) {
        standings.push(state.players[playerId]);
      }
      // Who is the great loser?
      for (player in state.players) {
        if (state.standings.indexOf(player.id) == -1) {
          standings.push(player);
        }
      }

      var window:UIWindow = { x:Game.WIDTH * 0.2, y:Game.HEIGHT * 0.1, w:Game.WIDTH * 0.6, h:Game.HEIGHT * 0.8, title:tr('standings') };
      var dimensions:Dimensions = UI.dimensions(window);
      ui.window(window);

      var nb = standings.length;
      var h = (dimensions.height - (nb - 1) * dimensions.margin) / nb;
      var dy = (dimensions.height + dimensions.margin) / nb;
      for (i in 0...nb) {
        ui.rank({
          rank:Std.string(i+1),
          player:standings[i],
          x:dimensions.left,
          y:dimensions.top + dy * i,
          w:dimensions.width,
          h:h,
        });
      }
    }
    else if (Board.isRunning(state)) {
      if (!Game.pause && !human && !sequencer.busy()) {
        var move:Null<Move> = null;
        switch state.currentPlayer.kind {
        case AiEasy:
          move = AI.search(state);
        default:
        }
        if (move != null) {
          sequencer.push(Game.aiSelectTile, move.from, 0.3);
          sequencer.push(Game.aiMove, move, 0.3);
        }
      }
    }
    else {
      var window:UIWindow = { x:Game.WIDTH * 0.3, y:Game.HEIGHT * 0.33, w:Game.WIDTH * 0.4, h:Game.HEIGHT * 0.34, title:tr('numberOfPlayers') };
      var dimensions:Dimensions = UI.dimensions(window);
      ui.window(window);

      var sequences = Board.SEQUENCES;
      var nb = sequences.length;
      var w = (dimensions.width - (nb - 1) * dimensions.margin) / nb;
      var dx = (dimensions.width + dimensions.margin) / nb;
      for (i in 0...nb) {
        var sequence:Sequence = sequences[i];
        if (ui.button({
          text:Std.string(sequence.length),
          selected:(Game.sequenceIndex == i),
          x:dimensions.left + dx * i,
          y:dimensions.top,
          w:w,
          h:w,
        }).hit) {
          Game.sequenceIndex = i;
        }
      }

      if (ui.button({ text:tr('play'), disabled:(Game.sequenceIndex == null), x:dimensions.left, y:dimensions.bottom - Game.HEIGHT * 0.067, w:dimensions.width, h:Game.HEIGHT * 0.067 }).hit) {
        Board.start(state);
      }
    }

    if (ui.button({ text:tr('quit'), x:Game.WIDTH * 0.85, y:Game.WIDTH * 0.025, w:Game.WIDTH * 0.125, h:Game.HEIGHT * 0.067 }).hit) {
      Game.sequenceIndex = null;
      Game.scene = 'title';
    }
  }

  function cancelLastMove() {
    Game.pause = true;
    Board.cancelLastMove(Game.state);
  }

  function changePlayerKind() {
    if (Game.state.currentPlayer != null && Game.state.sequence.length == 2) {
      Game.pause = true;
      Game.state.currentPlayer.kind = (Game.state.currentPlayer.kind == Human) ? AiEasy : Human;
    }
  }

  function pause() {
    Game.pause = !Game.pause;
  }
}
