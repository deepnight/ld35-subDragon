package en.m;

import mt.heaps.slib.*;
import mt.deepnight.Lib;
import mt.MLib;

class Splasher extends en.Mob {
	var dirt : HSprite;

	public function new(x,y) {
		super(x,y);
		spr.set("splasher");
		initLife(8);
		cd.setS("shoot", 2);

		dirt = Assets.tiles.h_get("splasherDirt",0, 0.5,0.5);
		Game.ME.scroller.add(dirt, Const.DP_ENTITY);
	}

	override public function onDispose() {
		super.onDispose();
		dirt.remove();
	}

	override function onDie() {
		super.onDie();
		Assets.SBANK.explosion2(0.7);
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.scaleX = 0.9 + 0.06*Math.cos(utime*0.05);
		spr.scaleY = 0.9 + 0.06*Math.cos(1.9+utime*0.08);
		spr.rotation = 0.1*Math.sin(utime*0.02);

		dirt.setPosition(spr.x, spr.y);
		//dirt.alpha = 0.9 + 0.05 * Math.cos(utime*0.1);
		dirt.rotation = spr.rotation;
		dirt.scaleX = spr.scaleX + 0.05*Math.cos(utime*0.06);
		dirt.scaleY = spr.scaleY + 0.05*Math.cos(utime*0.06);
	}

	override public function update() {
		super.update();

		var range = Const.GRID*11;

		dirt.visible = !cd.has("shootRecent");

		if( distSqr(hero)<=range*range*1.2*1.2 && !cd.hasSetF("shoot", secToFrames(5)) ) {
			prepare( secToFrames(1), function() {
				cd.setS("shootRecent", cd.getS("shoot")*0.5);
				var n = 20;
				for(i in 0...n) {
					var e = new en.Bullet(centerX, centerY);
					var a = 6.28*i/n;
					var s = 0.085*2;
					e.setRange(range);
					e.dx = Math.cos(a)*s;
					e.dy = Math.sin(a)*s;
				}
			});
		}
	}
}
