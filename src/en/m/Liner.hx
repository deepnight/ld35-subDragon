package en.m;

import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.MLib;

class Liner extends en.Mob {
	var ang : Float;
	var bullets = 0;
	public function new(x,y, ang:Float) {
		super(x,y);
		this.ang = ang;
		spr.set("liner");
		initLife(8);
		cd.setSeconds("shoot", 0.5);
	}

	override public function onDispose() {
		super.onDispose();
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.rotation = ang + Math.cos(utime*0.1)*0.1;
		//spr.rotation += Lib.angularSubstractionRad(angTo(hero), spr.rotation)*0.1;
	}

	override function onDie() {
		super.onDie();
		Assets.SBANK.explosion5(0.7);
	}

	override public function update() {
		super.update();

		var range = Const.GRID*13;

		if( distSqr(hero)<=range*range*1.1*1.1 && !cd.hasSet("shoot", secToFrames(1.5)) ) {
			prepare( secToFrames(0.5), function() {
				bullets = 10;
			});
		}

		if( bullets>0 && !cd.hasSet("subShoot", secToFrames(0.05)) ) {
			var d = rnd(0,5,true);
			var e = new en.Oscillo(centerX+Math.cos(ang)*10+Math.cos(ang+1.57)*d, centerY+Math.sin(ang)*10+Math.sin(ang+1.57)*d, ang, 0.3);
			e.setRange(range);
			//var s = 0.3;
			//e.dx = Math.cos(ang)*s;
			//e.dy = Math.sin(ang)*s;
			bullets--;
		}
	}
}
