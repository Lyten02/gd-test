package game.ui.dash;

import game.ui.mvp.IView;

/** Top-left gameplay HUD for attempt/progress/status. */
@:uiComp("dash-hud")
class DashHudView extends h2d.Flow implements h2d.domkit.Object implements IView<DashHudModel> {
	static var SRC = <dash-hud>
		<text public id="titleText"  class="dash-title"  text={""}/>
		<text public id="statsText"  class="dash-stats"  text={""}/>
		<text public id="statusText" class="dash-status" text={""}/>
		<text public id="hintText"   class="dash-hint"   text={""}/>
	</dash-hud>;

	public function new(big:h2d.Font, small:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		titleText.font = big;
		for (t in [titleText, statsText, statusText, hintText]) {
			t.font = t == titleText ? big : small;
			t.smooth = true;
		}
	}

	public function render(m:DashHudModel):Void {
		titleText.text = m.title;
		statsText.text = m.stats;
		statusText.text = m.status;
		hintText.text = m.hint;
	}
}
