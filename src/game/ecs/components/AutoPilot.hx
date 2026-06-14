package game.ecs.components;

/** Data-only replay bot: authored cue x-positions that press/hold jump. */
class AutoPilot implements Component {
	public var cueXs:Array<Float>;
	public var holdPx:Array<Float>;
	public var labels:Array<String>;
	public var nextCue:Int = 0;
	public var heldUntilX:Float = -1;
	public var enabled:Bool = true;
	public var lastCueLabel:String = "";

	public function new(cueXs:Array<Float>, ?holdPx:Array<Float>, ?labels:Array<String>) {
		this.cueXs = cueXs.copy();
		this.holdPx = holdPx != null ? holdPx.copy() : zeros(cueXs.length);
		this.labels = labels != null ? labels.copy() : emptyLabels(cueXs.length);
	}

	public inline function remainingCues():Int {
		return cueXs.length - nextCue;
	}

	static function zeros(count:Int):Array<Float> {
		var out = [];
		for (_ in 0...count) out.push(0.0);
		return out;
	}

	static function emptyLabels(count:Int):Array<String> {
		var out = [];
		for (_ in 0...count) out.push("");
		return out;
	}
}
