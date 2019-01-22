package en;

import mt.MLib;
import mt.deepnight.Lib;

class Head extends Ring {
	public var ca : mt.heaps.Controller.ControllerAccess;
	var speed : Float;

	public var mouseControl = false;

	public function new(x,y) {
		super(x,y);
		spr.set("head");
		weight = 10;
		ca = Boot.ME.controller.createAccess("head");
		frict = 0.7;
		speed = 0;
		initLife(1);
		#if debug
		initLife(100);
		#end

		for(i in 0...6) addRing();

		Game.ME.scroller.over(spr);
	}

	function addRing() {
		var e = new en.Tail(cx-en.Ring.ALL.length, cy);
		if( en.Ring.ALL.length<=2 )
			e.linkTo(this);
		else
			e.linkTo(en.Ring.ALL[en.Ring.ALL.length-2]);
	}

	override public function hitWeakSpot(e) {
		return false;
	}

	public function setFrozen(v) {
		for(e in en.Ring.ALL)
			e.frozen = v;
	}

	override public function postUpdate() {
		super.postUpdate();
		var e = getChild();
		if( e!=null )
			spr.rotation = ang + Lib.angularSubstractionRad(e.ang,ang)*0.7;
			//spr.rotation += Lib.angularSubstractionRad( ang + Lib.angularSubstractionRad(e.ang,ang)*0.7, spr.rotation ) * 0.3;
	}

	override public function hit(dmg, ?from:Entity) {
		if( !cd.has("shield") ) {
			cd.setF("shield", secToFrames(0.1));
			super.hit(dmg, from);
		}
	}

	override function onDie() {
		super.onDie();
		viewport.shake(9, 2);
		Assets.SBANK.explosion0(0.5);
		var i = 0;
		for(e in Ring.ALL) {
			Game.ME.delayer.addMs( function() {
				fx.ringExplode(e.centerX, e.centerY);
				e.spr.set("ringDamaged");
			}, i*450);

			if( e.isDead() )
				continue;

			e.lCollisions = true;
			e.dx = rnd(0.03,0.06,true);
			e.dr = rnd(0.05, 0.2, true);
			e.frozen = false;
			e.parent = null;

			i++;
		}
	}

	override public function onDispose() {
		super.onDispose();
		ca.dispose();
	}

	public inline function getBodyCenterX() {
		var v = 0.;
		for(e in Ring.ALL)
			v+=e.centerX;
		return v/Ring.ALL.length;
	}

	public inline function getBodyCenterY() {
		var v = 0.;
		for(e in Ring.ALL)
			v+=e.centerY;
		return v/Ring.ALL.length;
	}

	var target : Null<Point>;
	public function goto(x,y) {
		target = new Point(x,y);
	}

	override public function update() {
		super.update();

		var sa = 0.3;
		var trust = 0.;
		if( target!=null ) {
			// Auto pilot
			var ta = Math.atan2(target.centerY-centerY, target.centerX-centerX) + Math.cos(ftime*0.1)*0.2;
			ang += Lib.angularSubstractionRad(ta,ang)*sa*1.5;
			if( distSqrFree(target.centerX, target.centerY)<=MLib.pow(Const.GRID*1,2) ) {
				target = null;
				Game.ME.cm.signal();
			}
			trust = 0.7;
		}
		else if( !Game.ME.isLocked() ) {
			if( mouseControl ) {
				// Mouse controls
				var m = Game.ME.getMouse();
				var ma = angToFree(m.sx, m.sy);
				var da = Lib.distanceSqr(centerX, centerY, m.sx,m.sy);
				if( da>=8*8 && Lib.angularDistanceRad(ma,ang)<=MLib.PI*0.6 || da>=20*20 )
					ang+=Lib.angularSubstractionRad(ma, ang)*sa;
				trust = 0.5 + 0.5 * MLib.fmin( Lib.distance(centerX, centerY, m.sx, m.sy)/(Const.GRID*5), 1);
			}
			else {
				// Keyboard/pad controls
				trust = 0.15;
				if( ca.leftDown() ) {
					ang += Lib.angularSubstractionRad(3.14,ang)*sa*1.5;
					trust = 1;
				}
				else if( ca.rightDown() ) {
					ang += Lib.angularSubstractionRad(0,ang)*sa*1.5;
					trust = 1;
				}
				if( ca.upDown() ) {
					ang += Lib.angularSubstractionRad(-1.57,ang)*sa;
					trust = 1;
				}
				else if( ca.downDown() ) {
					ang += Lib.angularSubstractionRad(1.57,ang)*sa;
					trust = 1;
				}

				//trace("left="+ctrl.leftDown()+" right="+ctrl.rightDown()+" up="+ctrl.upDown()+" down="+ctrl.downDown());

				//fx.markerFree(centerX+rnd(0,10,true), centerY+rnd(0,10,true), 100);
				if( ca.aDown() )
					setFrozen(true);
				else
					setFrozen(false);
			}
		}

		speed += (frozen?0.7:1) * trust * 0.050; // 0.042;
		dx+=Math.cos(ang)*speed;
		dy+=Math.sin(ang)*speed;
		speed*=0.5;
		if( trust>=0.9 && !cd.hasSetF("bubTrust",secToFrames(0.2)) )
			for(i in 0...2)
				fx.bubble(centerX, centerY);

		// Checkpoints
		if( level.hasSpot("door",cx,cy) && ( Game.ME.curCheckPoint==null || Game.ME.curCheckPoint.cx<cx ) ) {
			var top = cy;
			while( level.hasSpot("door",cx,top-1) ) top--;
			var bot = cy;
			while( level.hasSpot("door",cx,bot+1) ) bot++;
			fx.markerCase(cx,top, 100);
			fx.markerCase(cx,bot, 100);
			fx.markerCase(cx,cy, 100);
			Game.ME.setCheckPoint(cx, Std.int((top+bot)*0.5));

		}

		//for(pt in level.getSpots("check"))
			//if( cx>=pt.cx && ( Game.ME.curCheckPoint==null || Game.ME.curCheckPoint.cx<pt.cx ) ) {
				//var any = false;
				//for(e in en.Mob.ALL)
					//if( !e.isDead() && e.cx<=pt.cx ) {
						//any = true;
						//break;
					//}
				//if( !any )
					//Game.ME.curCheckPoint = pt;
			//}
	}
}