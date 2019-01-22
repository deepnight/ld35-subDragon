package en;

import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.MLib;

class Ring extends Entity {
	public static var ALL : Array<Ring> = [];
	public var order : Int;
	var parent : Null<Ring>;
	var ang : Float;
	var da : Float;
	var linkDist : Float;
	public var eyeAng(get,never): Float;
	var shadow : HSprite;
	var phong : HSprite;
	var link : HSprite;
	var linkBg : HSprite;
	public var frozen(default,set) : Bool;
	var frozenAng : Float;
	var frozenDist : Float;
	var dr = 0.;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		ang = 0;
		da = 0;
		frozenAng = 0;
		order = ALL.length-1;
		cd.setF("bubble", rndSeconds(0, 1));
		circColRadius = Const.GRID*0.3;
		radius = Const.GRID*0.5;
		linkDist = Const.GRID*0.5;
		frozen = false;

		//spr.filter = true;

		link = Assets.tiles.h_get("ringLink",order%2==0?0:1, 0.5,0.5);
		Game.ME.scroller.add(link, Const.DP_ENTITY);

		linkBg = Assets.tiles.h_get("ringBack",0, 0.5,0.5);
		linkBg.setFrame( order%linkBg.group.frames.length );
		Game.ME.scroller.add(linkBg, Const.DP_BG);

		shadow = Assets.tiles.h_get("ringShadow",0, 0.5,0.5);
		Game.ME.scroller.add(shadow, Const.DP_ENTITY);
		shadow.alpha = 0.75;

		phong = Assets.tiles.h_get("ringPhong",0, 0.5,0.5);
		Game.ME.scroller.add(phong, Const.DP_ENTITY);
		phong.alpha = 0.4;
	}

	function getChild() : Null<Ring> {
		for(e in ALL)
			if( e.order==order+1 )
				return e;
		return null;
	}

	function set_frozen(v) {
		if( v && !frozen && parent!=null ) {
			frozenDist = Math.sqrt(distSqr(hero));
			frozenAng = hero.angTo(this);
		}
		return frozen = v;
	}

	function get_eyeAng() return ang;

	public function linkTo(e:Ring) parent = e;

	public function hitWeakSpot(e:Bullet) {
		return Lib.angularDistanceRad(angTo(e), eyeAng)<=1.25
			&& distCaseSqr(e)<=6*6;
		//return Lib.angularDistanceRad(eyeAng+3.14, bulletAng) <= 1.57;
	}

	var delayedBullets : Array<Bullet> = [];
	public function delayedBulletKill(e:Bullet) {
		delayedBullets.push(e);
	}

	override function onDie() {
		super.onDie();

		//fx.ringExplode(centerX, centerY);
//
		//var i = 0;
		//for(e in ALL) {
			//if( e.isDead() )
				//continue;
//
			//while( e.parent!=null && e.parent.isDead() )
				//e.parent = e.parent.parent;
			//e.order = i++;
		//}
	}

	override public function onDispose() {
		super.onDispose();

		ALL.remove(this);

		link.remove();
		shadow.remove();
		phong.remove();
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.x = Std.int(spr.x);
		spr.y = Std.int(spr.y);
		if( !hero.isDead() )
			spr.rotation += Lib.angularSubstractionRad( eyeAng, spr.rotation )*0.3;
		shadow.setPosition(spr.x, spr.y);
		phong.setPosition(spr.x, spr.y);

		link.visible = parent!=null && !parent.isDead();
		if( parent!=null ) {
			link.setPosition( (spr.x+parent.spr.x)*0.5, (spr.y+parent.spr.y)*0.5 );
			link.rotation = Math.atan2(parent.spr.y-spr.y, parent.spr.x-spr.x);
		}

		linkBg.visible = link.visible;
		linkBg.rotation = link.rotation + rnd(0,0.05,true);
		linkBg.setPosition(link.x, link.y);
	}

	override public function update() {
		super.update();
		if( centerY>(level.waterY-0.3)*Const.GRID && centerY<(level.waterY+0.3)*Const.GRID && !cd.hasSetS("softSplash",0.3) )
			fx.splash(centerX, true);

		if( !cd.hasSetS("bubble", rnd(1.5,2.5)) )
			fx.bubble(centerX, centerY);

		if( hero.isDead() ) {
			spr.rotation += dr;
			if( onGround )
				dr*=0.8;
			frict = 0.7;
			dy += cy<level.waterY ? rnd(0.03,0.04) : rnd(0.02, 0.03);
		}

		//if( cy<level.waterY )
			//dy+=0.06;

		for(e in delayedBullets)
			if( !e.isDead() ) {
				//if( !Game.ME.cd.hasSet("hitSuspend", secToFrames(5)) )
					//Boot.ME.suspendFor( secToFrames(0.2) );
				fx.hit(e.centerX, e.centerY, e.angTo(this));
				Game.ME.delayer.addF( function() {
					hit(2, e);
					e.destroy();
				}, 1);
				break;
			}
		delayedBullets = [];
	}
}