package game.map;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.map.MapData.MapEntity;
import game.ecs.components.Collider;
import game.ecs.components.DashRunner;
import game.ecs.components.FinishLine;
import game.ecs.components.GravityPortal;
import game.ecs.components.Hazard;
import game.ecs.components.JumpOrb;
import game.ecs.components.JumpPad;
import game.ecs.components.PlayerControlled;
import game.ecs.components.ShapeRender;
import game.ecs.components.ShapeRender.ShapeKind;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;

/** Spawns dash-platformer ECS entities from grid-authored map data. */
class EntityFactory {
	public static inline var BLOCK:Int = 0x1E7BFF;
	public static inline var PLAYER:Int = 0x00F5FF;
	public static inline var HAZARD:Int = 0xFF2D55;
	public static inline var PAD:Int = 0xFFE66D;
	public static inline var ORB:Int = 0xFFB000;
	public static inline var PORTAL:Int = 0xC77DFF;
	public static inline var GOAL:Int = 0x7CFF6B;

	public static function spawnAll(world:World, map:MapData, attempt:Int = 1):Void {
		for (e in map.entities) spawn(world, e, attempt);
	}

	public static function spawn(world:World, e:MapEntity, attempt:Int = 1):Entity {
		var px = Grid.cellToPx(e.x);
		var py = Grid.cellToPx(e.y);
		var cw = (e.w != null ? e.w : 1) * Grid.CELL;
		var ch = (e.h != null ? e.h : 1) * Grid.CELL;
		var cr = (e.r != null ? e.r : 1) * Grid.CELL;
		return switch e.type {
			case "player": player(world, px, py, attempt);
			case "rect": block(world, px, py, cw, ch, tint(e, BLOCK));
			case "block": block(world, px, py, cw, ch, tint(e, BLOCK));
			case "spike": spike(world, px, py, cw, ch, tint(e, HAZARD));
			case "saw": hazard(world, px, py, cr * 2, cr * 2, Circle(cr), tint(e, HAZARD));
			case "pad": pad(world, px, py, cw, ch, e.impulse, tint(e, PAD));
			case "jumpPad": pad(world, px, py, cw, ch, e.impulse, tint(e, PAD));
			case "orb": orb(world, px, py, cr, e.impulse, tint(e, ORB));
			case "jumpOrb": orb(world, px, py, cr, e.impulse, tint(e, ORB));
			case "gravityPortal": portal(world, px, py, cw, ch, e.dir, tint(e, PORTAL));
			case "goal": finish(world, px, py, cw, ch, tint(e, GOAL));
			case "decor": decor(world, px, py, cw, ch, tint(e, 0x00F5FF));
			case "circle": block(world, px, py, cr * 2, cr * 2, tint(e, BLOCK), Circle(cr));
			case "triangle": spike(world, px, py, cw, ch, tint(e, HAZARD));
			case "diamond": block(world, px, py, cw, ch, tint(e, BLOCK), Diamond(cw * 0.5, ch * 0.5));
			case "hexagon": block(world, px, py, cr * 2, cr * 2, tint(e, BLOCK), Hexagon(cr));
			default: throw 'EntityFactory: unknown type "${e.type}"';
		}
	}

	static function player(w:World, x:Float, y:Float, attempt:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Velocity());
		e.add(new Collider(Grid.CELL, Grid.CELL));
		e.add(new PlayerControlled(360));
		e.add(new DashRunner(attempt));
		e.add(new ShapeRender(Rect(Grid.CELL, Grid.CELL), PLAYER, Grid.CELL * 0.5, Grid.CELL * 0.5));
		return e;
	}

	static function block(w:World, x:Float, y:Float, cw:Float, ch:Float, color:Int,
		?kind:ShapeKind):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(cw, ch));
		e.add(new ShapeRender(kind == null ? Rect(cw, ch) : kind, color));
		return e;
	}

	static function spike(w:World, x:Float, y:Float, cw:Float, ch:Float, color:Int):Entity {
		return hazard(w, x, y, cw, ch, Triangle(cw * 0.5, ch * 0.5), color);
	}

	static function hazard(w:World, x:Float, y:Float, cw:Float, ch:Float, kind:ShapeKind, color:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(cw, ch, false));
		e.add(new Hazard());
		e.add(new ShapeRender(kind, color));
		return e;
	}

	static function pad(w:World, x:Float, y:Float, cw:Float, ch:Float, impulse:Null<Float>, color:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(cw, ch, false));
		e.add(new JumpPad(impulse != null ? impulse : 840));
		e.add(new ShapeRender(Diamond(cw * 0.5, ch * 0.5), color));
		return e;
	}

	static function orb(w:World, x:Float, y:Float, r:Float, impulse:Null<Float>, color:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(r * 2, r * 2, false));
		e.add(new JumpOrb(impulse != null ? impulse : 760));
		e.add(new ShapeRender(Circle(r), color));
		return e;
	}

	static function portal(w:World, x:Float, y:Float, cw:Float, ch:Float, dir:Null<Int>, color:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(cw, ch, false));
		e.add(new GravityPortal(dir != null ? dir : -1));
		e.add(new ShapeRender(Rect(cw, ch), color));
		return e;
	}

	static function finish(w:World, x:Float, y:Float, cw:Float, ch:Float, color:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(cw, ch, false));
		e.add(new FinishLine());
		e.add(new ShapeRender(Rect(cw, ch), color));
		return e;
	}

	static function decor(w:World, x:Float, y:Float, cw:Float, ch:Float, color:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new ShapeRender(Rect(cw, ch), color));
		return e;
	}

	static inline function tint(e:MapEntity, fallback:Int):Int {
		return e.color != null ? e.color : fallback;
	}
}
