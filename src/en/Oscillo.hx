package en;

class Oscillo extends en.Bullet {
	var ang : Float;
	var spd : Float;
	public function new(xx,yy, ang:Float, spd:Float) {
		super(xx,yy,false);
		this.ang = ang;
		this.spd = spd;
	}

	override public function update() {
		super.update();

		var o = Math.cos(utime*0.2);
		dx = Math.cos(ang)*spd + Math.cos(ang+1.57)*spd*o;
		dy = Math.sin(ang)*spd + Math.sin(ang+1.57)*spd*o;
	}
}