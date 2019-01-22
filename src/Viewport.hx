import mt.MLib;
import mt.deepnight.Tweenie;

class Viewport extends mt.Process {

	var s : h2d.Object;
	public var x : Float;
	public var y : Float;
	public var wid : Float;
	public var hei : Float;

	var level(get,never) : Level; inline function get_level() return Game.ME.level;

	public function new(s:h2d.Object) {
		super(Game.ME);
		this.s = s;
		x= y = 0;
		wid = hei = 1;
		onResize();
	}

	override public function onResize() {
		super.onResize();
		wid = w() / Const.UPSCALE;
		hei = h() / Const.UPSCALE;
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

		x = MLib.fclamp(x, wid*0.5, level.wid*Const.GRID-wid*0.5);
		y = MLib.fclamp(y, hei*0.5, level.hei*Const.GRID-hei*0.5);

		var tx = -(x-wid*0.5)*Const.UPSCALE;
		var ty = -(y-hei*0.5)*Const.UPSCALE;
		var spd = mt.deepnight.Lib.distanceSqr(s.x, s.y, tx, ty)>=400*400 ? 0.11 : 0.05;
		s.x += ( tx - s.x ) * spd;
		s.y += ( ty - s.y ) * spd;

		s.x += Math.cos(ftime*2)*shakePow;
		s.y += Math.sin(ftime*2.2)*shakePow;

		s.x = mt.MLib.round(s.x);
		s.y = mt.MLib.round(s.y);
		s.x = MLib.fclamp(s.x, -(level.wid*Const.GRID*Const.UPSCALE)+wid*0.5, 0);
		s.y = MLib.fclamp(s.y, -(level.hei*Const.GRID*Const.UPSCALE)+hei*0.5, 0);
	}

}
