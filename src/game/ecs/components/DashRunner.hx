package game.ecs.components;

/** Runtime state and tuning for the auto-running dash cube. */
class DashRunner implements Component {
	public var speed:Float;
	public var jumpImpulse:Float;
	public var gravity:Float;
	public var terminalVelocity:Float;
	public var gravityDir:Int;
	public var onGround:Bool = false;
	public var dead:Bool = false;
	public var finished:Bool = false;
	public var progress:Float = 0;
	public var attempt:Int;
	public var runTime:Float = 0;
	public var jumpHeld:Bool = false;
	public var jumpPressed:Bool = false;
	public var lastPortalId:Int = -1;

	public function new(attempt:Int = 1, speed:Float = 360, jumpImpulse:Float = 690,
		gravity:Float = 1900, terminalVelocity:Float = 950) {
		this.attempt = attempt;
		this.speed = speed;
		this.jumpImpulse = jumpImpulse;
		this.gravity = gravity;
		this.terminalVelocity = terminalVelocity;
		this.gravityDir = 1;
	}

	public inline function crash():Void {
		if (!finished) dead = true;
	}
}
