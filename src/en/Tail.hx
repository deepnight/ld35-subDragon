package en;

class Tail extends Ring {
	var target : Null<en.Mob>;
	var coneAng = 1.5;
	var shootSpr : HSprite;
	var frozenSpr : HSprite;

	public function new(x,y) {
		super(x,y);
		lCollisions = false;
		frict = 0.55;

		weight = 1;

		shootSpr = Assets.tiles.h_get("ringShoot",0, 0.5,0.5);
		Game.ME.scroller.add(shootSpr, Const.DP_FX);
		shootSpr.blendMode = Add;
		shootSpr.visible = false;

		frozenSpr = Assets.tiles.h_get("ringFrozen",0, 0.5,0.5);
		Game.ME.scroller.add(frozenSpr, Const.DP_ENTITY);
		frozenSpr.visible = false;

		spr.set("ring");
	}

	override function get_eyeAng() {
		var c = getChild();
		if( c==null || parent==null ) return ang+1.57;
		return Math.atan2(parent.centerY-c.centerY, parent.centerX-c.centerX) + 1.57;
	}

	override public function hit(dmg, ?from:Entity) {
		if( !hero.isDead() ) {
			for(e in Ring.ALL)
				e.colorBlink(0xFF0000, rndSeconds(0.03, 0.04));
			hero.hit(dmg, from);
		}
	}


	override function onTouch(e:Entity) {
		super.onTouch(e);

		if( e.is(en.Mob) && !cd.hasSetF("contactHit",secToFrames(0.3)) ) {
			e.hit(1000, this);
			hit(1, e);
		}
	}


	override public function postUpdate() {
		super.postUpdate();
		if( cd.has("shake") ) {
			spr.x+=rnd(0,1);
			spr.y+=rnd(0,1);
		}

		shootSpr.setPosition(spr.x, spr.y);
		shootSpr.rotation = spr.rotation;

		frozenSpr.setPosition(spr.x, spr.y);
		frozenSpr.rotation = spr.rotation;
		frozenSpr.visible = frozen;
	}

	override public function onDispose() {
		super.onDispose();
	}

	function playRandomSfx( randList:Array<?Float->dn.heaps.Sfx>, ?volume=1.0) {
		return randList[ Std.random(randList.length) ]().play(volume);
	}

	override public function update() {
		super.update();

		// Shoot
		if( !hero.isDead() ) {
			target = null;
			var range = 8;
			for(e in en.Mob.ALL)
				if( !e.isDead() && distCaseSqr(e)<=range*range && M.radDistance(angTo(e), eyeAng)<=coneAng*0.5 && ( target==null || distCaseSqr(e)<=distCaseSqr(target) ) )
					target = e;

			if( target!=null && !cd.hasSetF("shoot", secToFrames(0.15)) ) {
				var e = new en.Bullet(centerX, centerY, true);
				var s = 0.45;
				var a = angTo(target);
				e.setRange(range*1.2*Const.GRID);
				e.ignoreTouch(this);
				e.ignoreTouch(parent);
				e.ignoreTouch(getChild());
				e.dx = Math.cos(a)*s;
				e.dy = Math.sin(a)*s;
				//target.hit(1, this);
				cd.setF("shake", secToFrames(0.2));
				fx.shoot(centerX, centerY, target.centerX, target.centerY);
				shootSpr.visible = true;
				shootSpr.alpha = 1;
				shootSpr.scaleX = 1;
				if( !hero.cd.hasSetF("shootSfx", secToFrames(0.1)) )
					playRandomSfx([ Assets.SBANK.shoot1,Assets.SBANK.shoot2,Assets.SBANK.shoot3 ], rnd(0.03, 0.07));
			}
		}


		if( parent!=null && !hero.isDead() )
			if( frozen ) {
				// Frozen position
				var tx = hero.centerX + Math.cos(frozenAng)*frozenDist;
				var ty = hero.centerY + Math.sin(frozenAng)*frozenDist;
				var ta = Math.atan2(ty-centerY, tx-centerX);
				var d = Math.sqrt( distSqrFree(tx,ty) ) / Const.GRID;
				dx += Math.cos(ta)*d*0.3*gpTmod;
				dy += Math.sin(ta)*d*0.3*gpTmod;
			}
			else {
				// Follow parent
				var ta = angTo(parent);
				ang += M.radSubstract(ta, ang)*0.7;
				var d = (Math.sqrt( distSqr(parent) ) - linkDist*1.2) / Const.GRID;
				dx += Math.cos(ang)*d*0.3*gpTmod;
				dy += Math.sin(ang)*d*0.3*gpTmod;
			}

		if( shootSpr.visible ) {
			shootSpr.alpha-=0.3;
			shootSpr.scaleX*=0.8;
			if( shootSpr.alpha<=0 )
				shootSpr.visible = false;
		}

	}
}