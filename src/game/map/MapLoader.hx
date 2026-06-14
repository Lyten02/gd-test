package game.map;

import game.map.MapData.AutoPlayCue;
import game.map.MapData.MapEntity;

/**
 * Pure JSON → MapData parser. Throws on malformed input.
 * No engine deps → unit-testable.
 */
class MapLoader {
	public static function parse(json:String):MapData {
		var raw:Dynamic = haxe.Json.parse(json);
		if (raw == null) throw "MapLoader: empty JSON";
		if (raw.width == null || raw.height == null) throw "MapLoader: missing width/height";
		if (raw.entities == null) throw "MapLoader: missing entities array";

		var entities:Array<MapEntity> = [];
		var rawEntities:Array<Dynamic> = raw.entities;
		for (i in 0...rawEntities.length) {
			var e = rawEntities[i];
			if (e.type == null) throw 'MapLoader: entity[$i] missing "type"';
			if (e.x == null || e.y == null) throw 'MapLoader: entity[$i] missing x/y';
			entities.push({
				type:    e.type,
				x:       e.x,
				y:       e.y,
				w:       e.w,
				h:       e.h,
				r:       e.r,
				color:   e.color,
				impulse: e.impulse,
				dir:     e.dir,
				label:   e.label,
				surface: e.surface,
				stock:   e.stock,
				trash:      e.trash,
				ingredient: e.ingredient,
				station:    e.station,
				stand:      e.stand,
				serve:      e.serve,
			});
		}

		return {
			width: raw.width,
			height: raw.height,
			entities: entities,
			autoplay: parseAutoplay(raw.autoplay)
		};
	}

	static function parseAutoplay(rawAutoplay:Dynamic):Null<Array<AutoPlayCue>> {
		if (rawAutoplay == null) return null;
		var rawCues:Array<Dynamic> = rawAutoplay;
		var cues:Array<AutoPlayCue> = [];
		for (i in 0...rawCues.length) {
			var cue = rawCues[i];
			if (cue.x == null) throw 'MapLoader: autoplay[$i] missing x';
			cues.push({
				x: cue.x,
				hold: cue.hold,
				label: cue.label,
			});
		}
		return cues;
	}
}
