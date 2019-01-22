import mt.deepnight.Lib;
import mt.MLib;

class Intro extends mt.Process {

	public function new() {
		super();

		createRoot(Boot.ME.s2d);

		var ca = Boot.ME.controller.createAccess("intro");
		var logo = Assets.tiles.h_get("logo",0, 0.5,0.5, root);
		logo.setScale( MLib.fmax( w()/logo.tile.width, h()/logo.tile.height ) );
		//logo.constraintSize(w(), h());
		logo.setPosition(w()*0.5, h()*0.5);
		tw.createMs(logo.alpha, 0>1, 1500);
		delayer.add( function() {
			tw.createMs(logo.alpha,0, 1500).end( function() {
				new Game();
				destroy();
			});
		}, 3800);

		Assets.music.playOnGroup(1,true);
	}
}