package game.systems;

import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.AutoPilot;
import game.ecs.components.Collider;
import game.ecs.components.DashRunner;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;
import game.input.GameAction;
import game.input.IActionInput;

/** Converts action input into auto-run gravity and jumps. */
class DashControlSystem implements ISystem {
	var input:IActionInput;

	public function new(input:IActionInput) {
		this.input = input;
	}

	public function update(world:World, dt:Float):Void {
		var manualPressed = input != null && input.wasPressed(GameAction.Jump);
		var manualHeld = input != null && input.isDown(GameAction.Jump);
		for (e in world.query(DashRunner)) {
			var runner = e.get(DashRunner);
			var vel = e.get(Velocity);
			if (runner.dead || runner.finished) {
				runner.jumpPressed = false;
				runner.jumpHeld = false;
				if (vel != null) vel.v.set(0, 0);
				continue;
			}

			var autoPressed = advanceAutoPilot(e);
			var autoHeld = isAutoHolding(e);
			runner.jumpPressed = manualPressed || autoPressed;
			runner.jumpHeld = manualHeld || autoHeld;
			if (vel == null) continue;

			runner.runTime += dt;
			vel.v.x = runner.speed;
			vel.v.y += runner.gravity * runner.gravityDir * dt;
			limitFall(runner, vel);
			if ((runner.jumpPressed || runner.jumpHeld) && runner.onGround) launch(runner, vel, runner.jumpImpulse);
		}
	}

	static function advanceAutoPilot(e:Entity):Bool {
		var auto = e.get(AutoPilot);
		var centerX = playerCenterX(e);
		if (auto == null || !auto.enabled || centerX == null) return false;

		var pressed = false;
		while (auto.nextCue < auto.cueXs.length && centerX >= auto.cueXs[auto.nextCue]) {
			var cue = auto.nextCue;
			auto.heldUntilX = auto.cueXs[cue] + auto.holdPx[cue];
			auto.lastCueLabel = cue < auto.labels.length ? auto.labels[cue] : "";
			auto.nextCue++;
			pressed = true;
		}
		return pressed;
	}

	static function isAutoHolding(e:Entity):Bool {
		var auto = e.get(AutoPilot);
		var centerX = playerCenterX(e);
		return auto != null && auto.enabled && centerX != null && centerX < auto.heldUntilX;
	}

	static function playerCenterX(e:Entity):Null<Float> {
		var tr = e.get(Transform);
		if (tr == null) return null;
		var col = e.get(Collider);
		return tr.pos.x + (col != null ? col.w * 0.5 : 0);
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
