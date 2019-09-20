class Intro extends dn.Process {
	var logo : HSprite;

	public function new() {
		super();

		createRoot(Main.ME.root);

		var ca = Main.ME.controller.createAccess("intro");
		logo = Assets.tiles.h_get("logo",0, 0.5,0.5, root);
		// logo.setScale( M.fmax( wid/logo.tile.width, hei/logo.tile.height ) );
		tw.createMs(logo.alpha, 0>1, 1500);
		delayer.addMs( function() {
			tw.createMs(logo.alpha,0, 1500).end( function() {
				new Game();
				destroy();
			});
		}, 3800);

		onResize();
	}

	override function onResize() {
		super.onResize();

		var wid = w()/Const.UPSCALE;
		var hei = h()/Const.UPSCALE;
		// var sy = hei / 300;

		// logo.setScale( 1 + M.floor(Const.UPSCALE*0.5) );
		logo.setScale(Const.UPSCALE<4 ? 2 : 1);
		logo.setPosition(wid*0.5, hei*0.5);
		trace(Const.UPSCALE);
	}
}