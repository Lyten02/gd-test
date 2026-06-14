package game.render;

import h2d.Graphics;
import h2d.Object;

/** Deterministic neon world backdrop: gradient bands, grid, stars and skyline. */
class DashBackdrop {
	public static function build(parent:Object, worldW:Float, worldH:Float):Object {
		var root = new Object(parent);
		var g = new Graphics(root);
		drawGradient(g, worldW, worldH);
		drawGrid(g, worldW, worldH);
		drawStars(g, worldW, worldH);
		drawSkyline(g, worldW, worldH);
		return root;
	}

	static function drawGradient(g:Graphics, w:Float, h:Float):Void {
		var bands = 18;
		for (i in 0...bands) {
			var t = i / (bands - 1);
			var c = blend(0x060019, 0x180044, t);
			g.beginFill(c, 1);
			g.drawRect(0, h * i / bands, w, h / bands + 2);
			g.endFill();
		}
	}

	static function drawGrid(g:Graphics, w:Float, h:Float):Void {
		g.lineStyle(1, 0x245BFF, 0.18);
		var x = 0.0;
		while (x <= w) { g.moveTo(x, 0); g.lineTo(x, h); x += 32; }
		var y = 0.0;
		while (y <= h) { g.moveTo(0, y); g.lineTo(w, y); y += 32; }
		g.lineStyle(2, 0x00F5FF, 0.18);
		g.moveTo(0, h - 96);
		g.lineTo(w, h - 96);
	}

	static function drawStars(g:Graphics, w:Float, h:Float):Void {
		for (i in 0...150) {
			var x = (i * 197 % Std.int(w));
			var y = (i * 83 % Std.int(h * 0.62));
			var r = 1 + (i % 3) * 0.55;
			g.beginFill(i % 4 == 0 ? 0xFF4DFF : 0x00F5FF, 0.25 + (i % 5) * 0.08);
			g.drawCircle(x, y, r);
			g.endFill();
		}
	}

	static function drawSkyline(g:Graphics, w:Float, h:Float):Void {
		var x = 0.0;
		var i = 0;
		while (x < w) {
			var bw = 60 + (i * 37 % 80);
			var bh = 70 + (i * 53 % 190);
			g.beginFill(0x050011, 0.58);
			g.drawRect(x, h - 96 - bh, bw, bh);
			g.endFill();
			g.lineStyle(2, i % 2 == 0 ? 0xFF2D95 : 0x00F5FF, 0.18);
			g.drawRect(x, h - 96 - bh, bw, bh);
			x += bw + 18;
			i++;
		}
	}

	static function blend(a:Int, b:Int, t:Float):Int {
		var ar = (a >> 16) & 0xFF, ag = (a >> 8) & 0xFF, ab = a & 0xFF;
		var br = (b >> 16) & 0xFF, bg = (b >> 8) & 0xFF, bb = b & 0xFF;
		var r = Std.int(ar + (br - ar) * t);
		var g = Std.int(ag + (bg - ag) * t);
		var bl = Std.int(ab + (bb - ab) * t);
		return (r << 16) | (g << 8) | bl;
	}
}
