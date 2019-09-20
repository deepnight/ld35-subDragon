class Boot extends hxd.App {
	public static var ME : Boot;

	// Boot
	static function main() {
		hxd.Res.initEmbed({compressSounds:true});

		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;

		var w = new h2d.Object(Boot.ME.s2d);
		new Main(w);
	}

	override function onResize() {
		super.onResize();
		dn.Process.resizeAll();
	}

	var suspend = 0.;
	public function suspendFor(d:Float) {
		suspend = d;
	}

	override function update(delta:Float) {
		dn.heaps.Controller.beforeUpdate();

		super.update(delta);

		if( suspend>0 )
			suspend--;
		else
			dn.Process.updateAll(hxd.Timer.tmod);
	}
}

