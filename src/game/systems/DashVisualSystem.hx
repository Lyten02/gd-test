package game.systems;

import game.ecs.World;
import game.ecs.components.DashRunner;
import game.ecs.components.JumpOrb;
import game.ecs.components.ShapeRender;

/** Updates purely-visual rotation, pulse and fade values before RenderSystem draws. */
class DashVisualSystem implements ISystem {
	public function new() {}

	public function update(world:World, dt:Float):Void {
		for (e in world.query(DashRunner)) {
			var runner = e.get(DashRunner);
			var sr = e.get(ShapeRender);
			if (sr == null) continue;
			if (!runner.dead && !runner.finished && !runner.onGround) {
				sr.rotation += dt * 8.8 * runner.gravityDir;
			} else if (runner.onGround) {
				var quarter = Math.PI * 0.5;
				sr.rotation = Math.round(sr.rotation / quarter) * quarter;
			}
			sr.alpha = runner.dead ? 0.35 : 1;
		}

		for (e in world.query(JumpOrb)) {
			var orb = e.get(JumpOrb);
			var sr = e.get(ShapeRender);
			if (sr != null) {
				sr.alpha = orb.used ? 0.28 : 0.78 + Math.sin(haxe.Timer.stamp() * 8) * 0.2;
			}
		}
	}
}
