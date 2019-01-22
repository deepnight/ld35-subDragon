import h2d.SpriteBatch;
import mt.heaps.HParticle;
import mt.deepnight.Lib;
import mt.MLib;

enum Col {
	@str("Red") Red;
	@str("Blue") Blue;
	@str("Green") Green;
	@str("Yellow") Yellow;
	@str("Pink") Pink;
}

class Fx extends mt.Process {
	var pool : ParticlePool;
	public var addSb : h2d.SpriteBatch;
	public var normalSb : h2d.SpriteBatch;

	public function new(p:mt.Process, addCtx:h2d.Object, normalCtx:h2d.Object) {
		super(p);

		pool = new ParticlePool(Assets.tiles.tile, 2048, Const.FPS);
		normalSb = new h2d.SpriteBatch(Assets.tiles.tile, normalCtx);
		normalSb.hasRotationScale = true;

		addSb = new h2d.SpriteBatch(Assets.tiles.tile, addCtx);
		addSb.blendMode = Add;
		addSb.hasRotationScale = true;
	}

	inline function rndSeconds(min,max,?sign) return secToFrames( Lib.rnd(min,max,sign) );
	inline function irndSeconds(min,max,?sign) return secToFrames( Lib.rnd(min,max,sign) );

	override function onDispose() {
		super.onDispose();
		pool.dispose();
	}

	inline function alloc(t:h2d.Tile, x:Float, y:Float, ?add=true) : HParticle {
		return pool.alloc(add?addSb:normalSb, t, x, y);
		// return HParticle.allocFromPool(add?addPool:normalPool, t, x,y);
	}

	inline function getTile(k:String, ?f=-1) return f>=0 ? Assets.tiles.getTile(k,f) : Assets.tiles.getTileRandom(k);

	override public function update() {
		super.update();
		pool.update(tmod);
	}

	public function markerCase(cx,cy, ?d=1.0) {
		var p = alloc(getTile("snakeBall"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setScale(0.5);
		p.lifeF = secToFrames(d);
	}

	public function splash(x, ?soft=false) {
		var y = Game.ME.level.waterY*Const.GRID;
		for(i in 0...2) {
			var p = alloc(getTile("splash"), x+rnd(0,10,true), y+rnd(0,4,true));
			p.alpha = rnd(0.6, 1) * (soft?0.5:1);
			p.setCenterRatio(0.5,1);
			p.setScale( rnd(0.2, 0.3) );
			if( soft )
				p.scaleY*=0.25;
			p.ds = 0.4;
			p.dsFrict = 0.8;
			p.lifeF = rndSeconds(0.3, 0.6);
			//p.scaleMul = 0.92;
			p.onUpdate = function(_) {
				p.scaleY*=0.9;
			}
		}
		for(i in 0...2) {
			var p = alloc(getTile("splash"), x+rnd(0,10,true), y+rnd(0,4,true));
			p.alpha = rnd(0.05, 0.08);
			p.setCenterRatio(0.5,1);
			p.scaleX = rnd(0.5,1);
			p.scaleY = -rnd(0.8,1.3);
			p.lifeF = rndSeconds(0.2, 0.4);
			p.onUpdate = function(_) {
				p.scaleX*=0.9;
				p.scaleY-=0.1;
			}
		}
	}

	public inline function markerEnt(e:Entity, ?d=1.0) {
		markerFree(e.centerX, e.centerY, d);
	}

	public function markerFree(x,y, ?d=1.0) {
		var p = alloc(getTile("snakeBall"), x,y);
		//p.setScale(0.5);
		p.lifeF = secToFrames(d);
	}

	public function tail(x,y, a) {
		var p = alloc(getTile("fxTail"), x,y);
		p.setCenterRatio(0.9, 0.5);
		p.scaleX = 1;
		p.scaleY = 0.6;
		//p.moveAng(a+3.14, 1.5);
		p.alpha = 0.3;
		p.rotation = a;
		p.frict = 0.9;
		p.lifeF = 0;
		p.fadeOutSpeed = p.alpha*0.1;
	}

	public function shoot(fx:Float,fy:Float, tx:Float,ty:Float) {
		fx+=rnd(0,1,true);
		fy+=rnd(0,1,true);
		tx+=rnd(0,3,true);
		ty+=rnd(0,3,true);
		var a = Math.atan2(ty-fy, tx-fx);
		for(i in 0...8) {
			var a = a+rnd(0, 0.05, true);
			var d = rnd(6,8);
			var p = alloc(getTile("fxBlueLine"), fx + Math.cos(a)*d, fy + Math.sin(a)*d);
			p.setScale( rnd(1,2) );
			p.setCenterRatio(i==0?0:1, 0.5);
			p.rotation = a;
			p.moveAng(a, rnd(2.5,3.5));
			p.frict = 0.85;
			p.scaleMul = 0.9;
			p.lifeF = 0;
			//p.delay = i*0.3;
		}
	}


	public function prepare(x:Float,y:Float, r:Float) {
		var p = alloc(getTile("warning"), x,y);
		p.alpha = MLib.fmin(r*1.5, 1);
		p.setScale( 1-r*0.7 );
		p.lifeF = 0;
		p.fadeOutSpeed = 0.3;
	}


	public function hit(x:Float,y:Float, ?ang:Float) {
		var p = alloc(getTile("fxExplode",0), x+rnd(0,7,true), y+rnd(0,7,true));
		p.ds = 0.1;
		p.dsFrict = 0.8;
		p.alpha = rnd(0.6, 0.8);
		p.setScale(rnd(0.03, 0.06));
		p.rotation = rnd(0,6.28);
		p.playAnimAndKill(Assets.tiles, "fxExplode", rnd(0.5,1));

		if( ang!=null ) {
			for(i in 0...3) {
				var a = ang + 3.14 + (i==0?0:rnd(0.2,0.4,true));
				var p = alloc(getTile("fxFireLine"), x + rnd(0,1,true), y + rnd(0,2,true));
				p.alpha = rnd(0.5,0.8);
				p.setScale(rnd(0.5, 1));
				p.moveAng(a, rnd(3,8));
				p.rotation = a;
				p.frict = 0.85;
				p.lifeF = rndSeconds(0.1, 0.2);
			}
		}
	}

	public function bulletHitEcho(x:Float,y:Float) {
		var p = alloc(getTile("bulletHit"), x,y);
		p.alpha = rnd(0.6, 0.8);
		p.lifeF = secToFrames(0.4);
		p.ds = 0.02;
	}


	public function hitShield(x:Float,y:Float, ang:Float) {
		for(i in 0...5) {
			var a = ang + 3.14 + (i==0?0:rnd(0.2,0.4,true));
			var p = alloc(getTile("fxShieldLine"), x + rnd(0,1,true), y + rnd(0,2,true));
			p.alpha = rnd(0.5,0.8);
			p.setScale(rnd(0.5, 1));
			p.moveAng(a, rnd(1,4));
			p.rotation = a;
			p.frict = 0.85;
			p.lifeF = rndSeconds(0.1, 0.2);
		}
	}

	public function bubble(x:Float,y:Float, ?push=false) {
		var p = alloc(getTile("fxBubble"), x+rnd(0,7,true), y+rnd(0,7,true));
		p.ds = 0.1;
		p.dsFrict = 0.7;
		p.alpha = rnd(0.3, 0.8);
		if( push ) {
			p.dx = rnd(2,6,true);
			p.dy = rnd(2,6,true);
		}
		p.gy = -rnd(0.1, 0.3);
		p.frict = 0.85;
		p.fadeOutSpeed = rnd(0.03, 0.06);
		p.lifeF = rndSeconds(2,4);
		var x = p.x;
		var off = rnd(0,3.14);
		var freq = rnd(0.05, 0.1);
		var amp = rnd(0.1, 1);
		p.onUpdate = function(_) {
			p.dx += Math.cos(off+ftime*freq)*0.2*amp;
			if( p.y/Const.GRID<=Game.ME.level.waterY )
				p.kill();
		}
	}


	public function ringExplode(x:Float,y:Float) {
		//var p = alloc(getTile("fxHeroExplode",0), x+rnd(0,7,true), y+rnd(0,7,true));
		//p.alpha = rnd(0.7, 0.8);
		//p.setScale(rnd(1.6,1.8));
		//p.ds = 0.3;
		//p.dsFrict = 0.95;
		//p.rotation = rnd(0, 0.2, true);
		//p.playAnimAndKill(Assets.tiles, "fxHeroExplode", rnd(0.4,0.75));

		for(i in 0...20)
			bubble(x,y,true);

		for(i in 0...10) {
			var p = alloc(getTile("fxHeroExplode",0), x+rnd(0,7,true), y+rnd(0,7,true));
			p.alpha = rnd(0.8, 1);
			p.setScale(rnd(0.1,0.2));
			p.ds = rnd(0,0.2);
			p.dsFrict = 0.7;
			p.rotation = rnd(0,6.28);
			p.playAnimAndKill(Assets.tiles, "fxHeroExplode", rnd(0.4,0.75));
			p.delayF = i<=3 ? 0 : i + irnd(0,2,true);
		}

		for(i in 0...8) {
			var p = alloc(getTile("fxShootLine"), x+rnd(0,2,true), y+rnd(0,2,true));
			p.alpha = rnd(0.4, 0.6);
			p.setScale(rnd(0.7,0.8));
			p.rotation = rnd(0,6.28);
			p.ds = rnd(0,0.2);
			p.dsFrict = 0.9;
			p.scaleMul = 0.9;
			p.delayF = i*0.5 + irnd(0,2,true);
			p.lifeF = rndSeconds(0.2, 0.4);
		}
	}

	public function explode(x:Float,y:Float) {
		var p = alloc(getTile("fxExplode",0), x+rnd(0,7,true), y+rnd(0,7,true));
		p.alpha = rnd(0.3, 0.4);
		p.setScale(rnd(1.6,1.8));
		p.ds = 0.3;
		p.dsFrict = 0.95;
		p.rotation = rnd(0, 0.2, true);
		p.playAnimAndKill(Assets.tiles, "fxExplode", rnd(0.4,0.75));

		for(i in 0...20)
			bubble(x,y,true);

		for(i in 0...15) {
			var p = alloc(getTile("fxExplode",0), x+rnd(0,7,true), y+rnd(0,7,true));
			p.alpha = rnd(0.8, 1);
			p.setScale(rnd(0.1,0.2));
			p.ds = rnd(0,0.2);
			p.dsFrict = 0.7;
			p.rotation = rnd(0,6.28);
			p.playAnimAndKill(Assets.tiles, "fxHeroExplode", rnd(0.4,0.75));
			p.delayF = i<=3 ? 0 : i + irnd(0,2,true);
		}

		for(i in 0...8) {
			var p = alloc(getTile("fxShootLine"), x+rnd(0,2,true), y+rnd(0,2,true));
			p.alpha = rnd(0.8, 1);
			p.setScale(rnd(1,1.5));
			p.rotation = rnd(0,6.28);
			p.ds = rnd(0,0.2);
			p.dsFrict = 0.9;
			p.scaleMul = 0.9;
			p.delayF = i*0.5 + irnd(0,2,true);
			p.lifeF = rndSeconds(0.2, 0.4);
		}
	}
}

