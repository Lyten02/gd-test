package game.systems;

import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.DashRunner;
import game.ecs.components.Transform;
import h2d.Bitmap;
import h2d.Object;
import h2d.Tile;

/** Cheap neon afterimage trail for the cube. */
class DashTrailSystem implements ISystem {
	static inline var LIFE:Float = 0.36;
	static inline var STEP:Float = 0.035;

	var root:Object;
	var bits:Array<{bmp:Bitmap, life:Float}> = [];
	var acc:Float = 0;

	public function new(root:Object) {
		this.root = root;
	}

	public function update(world:World, dt:Float):Void {
		for (i in 0...bits.length) {
			var b = bits[i];
			b.life -= dt;
			b.bmp.alpha = b.life / LIFE * 0.45;
			b.bmp.scaleX *= 0.985;
			b.bmp.scaleY *= 0.985;
		}
		var i = bits.length - 1;
		while (i >= 0) {
			if (bits[i].life <= 0) {
				bits[i].bmp.remove();
				bits.splice(i, 1);
			}
			i--;
		}

		acc += dt;
		if (acc < STEP) return;
		acc = 0;
		spawnFor(world);
	}

	function spawnFor(world:World):Void {
		for (e in world.query(DashRunner)) {
			var runner = e.get(DashRunner);
			if (runner.dead || runner.finished) return;
			var tr = e.get(Transform);
			var col = e.get(Collider);
			if (tr == null || col == null) return;
			var bmp = new Bitmap(Tile.fromColor(0x00F5FF, Std.int(col.w), Std.int(col.h), 0.45), root);
			bmp.x = tr.pos.x;
			bmp.y = tr.pos.y;
			bmp.blendMode = Add;
			bits.push({ bmp: bmp, life: LIFE });
			return;
		}
	}
}
