package game.states;

import game.Game;
import game.ecs.World;
import game.map.MapData;
import game.core.Grid;
import game.systems.DashControlSystem;
import game.systems.DashPhysicsSystem;
import game.systems.DashTrailSystem;
import game.systems.DashVisualSystem;
import game.systems.RenderSystem;
import game.systems.SpriteRenderSystem;

/** Bundles the dash gameplay simulation and render systems. */
class GameplaySystems {
	var control:DashControlSystem;
	var physics:DashPhysicsSystem;
	var visual:DashVisualSystem;
	var renderS:RenderSystem;
	var sprite:SpriteRenderSystem;
	var trail:DashTrailSystem;

	public function new(game:Game, worldLayer:h2d.Object, map:MapData, world:World) {
		control = new DashControlSystem(game.input);
		physics = new DashPhysicsSystem();
		physics.boundsW = Grid.cellToPx(map.width);
		physics.boundsH = Grid.cellToPx(map.height);
		visual = new DashVisualSystem();
		renderS = new RenderSystem(worldLayer);
		sprite = new SpriteRenderSystem(worldLayer);
		trail = new DashTrailSystem(worldLayer);
	}

	public inline function boundsW():Float return physics.boundsW;
	public inline function boundsH():Float return physics.boundsH;

	public function simulate(world:World, dt:Float, sdt:Float):Void {
		control.update(world, sdt);
		physics.update(world, sdt);
		visual.update(world, dt);
	}

	public function renderAll(world:World, dt:Float):Void {
		renderS.update(world, dt);
		sprite.update(world, dt);
		trail.update(world, dt);
	}
}
