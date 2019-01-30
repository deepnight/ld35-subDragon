import mt.deepnight.Lib;
import mt.MLib;

class Intro extends mt.Process {
	var logo : mt.heaps.slib.HSprite;

	public function new() {
		super();

		createRoot(Main.ME.root);

		var ca = Main.ME.controller.createAccess("intro");
		logo = Assets.tiles.h_get("logo",0, 0.5,0.5, root);
		// logo.setScale( MLib.fmax( wid/logo.tile.width, hei/logo.tile.height ) );
		tw.createMs(logo.alpha, 0>1, 1500);
		delayer.addMs( function() {
			tw.createMs(logo.alpha,0, 1500).end( function() {
				new Game();
				destroy();
			});
		}, 380000);

		onResize();
	}

	override function onResize() {
		super.onResize();

		var wid = w()/Const.UPSCALE;
		var hei = h()/Const.UPSCALE;
		// var sy = hei / 300;

		// logo.setScale( 1 + MLib.floor(Const.UPSCALE*0.5) );
		logo.setScale(Const.UPSCALE<4 ? 2 : 1);
		logo.setPosition(wid*0.5, hei*0.5);
		trace(Const.UPSCALE);
	}
}