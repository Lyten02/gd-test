package game.systems;

import game.core.AABB;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.DashRunner;
import game.ecs.components.FinishLine;
import game.ecs.components.GravityPortal;
import game.ecs.components.Hazard;
import game.ecs.components.JumpOrb;
import game.ecs.components.JumpPad;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;

/** Pure dash-platformer physics, solid landing, lethal triggers and level progress. */
class DashPhysicsSystem implements ISystem {
	public var boundsW:Float = 1920;
	public var boundsH:Float = 720;

	public function new() {}

	public function update(world:World, dt:Float):Void {
		var solids = solidsOf(world);
		for (e in world.query(DashRunner)) {
			var runner = e.get(DashRunner);
			var tr = e.get(Transform);
			var col = e.get(Collider);
			var vel = e.get(Velocity);
			if (tr == null || col == null || vel == null) continue;
			if (runner.dead || runner.finished) continue;

			runner.onGround = false;
			tr.pos.x += vel.v.x * dt;
			if (resolveX(tr, col, solids, vel.v.x)) runner.crash();

			tr.pos.y += vel.v.y * dt;
			if (resolveY(tr, col, solids, vel, runner)) runner.crash();

			if (tr.pos.y < -col.h || tr.pos.y > boundsH) runner.crash();
			applyTriggers(world, e, runner, tr, col, vel);
			updateProgress(runner, tr, col);
		}
	}

	function applyTriggers(world:World, player:Entity, runner:DashRunner,
		tr:Transform, col:Collider, vel:Velocity):Void {
		for (e in world.query(Collider)) {
			if (e == player) continue;
			var tc = e.get(Collider);
			if (tc.solid) continue;
			var tt = e.get(Transform);
			if (tt == null || !overlaps(tr, col, tt, tc)) continue;

			if (e.has(Hazard)) runner.crash();
			var pad = e.get(JumpPad);
			if (pad != null) launch(runner, vel, pad.impulse);
			var orb = e.get(JumpOrb);
			if (orb != null && runner.jumpPressed && !orb.used) {
				orb.used = true;
				launch(runner, vel, orb.impulse);
			}
			var portal = e.get(GravityPortal);
			if (portal != null && runner.lastPortalId != e.id) {
				runner.gravityDir = portal.dir;
				runner.lastPortalId = e.id;
				vel.v.y = 0;
			}
			if (e.has(FinishLine)) {
				runner.finished = true;
				vel.v.set(0, 0);
				runner.progress = 100;
			}
		}
	}

	function resolveX(tr:Transform, col:Collider, solids:Array<Entity>, axisVel:Float):Bool {
		for (s in solids) {
			var st = s.get(Transform);
			var sc = s.get(Collider);
			if (!overlaps(tr, col, st, sc)) continue;
			tr.pos.x = axisVel >= 0 ? st.pos.x - col.w : st.pos.x + sc.w;
			return true;
		}
		return false;
	}

	function resolveY(tr:Transform, col:Collider, solids:Array<Entity>, vel:Velocity, runner:DashRunner):Bool {
		for (s in solids) {
			var st = s.get(Transform);
			var sc = s.get(Collider);
			if (!overlaps(tr, col, st, sc)) continue;
			var falling = vel.v.y * runner.gravityDir > 0;
			if (runner.gravityDir > 0) {
				tr.pos.y = vel.v.y >= 0 ? st.pos.y - col.h : st.pos.y + sc.h;
			} else {
				tr.pos.y = vel.v.y <= 0 ? st.pos.y + sc.h : st.pos.y - col.h;
			}
			vel.v.y = 0;
			if (falling) {
				runner.onGround = true;
				return false;
			}
			return true;
		}
		return false;
	}

	function solidsOf(world:World):Array<Entity> {
		var out = [];
		for (e in world.query(Collider)) {
			var c = e.get(Collider);
			if (c.solid && !e.has(Velocity) && e.get(Transform) != null) out.push(e);
		}
		return out;
	}

	inline function launch(runner:DashRunner, vel:Velocity, impulse:Float):Void {
		vel.v.y = -impulse * runner.gravityDir;
		runner.onGround = false;
	}

	inline function updateProgress(runner:DashRunner, tr:Transform, col:Collider):Void {
		if (runner.finished) {
			runner.progress = 100;
			return;
		}
		var p = (tr.pos.x + col.w) / boundsW * 100;
		if (p < 0) p = 0; else if (p > 100) p = 100;
		runner.progress = p;
	}

	static inline function overlaps(a:Transform, ac:Collider, b:Transform, bc:Collider):Bool {
		return AABB.overlapsRaw(a.pos.x, a.pos.y, ac.w, ac.h, b.pos.x, b.pos.y, bc.w, bc.h);
	}
}
