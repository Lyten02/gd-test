package game.systems;

import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.DashRunner;
import game.ecs.components.FinishLine;
import game.ecs.components.GravityPortal;
import game.ecs.components.Hazard;
import game.ecs.components.JumpPad;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;
import utest.Assert;
import utest.Test;

class TestDashPhysicsSystem extends Test {
	function testLandingOnSolidSetsGround() {
		var w = new World();
		var floor = w.create();
		floor.add(new Transform(0, 40));
		floor.add(new Collider(300, 20, true));

		var runner = makeRunner(w, 0, 0);
		var dash = runner.get(DashRunner);
		var vel = runner.get(Velocity);
		var tr = runner.get(Transform);
		vel.v.set(0, 1000);

		var sys = new DashPhysicsSystem();
		sys.update(w, 1 / 60);

		Assert.isTrue(dash.onGround);
		Assert.equals(8.0, tr.pos.y);
		Assert.equals(0.0, vel.v.y);
	}

	function testHazardCrashesRunner() {
		var w = new World();
		var runner = makeRunner(w, 0, 0).get(DashRunner);
		var spike = w.create();
		spike.add(new Transform(0, 0));
		spike.add(new Collider(32, 32, false));
		spike.add(new Hazard());

		new DashPhysicsSystem().update(w, 1 / 60);

		Assert.isTrue(runner.dead);
	}

	function testJumpPadLaunchesRunner() {
		var w = new World();
		var e = makeRunner(w, 0, 0);
		var vel = e.get(Velocity);
		var pad = w.create();
		pad.add(new Transform(0, 0));
		pad.add(new Collider(32, 12, false));
		pad.add(new JumpPad(500));

		new DashPhysicsSystem().update(w, 1 / 60);

		Assert.equals(-500.0, vel.v.y);
	}

	function testGravityPortalFlipsRunner() {
		var w = new World();
		var runner = makeRunner(w, 0, 0).get(DashRunner);
		var portal = w.create();
		portal.add(new Transform(0, 0));
		portal.add(new Collider(32, 96, false));
		portal.add(new GravityPortal(-1));

		new DashPhysicsSystem().update(w, 1 / 60);

		Assert.equals(-1, runner.gravityDir);
	}

	function testFinishLineCompletesRun() {
		var w = new World();
		var runner = makeRunner(w, 0, 0).get(DashRunner);
		var goal = w.create();
		goal.add(new Transform(0, 0));
		goal.add(new Collider(32, 96, false));
		goal.add(new FinishLine());

		new DashPhysicsSystem().update(w, 1 / 60);

		Assert.isTrue(runner.finished);
		Assert.equals(100.0, runner.progress);
	}

	function makeRunner(w:World, x:Float, y:Float) {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(32, 32));
		e.add(new Velocity());
		e.add(new DashRunner());
		return e;
	}
}
