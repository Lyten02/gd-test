package game.ui.dash;

import game.ecs.World;
import game.ecs.components.DashRunner;
import game.ui.mvp.IPresenter;
import haxe.DynamicAccess;
import loc.text.I18n;

/** Reads the world and fills the dash HUD model; the view only renders strings. */
class DashHudPresenter implements IPresenter {
	public var model(default, null):DashHudModel;
	var view:DashHudView;
	var world:World;

	public function new(view:DashHudView, world:World) {
		this.view = view;
		this.world = world;
		this.model = new DashHudModel();
	}

	public function update(dt:Float):Void {
		model.title = I18n.t("ui.dash.title");
		model.hint = I18n.t("ui.dash.hint");
		var runners = world.query(DashRunner);
		if (runners.length > 0) {
			var r = runners[0].get(DashRunner);
			model.stats = I18n.t("ui.dash.stats", statsArgs(r));
			model.status = statusFor(r);
		}
		view.render(model);
	}

	public function dispose():Void {}

	static function statsArgs(r:DashRunner):DynamicAccess<String> {
		var args = new DynamicAccess<String>();
		args.set("attempt", Std.string(r.attempt));
		args.set("progress", Std.string(Std.int(r.progress)));
		args.set("speed", Std.string(Std.int(r.speed)));
		return args;
	}

	static function statusFor(r:DashRunner):String {
		if (r.dead) return I18n.t("ui.dash.status.dead");
		if (r.finished) return I18n.t("ui.dash.status.finished");
		return r.gravityDir < 0 ? I18n.t("ui.dash.status.inverted") : I18n.t("ui.dash.status.running");
	}
}
