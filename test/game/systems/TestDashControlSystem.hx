package game.systems;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.AutoPilot;
import game.ecs.components.Collider;
import game.ecs.components.DashRunner;
import game.ecs.components.FinishLine;
import game.ecs.components.Hazard;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;
import utest.Assert;
import utest.Test;

class TestDashControlSystem extends Test {
	function testAutopilotCueLaunchesRunner() {
		var w = new World();
		var e = makeRunner(w, 50, 0);
		var runner = e.get(DashRunner);
		var vel = e.get(Velocity);
		e.add(new AutoPilot([66.0]));
		runner.onGround = true;

		new DashControlSystem(null).update(w, 1 / 60);

		Assert.isTrue(runner.jumpPressed);
		Assert.isFalse(runner.jumpHeld);
		Assert.equals(1, e.get(AutoPilot).nextCue);
		Assert.equals(-runner.jumpImpulse, vel.v.y);
	}

	function testAutoplayRouteFinishesWithoutInput() {
		var w = new World();
		var floor = w.create();
		floor.add(new Transform(0, Grid.cellToPx(6)));
		floor.add(new Collider(Grid.cellToPx(20), Grid.cellToPx(2)));

		var player = makeRunner(w, Grid.cellToPx(1), Grid.cellToPx(5));
		player.add(new AutoPilot([Grid.cellToPx(3)]));

		var spike = w.create();
		spike.add(new Transform(Grid.cellToPx(5), Grid.cellToPx(5)));
		spike.add(new Collider(Grid.CELL, Grid.CELL, false));
		spike.add(new Hazard());

		var goal = w.create();
		goal.add(new Transform(Grid.cellToPx(15), Grid.cellToPx(2)));
		goal.add(new Collider(Grid.CELL, Grid.cellToPx(4), false));
		goal.add(new FinishLine());

		var control = new DashControlSystem(null);
		var physics = new DashPhysicsSystem();
		physics.boundsW = Grid.cellToPx(20);
		physics.boundsH = Grid.cellToPx(8);

		var runner = player.get(DashRunner);
		for (_ in 0...600) {
			control.update(w, 1 / 60);
			physics.update(w, 1 / 60);
			if (runner.dead || runner.finished) break;
		}

		Assert.isTrue(runner.finished);
		Assert.isFalse(runner.dead);
	}

	function makeRunner(w:World, x:Float, y:Float):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(32, 32));
		e.add(new Velocity());
		e.add(new PlayerControlled());
		e.add(new DashRunner());
		return e;
	}
}
