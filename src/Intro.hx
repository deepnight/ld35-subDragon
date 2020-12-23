class Intro extends dn.Process {
	var logo : HSprite;

	public function new() {
		super();

		createRoot(Main.ME.root);

		var ca = Main.ME.controller.createAccess("intro");
		logo = Assets.tiles.h_get("logo",0, 0.5,0.5, root);

		// var mul = #if debug 0.3 #else 1 #end;
		var mul = 1;
		tw.createMs(logo.alpha, 0>1, 1500*mul);
		delayer.addMs( function() {
			var tf = new h2d.Text(Assets.font, root);
			tf.text = "Initialiazing level...";
			tf.x = Std.int( w()/Const.UPSCALE*0.5 - tf.textWidth*0.5*tf.scaleX );
			tf.y = Std.int( h()/Const.UPSCALE*0.9 - tf.textHeight*tf.scaleY );
			tw.createMs(logo.alpha,0.7, 700).end( function() {
				delayer.addF(()->{
					new Game();
					root.parent.addChild(root);
				}, 1);
				delayer.addF(()->{
					tw.createMs(tf.alpha, 0, 500);
					tw.createMs(logo.alpha, 0, 1500).end(destroy);
				}, 2);
			});
		}, 1900*mul);

		onResize();
	}

	override function onResize() {
		super.onResize();

		var wid = w()/Const.UPSCALE;
		var hei = h()/Const.UPSCALE;

		logo.setScale(Const.UPSCALE<4 ? 2 : 1);
		logo.setPosition(wid*0.5, hei*0.5);
	}
}