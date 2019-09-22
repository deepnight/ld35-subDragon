class Viewport extends dn.Process {

	var s : h2d.Object;
	public var x : Float;
	public var y : Float;
	public var wid(get,never) : Float; inline function get_wid() return w()/Const.UPSCALE;
	public var hei(get,never) : Float; inline function get_hei() return h()/Const.UPSCALE;

	var level(get,never) : Level; inline function get_level() return Game.ME.level;

	public function new(s:h2d.Object) {
		super(Game.ME);
		this.s = s;
		x= y = 0;
	}

	var shakePow = 0.;
	public function shake(pow:Float, ?dsec=1.0) {
		if( shakePow>pow )
			return;

		shakePow = pow;
		tw.createMs(shakePow, 200|pow>0, dsec*1000, TEaseIn);
	}

	override public function update() {
		super.update();

		var e = Game.ME.hero;
		var a = e.getMoveAng();
		var spd = Math.sqrt(e.dx*e.dx+e.dy*e.dy)*200;
		x = e.centerX + Math.cos(a)*spd;
		y = e.centerY + Math.sin(a)*spd;

		x = M.fclamp(x, wid*0.5, level.wid*Const.GRID-wid*0.5);
		y = M.fclamp(y, hei*0.5, level.hei*Const.GRID-hei*0.5);

		var tx = -(x-wid*0.5);
		var ty = -(y-hei*0.5);
		var spd = M.distSqr(s.x, s.y, tx, ty)>=400*400 ? 0.11 : 0.05;
		s.x += ( tx - s.x ) * spd;
		s.y += ( ty - s.y ) * spd;

		s.x += Math.cos(ftime*2)*shakePow;
		s.y += Math.sin(ftime*2.2)*shakePow;

		s.x = M.round(s.x);
		s.y = M.round(s.y);
		s.x = M.fclamp(s.x, -(level.wid*Const.GRID)+wid*0.5, 0);
		s.y = M.fclamp(s.y, -(level.hei*Const.GRID)+hei*0.5, 0);
	}

}
