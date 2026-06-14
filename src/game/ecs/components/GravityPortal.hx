package game.ecs.components;

/** Flips gravity: dir=1 falls down, dir=-1 falls up. */
class GravityPortal implements Component {
	public var dir:Int;

	public function new(dir:Int) {
		this.dir = dir < 0 ? -1 : 1;
	}
}
