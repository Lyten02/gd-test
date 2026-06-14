package game.systems;

import game.ecs.World;
import game.ecs.components.DashRunner;
import game.ecs.components.Velocity;
import game.input.GameAction;
import game.input.InputBindings;

/** Converts action input into auto-run gravity and jumps. */
class DashControlSystem implements ISystem {
	var input:InputBindings;

	public function new(input:InputBindings) {
		this.input = input;
	}

	public function update(world:World, dt:Float):Void {
		var pressed = input.wasPressed(GameAction.Jump);
		var held = input.isDown(GameAction.Jump);
		for (e in world.query(DashRunner)) {
			var runner = e.get(DashRunner);
			var vel = e.get(Velocity);
			runner.jumpPressed = pressed;
			runner.jumpHeld = held;
			if (vel == null) continue;
			if (runner.dead || runner.finished) {
				vel.v.set(0, 0);
				continue;
			}

			runner.runTime += dt;
			vel.v.x = runner.speed;
			vel.v.y += runner.gravity * runner.gravityDir * dt;
			limitFall(runner, vel);
			if ((pressed || held) && runner.onGround) launch(runner, vel, runner.jumpImpulse);
		}
	}

	static inline function launch(runner:DashRunner, vel:Velocity, impulse:Float):Void {
		vel.v.y = -impulse * runner.gravityDir;
		runner.onGround = false;
	}

	static inline function limitFall(runner:DashRunner, vel:Velocity):Void {
		var fall = vel.v.y * runner.gravityDir;
		if (fall > runner.terminalVelocity) vel.v.y = runner.terminalVelocity * runner.gravityDir;
	}
}
