import mt.deepnight.Lib;
import mt.MLib;

class Intro extends mt.Process {

	public function new() {
		super();

		createRoot(Boot.ME.s2d);

		var ctrl = new mt.flash.Controller("main");
		var logo = Assets.tiles.h_get("logo",0, 0.5,0.5, root);
		logo.setScale( MLib.fmax( w()/logo.tile.width, h()/logo.tile.height ) );
		//logo.constraintSize(w(), h());
		logo.setPos(w()*0.5, h()*0.5);
		tw.create(logo.alpha, 0>1, 1500);
		delayer.add( function() {
			tw.create(logo.alpha,0, 1500).end( function() {
				new Game();
				destroy();
			});
		}, 3800);

		Assets.music.playLoop();
	}
}