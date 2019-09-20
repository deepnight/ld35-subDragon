import dn.heaps.Controller;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : Controller;
	public var ca : ControllerAccess;

    public function new(wrapper:h2d.Object) {
        super();

        ME = this;
        createRoot(wrapper);
		root.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		engine.backgroundColor = 0xff<<24|0x0;
		hxd.Timer.wantedFPS = Const.FPS;

		controller = new dn.heaps.Controller(Boot.ME.s2d);
		ca = controller.createAccess("main");
		controller.bind(A, hxd.Key.SPACE, hxd.Key.F);
		controller.bind(AXIS_LEFT_X_NEG, hxd.Key.A, hxd.Key.LEFT, hxd.Key.Q);
		controller.bind(AXIS_LEFT_X_POS, hxd.Key.D, hxd.Key.RIGHT);
		controller.bind(AXIS_LEFT_Y_POS, hxd.Key.W, hxd.Key.UP, hxd.Key.Z);
		controller.bind(AXIS_LEFT_Y_NEG, hxd.Key.S, hxd.Key.DOWN);

		Assets.init();

		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.font);

		delayer.addF( function() {
            onResize();
			// #if debug
			// 	new Game();
			// #else
				new Intro();
			// #end
			#if hl
				var c = new h2d.Console(Assets.font, Boot.ME.s2d);
				Lib.redirectTracesToH2dConsole(c);
			#end
			dn.Process.resizeAll();
		}, 100);

    }

    override function onResize() {
        super.onResize();
        Const.UPSCALE = M.imax( M.floor( h()/Const.GUARANTEED_HEI ), 1);
		root.setScale(Const.UPSCALE);
    }

}