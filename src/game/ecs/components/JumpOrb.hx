package game.ecs.components;

/** Tap-activated air orb. Each orb can be used once per attempt. */
class JumpOrb implements Component {
	public var impulse:Float;
	public var used:Bool = false;

	public function new(impulse:Float = 760) {
		this.impulse = impulse;
	}
}
