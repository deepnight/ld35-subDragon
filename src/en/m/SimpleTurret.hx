package en.m;

import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.MLib;

class SimpleTurret extends en.Mob {
	var bullets = 0;
	var base : HSprite;

	public function new(x,y) {
		super(x,y);
		spr.set("turretFull");
		initLife(8);
		cd.setF("shoot", rndSeconds(2,3));

		base = Assets.tiles.h_get("turretBase",0, 0.5,0.5);
		Game.ME.scroller.add(base, Const.DP_BG);
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.scaleX = 0.9 + 0.06*Math.cos(utime*0.07);
		spr.scaleY = 0.9 + 0.06*Math.cos(1.9+utime*0.09);
		spr.rotation += Lib.angularSubstractionRad(angTo(hero), spr.rotation) * 0.2;

		if( spr.is("turret") && !cd.has("empty") )
			spr.set("turretFull");

		base.setPosition(spr.x, spr.y);
		base.rotation = -spr.rotation*0.5;
	}

	override function onDie() {
		super.onDie();
		Assets.SBANK.explosion3(0.7);
	}

	override public function onDispose() {
		super.onDispose();
		base.remove();
	}

	override public function update() {
		super.update();

		var range = Const.GRID*9;

		if( !hero.isDead() && distSqr(hero)<=range*range*1.5*1.5 && !cd.hasSetF("shoot", rndSeconds(4.5, 5)) ) {
			prepare(secToFrames(1.3), function() {
				spr.set("turret");
				bullets+=4;
			});
		}

		if( bullets>0 && !cd.hasSetF("shootingSub",secToFrames(0.15)) ) {
			cd.setS("empty", cd.getS("shoot")*0.5 );
			var e = new en.Bullet(centerX, centerY);
			e.setRange(range);
			var a = angToFree( hero.getBodyCenterX(), hero.getBodyCenterY() );
			var s = 0.1;
			e.dx = Math.cos(a)*s;
			e.dy = Math.sin(a)*s;
			bullets--;
		}
	}
}