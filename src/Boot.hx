import mt.flash.Controller;
import mt.flash.GamePad;

class Boot extends hxd.App {
	public static var ME : Boot;
	public var buffer : h2d.CachedBitmap;

	// Boot
	static function main() {
		hxd.Res.initEmbed({compressSounds:true});

		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;

		engine.backgroundColor = 0xff<<24|0x0;

		Controller.bind(A, hxd.Key.SPACE, hxd.Key.F);
		Controller.bind(AXIS_LEFT_X_NEG, hxd.Key.A, hxd.Key.LEFT, hxd.Key.Q);
		Controller.bind(AXIS_LEFT_X_POS, hxd.Key.D, hxd.Key.RIGHT);
		Controller.bind(AXIS_LEFT_Y_POS, hxd.Key.W, hxd.Key.UP, hxd.Key.Z);
		Controller.bind(AXIS_LEFT_Y_NEG, hxd.Key.S, hxd.Key.DOWN);

		Assets.init();

		if( mt.deepnight.Lib.ludumProtection(true) ) {
			#if debug
			new Game();
			#else
			new Intro();
			#end
		}
		else {
			var t = new h2d.Text(Assets.font, s2d);
			t.text = "Couldn't load data. Sorry.";
			t.scale(2);
		}

		onResize();
	}

	override function onResize() {
		super.onResize();
		mt.Process.resizeAll();
	}

	var suspend = 0.;
	public function suspendFor(d:Float) {
		suspend = d;
	}

	override function update(dt:Float) {
		mt.flash.Controller.beforeUpdate();

		super.update(dt);
		if( suspend>0 ) {
			mt.flash.Controller.lockGlobal();
			suspend--;
		}
		else {
			mt.flash.Controller.unlockGlobal();
			mt.Process.updateAll(dt);
		}
	}
}

