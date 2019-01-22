package en;

import mt.deepnight.Lib;
import mt.MLib;

class Bullet extends Entity {
	var maxDist2 : Float;
	var ox : Float;
	var oy : Float;
	var fromHero : Bool;
	public function new(xx,yy, ?fromHero:Bool) {
		super(0,0);
		this.fromHero = fromHero;
		setPosePixel(xx,yy);
		ox = xx;
		oy = yy;
		floating = false;

		setRange(Const.GRID*7);

		radius = 2;
		lCollisions = false;
		weight = 0;
		frict = 1;
		spr.anim.playAndLoop(fromHero?"hbullet":"ebullet").setSpeed(0.25);
		Game.ME.scroller.add(spr, Const.DP_BULLET);
	}

	public inline function setRange(v:Float) {
		maxDist2 = v*v;
	}

	override function onTouch(e:Entity) {
		super.onTouch(e);

		if( e.is(en.Mob) && fromHero ) {
			var a = getMoveAng();
			fx.bulletHitEcho(centerX, centerY);
			e.hit(1, this);
			destroy();
		}

		if( e.is(en.Ring) ) {
			var e : en.Ring = cast e;
			var a = getMoveAng();
			if( !fromHero )
				fx.bulletHitEcho(centerX, centerY);
			if( !fromHero && e.hitWeakSpot(this) ) {
				e.delayedBulletKill(this);
			}
			else {
				if( !fromHero ) {
					e.colorBlink( 0xFFFFFF, secToFrames(0.10), 0.9 );
					Assets.SBANK.shield0(rnd(0.1,0.3));
				}
				fx.hitShield(centerX, centerY, a);
				destroy();
			}
		}
	}

	override public function postUpdate() {
		super.postUpdate();
		if( fromHero )
			spr.rotation = getMoveAng();
	}

	override public function update() {
		super.update();

		if( !cd.hasSetF("tail",2) )
			fx.tail(centerX, centerY, getMoveAng());

		if( level.hasCollision(cx,cy) ) {
			fx.hitShield(centerX, centerY, getMoveAng());
			destroy();
		}

		if( Lib.distanceSqr(centerX, centerY, ox, oy)>=maxDist2 )
			destroy();
	}
}