import mt.heaps.Controller;

class Boot extends hxd.App {
	public static var ME : Boot;

	public var controller : Controller;
	public var ca : ControllerAccess;

	// Boot
	static function main() {
		hxd.Res.initEmbed({compressSounds:true});

		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;

		engine.backgroundColor = 0xff<<24|0x0;

		hxd.Timer.wantedFPS = Const.FPS;
		controller = new mt.heaps.Controller(s2d);
		ca = controller.createAccess("main");

		controller.bind(A, hxd.Key.SPACE, hxd.Key.F);
		controller.bind(AXIS_LEFT_X_NEG, hxd.Key.A, hxd.Key.LEFT, hxd.Key.Q);
		controller.bind(AXIS_LEFT_X_POS, hxd.Key.D, hxd.Key.RIGHT);
		controller.bind(AXIS_LEFT_Y_POS, hxd.Key.W, hxd.Key.UP, hxd.Key.Z);
		controller.bind(AXIS_LEFT_Y_NEG, hxd.Key.S, hxd.Key.DOWN);

		Assets.init();

		// if( mt.deepnight.Lib.ludumProtection(true) ) {
			#if debug
			new Game();
			#else
			new Intro();
			#end
			#if hl
			var c = new h2d.Console(Assets.font, s2d);
			mt.deepnight.Lib.redirectTracesToH2dConsole(c);
			#end
		// }
		// else {
		// 	var t = new h2d.Text(Assets.font, s2d);
		// 	t.text = "Couldn't load data. Sorry.";
		// 	t.scale(2);
		// }

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

	override function update(delta:Float) {
		mt.heaps.Controller.beforeUpdate();

		super.update(delta);

		if( suspend>0 )
			suspend--;
		else
			mt.Process.updateAll(hxd.Timer.tmod);
	}
}

