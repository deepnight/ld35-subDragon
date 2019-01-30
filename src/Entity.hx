import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;

class Entity {
	public static var GC : Array<Entity> = [];
	public static var ALL : Array<Entity> = [];
	static var UNIQ = 0;

	var spr : HSprite;
	var cd : mt.Cooldown;
	public var uid : Int;

	// public var gpTmod(get,never) : Float; inline function get_tmod() return Game.ME.gpTmod*0.5;
	public var gpTmod(get,never) : Float; inline function get_gpTmod() return Game.ME.tmod * Const.GP_FPS/Const.FPS;
	public var realTmod(get,never) : Float; inline function get_realTmod() return Game.ME.tmod;

	public var cx : Int;
	public var cy : Int;
	public var xr : Float;
	public var yr : Float;

	public var dx : Float;
	public var dy : Float;
	public var frict : Float;
	public var weight : Float;

	//public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	//public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID;

	public var centerX(get,never) : Float; inline function get_centerX() return (cx+xr)*Const.GRID;
	public var centerY(get,never) : Float; inline function get_centerY() return (cy+yr)*Const.GRID;

	public var radius : Float;
	public var circColRadius : Float;
	var lCollisions = true;
	var floating = true;
	public var destroyed(default,null) = false;

	var level(get,never) : Level; inline function get_level() return Game.ME.level;
	var viewport(get,never) : Viewport; inline function get_viewport() return Game.ME.viewport;
	var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	var hero(get,never) : en.Head; inline function get_hero() return Game.ME.hero;
	var ftime(get,never) : Float; inline function get_ftime() return Game.ME.ftime;
	var utime(get,never) : Float; inline function get_utime() return Game.ME.ftime+uid*10;
	var onGround(get,never) : Bool; inline function get_onGround() return yr==1 && level.hasCollision(cx,cy+1);
	var life : Int;
	var maxLife : Int;

	public function new(x:Int,y:Int) {
		uid = UNIQ++;
		ALL.push(this);
		cd = new mt.Cooldown(Const.FPS);
		setPoseCase(x,y);
		dx = dy = 0;
		frict = 0.85;
		weight = 0;
		circColRadius = Const.GRID*0.6;
		radius = Const.GRID*0.5;
		initLife(1);

		spr = new mt.heaps.slib.HSprite(Assets.tiles);
		spr.setCenterRatio(0.5,0.5);
		spr.set("level");
		Game.ME.scroller.add(spr, Const.DP_ENTITY);
	}

	public function initLife(v:Int) {
		life = maxLife = v;
	}

	public function hit(dmg, ?from:Entity) {
		colorBlink(0xFF0000, secToFrames(0.03));
		life-=dmg;
		if( life<=0 )
			onDie();
	}

	function onDie() {
		destroy();
	}

	public function distCaseSqr(e:Entity) return mt.deepnight.Lib.distanceSqr(cx,cy, e.cx, e.cy);
	public function distSqr(e:Entity) return mt.deepnight.Lib.distanceSqr(centerX, centerY, e.centerX, e.centerY);
	public function distSqrFree(x:Float, y:Float) return mt.deepnight.Lib.distanceSqr(centerX, centerY, x, y);
	public inline function angTo(e:Entity) return Math.atan2(e.centerY-centerY, e.centerX-centerX);
	public inline function getMoveAng() return Math.atan2(dy,dx);
	public inline function angToFree(x:Float, y:Float) return Math.atan2(y-centerY, x-centerX);
	public inline function secToFrames(v:Float) return Game.ME.secToFrames(v);
	inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	inline function pretty(v:Float, ?precision=2) return Lib.prettyFloat(v, precision);
	inline function rndSeconds(min,max,?sign) return secToFrames( Lib.rnd(min,max,sign) );
	inline function irndSeconds(min,max,?sign) return secToFrames( Lib.rnd(min,max,sign) );

	public inline function is(c:Class<Entity>) return Std.is(this,c);

	public function setPoseCase(x,y) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 0.5;
	}
	public function setPosePixel(x:Float,y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = ( x - cx*Const.GRID ) / Const.GRID;
		yr = ( y - cy*Const.GRID ) / Const.GRID;
	}

	public inline function destroy() {
		if( !destroyed ) {
			GC.push(this);
			destroyed = true;
		}
	}


	var color : Null<UInt>;
	var colorPow = 0.;
	public function colorBlink(c:UInt, d:Float, ?pow=1.0) {
		color = c;
		colorPow = pow;
		spr.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(c, pow);
		cd.setF("rgbRestore", d);
	}


	public function onDispose() {
		ALL.remove(this);
		spr.remove();
	}

	public function postUpdate() {
		spr.setPosition(centerX,centerY);

		if( floating && cy>=level.waterY ) {
			spr.x += Math.cos(utime*0.052)*2;
			spr.y += Math.sin(utime*0.035)*2;
		}

		// Color blink
		if( !cd.has("rgbRestore") && colorPow>0 ) {
			colorPow = MLib.fmax(colorPow-0.22, 0);
			if( colorPow<=0 )
				spr.colorMatrix = null;
			else
				spr.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(color, colorPow);
		}
	}


	function physX() {
		xr+=dx*gpTmod;

		if( lCollisions ) {
			if( xr<0.25 && level.hasCollision(cx-1,cy) ) {
				dx *= Math.pow(0.6,gpTmod);
				xr = 0.25;
			}
			if( xr>0.75 && level.hasCollision(cx+1,cy) ) {
				dx *= Math.pow(0.6,gpTmod);
				xr = 0.75;
			}
		}
	}


	function physY() {
		yr+=dy*gpTmod;

		if( lCollisions ) {
			if( yr<0.5 && level.hasCollision(cx,cy-1) ) {
				dy *= Math.pow(0.8,gpTmod);
				yr = 0.5;
			}
			if( yr>1 && level.hasCollision(cx,cy+1) ) {
				dy = 0;
				yr = 1;
			}
		}
	}

	public function isDead() {
		return destroyed;
	}


	function onTouch(e:Entity) {
	}


	public function ignoreTouch(e:Entity, ?d=99999) {
		if( e==null )
			return;
		cd.setF("ignore"+e.uid, d);
		e.cd.setF("ignore"+uid, d);
	}

	public function update() {
		var oldY = centerY;
		cd.update(realTmod);

		// Circular collisions
		if( weight>0 )
			for(e in ALL) {
				if( e==this || e.weight<=0 || e.isDead() )
					continue;

				var d = distSqr(e);
				if( d>=(circColRadius+e.circColRadius)*(circColRadius+e.circColRadius) )
					continue;

				var pow = 0.05;
				var a = Math.atan2(e.centerY-centerY, e.centerX-centerX);
				var wr = e.weight / (e.weight+weight);
				if( wr>0.9 ) wr = 1;
				if( wr<0.1 ) wr = 0;
				dx-=Math.cos(a)*pow*wr*gpTmod;
				dy-=Math.sin(a)*pow*wr*gpTmod;

				var wr = weight / (e.weight+weight);
				if( wr>0.9 ) wr = 1;
				if( wr<0.1 ) wr = 0;
				e.dx+=Math.cos(a)*pow*wr*gpTmod;
				e.dy+=Math.sin(a)*pow*wr*gpTmod;
			}

		// Touch detection
		for(e in ALL)
			if( e!=this && !isDead() && distSqr(e)<=(radius+e.radius)*(radius+e.radius) && !cd.has("ignore"+e.uid) ) {
				onTouch(e);
				e.onTouch(this);
			}

		// X
		physX();

		dx*=Math.pow(frict,gpTmod);
		if( MLib.fabs(dx)<=0.0001*gpTmod ) dx = 0;

		while(xr>1) { xr--; cx++; }
		while(xr<0) { xr++; cx--; }

		// Y
		physY();

		dy*=Math.pow(frict,gpTmod);
		if( MLib.fabs(dy)<=0.0001*gpTmod ) dy = 0;

		while(yr>1) { yr--; cy++; }
		while(yr<0) { yr++; cy--; }


		// Water splash
		if( MLib.sign(level.waterY*Const.GRID-oldY) != MLib.sign(level.waterY*Const.GRID-centerY) )
			fx.splash(centerX);
	}
}