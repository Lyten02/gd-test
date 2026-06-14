package game.input;

/** Minimal action-input contract used by gameplay systems and pure tests. */
interface IActionInput {
	public function isDown(action:GameAction):Bool;
	public function wasPressed(action:GameAction):Bool;
}
