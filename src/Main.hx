import dn.heaps.Controller;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : Controller;
	public var ca : ControllerAccess;

    public function new(wrapper:h2d.Object) {
        super();

        ME = this;
        createRoot(wrapper);
		root.filter = new h2d.filter.Nothing(); // force rendering for pixel perfect

		engine.backgroundColor = 0xff<<24|0x0;
		hxd.Timer.wantedFPS = Const.FPS;

		#if !js
		var f = new dn.heaps.filter.OverlayTexture(Soft);
		f.alpha = 0.2;
		f.autoUpdateSize = ()->Const.UPSCALE;
		Boot.ME.s2d.filter = f;
		#end

		controller = new dn.heaps.Controller(Boot.ME.s2d);
		ca = controller.createAccess("main");
		controller.bind(A, hxd.Key.SPACE, hxd.Key.F);
		controller.bind(AXIS_LEFT_X_NEG, hxd.Key.A, hxd.Key.LEFT, hxd.Key.Q);
		controller.bind(AXIS_LEFT_X_POS, hxd.Key.D, hxd.Key.RIGHT);
		controller.bind(AXIS_LEFT_Y_POS, hxd.Key.W, hxd.Key.UP, hxd.Key.Z);
		controller.bind(AXIS_LEFT_Y_NEG, hxd.Key.S, hxd.Key.DOWN);

		Assets.init();
		hxd.snd.Manager.get();

		#if js
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.font);
		#end

		delayer.addF( function() {
            onResize();
			#if debug
				new Game(); // HACK
			#else
				new Intro();
			#end
			#if hl
				var c = new h2d.Console(Assets.font, Boot.ME.s2d);
				Lib.redirectTracesToH2dConsole(c);
			#end
			dn.Process.resizeAll();
		}, 100);

    }

    override function onResize() {
		super.onResize();
		Const.UPSCALE = dn.heaps.Scaler.bestFit_i(350,260);
		root.setScale(Const.UPSCALE);
    }

}