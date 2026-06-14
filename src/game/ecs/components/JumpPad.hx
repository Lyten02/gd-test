package game.ecs.components;

/** Auto-bounce trigger placed on the track. */
class JumpPad implements Component {
	public var impulse:Float;

	public function new(impulse:Float = 820) {
		this.impulse = impulse;
	}
}
