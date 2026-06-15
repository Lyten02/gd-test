package game.render;

import game.ecs.components.ShapeRender.ShapeKind;
import h2d.Graphics;
import h2d.Object;

/** Builds neon h2d objects from ShapeKind while preserving top-left gameplay AABBs. */
class ShapeFactory {
	public static inline var OUTLINE_W:Float = 2;

	public static function build(kind:ShapeKind, color:Int, parent:Object,
		originX:Float = 0, originY:Float = 0):Object {
		if (originX == 0 && originY == 0) return raw(kind, color, parent);
		var wrap = new Object(parent);
		var child = raw(kind, color, wrap);
		child.x = -originX;
		child.y = -originY;
		return wrap;
	}

	static function raw(kind:ShapeKind, color:Int, parent:Object):Object {
		return switch kind {
			case Rect(w, h)        : rect(w, h, color, parent);
			case Circle(r)         : poly(c -> c.drawCircle(r, r, r), color, parent);
			case Triangle(hw, hh)  : poly(c -> triPath(c, hw * 2, hh * 2), color, parent);
			case Diamond(hw, hh)   : poly(c -> diamondPath(c, hw * 2, hh * 2), color, parent);
			case Hexagon(r)        : poly(c -> hexPath(c, r), color, parent);
		}
	}

	static function rect(w:Float, h:Float, color:Int, parent:Object):Graphics {
		var g = new Graphics(parent);
		g.lineStyle(8, color, 0.18);
		g.drawRect(0, 0, w, h);
		g.lineStyle(OUTLINE_W, boost(color, 60), 1);
		g.beginFill(color, 0.92);
		g.drawRect(0, 0, w, h);
		g.endFill();
		return g;
	}

	static function poly(draw:(Graphics)->Void, color:Int, parent:Object):Graphics {
		var g = new Graphics(parent);
		g.lineStyle(8, color, 0.18);
		draw(g);
		g.lineStyle(OUTLINE_W, boost(color, 72), 1);
		g.beginFill(color, 0.92);
		draw(g);
		g.endFill();
		return g;
	}

	static function triPath(c:Graphics, w:Float, h:Float):Void {
		c.moveTo(w * 0.5, 0);
		c.lineTo(w, h);
		c.lineTo(0, h);
		c.lineTo(w * 0.5, 0);
	}

	static function diamondPath(c:Graphics, w:Float, h:Float):Void {
		c.moveTo(w * 0.5, 0);
		c.lineTo(w, h * 0.5);
		c.lineTo(w * 0.5, h);
		c.lineTo(0, h * 0.5);
		c.lineTo(w * 0.5, 0);
	}

	static function hexPath(c:Graphics, r:Float):Void {
		var cx = r;
		var cy = r;
		for (i in 0...7) {
			var a = i * Math.PI / 3.0;
			var px = cx + Math.cos(a) * r;
			var py = cy + Math.sin(a) * r;
			if (i == 0) c.moveTo(px, py) else c.lineTo(px, py);
		}
	}

	static function boost(color:Int, delta:Int):Int {
		var r = clamp(((color >> 16) & 0xFF) + delta);
		var g = clamp(((color >> 8) & 0xFF) + delta);
		var b = clamp((color & 0xFF) + delta);
		return (r << 16) | (g << 8) | b;
	}

	static inline function clamp(v:Int):Int {
		return v < 0 ? 0 : (v > 255 ? 255 : v);
	}
}
