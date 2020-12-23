package en;

class Door extends Entity {
	var parts : Array<HSprite> = [];
	var top : HSprite;
	var bot : HSprite;
	var hei : Int;
	public function new(x,y, h) {
		super(x,y);
		lCollisions = false;
		hei = h;
		floating = false;
		spr.set("empty");
		spr.setCenterRatio(0,0);
		//spr.scaleY = hei;

		top = Assets.tiles.h_get("doorTop");
		Game.ME.scroller.add(top, Const.DP_BG);
		bot = Assets.tiles.h_get("doorBot");
		Game.ME.scroller.add(bot, Const.DP_BG);

		for(d in 0...hei) {
			level.addDoorColl(cx,cy+d);
			var e = Assets.tiles.h_get("door");
			parts.push(e);
			Game.ME.scroller.add(e, Const.DP_BG);
		}
	}

	override public function onDispose() {
		super.onDispose();

		for(e in parts)
			e.remove();
		parts = null;
		top.remove();
		bot.remove();
	}

	override function outOfScreenUpdate() {
		super.outOfScreenUpdate();
		top.visible = false;
		bot.visible = false;
		for(p in parts)
			p.visible = false;
	}

	override public function postUpdate() {
		super.postUpdate();

		top.visible = spr.visible;
		top.setPosition(cx*Const.GRID, (cy-1)*Const.GRID);

		bot.visible = spr.visible;
		bot.setPosition(cx*Const.GRID, (cy+hei)*Const.GRID);

		var i = 0;
		for(e in parts) {
			e.visible = spr.visible;
			e.setPosition(cx*Const.GRID, (cy+i)*Const.GRID);
			i++;
		}
	}

	public function open() {
		cd.setS("open",99999);

		for(d in 0...hei) {
			parts[d].x += rnd(1,3,true);
			parts[d].y += rnd(1,3,true);
			Game.ME.delayer.addMs( function() {
				parts[d].visible = false;
				fx.explode(centerX, (cy+d)*Const.GRID);
				if( !cd.hasSetF("sfx", secToFrames(0.1)) )
					Assets.SBANK.explosion4(0.2);
			}, d*200);
		}

		if( !level.destroyed )
			for(d in 0...hei)
				level.removeDoorColl(cx,cy+d);
	}

	override public function update() {
		super.update();

		if( !cd.has("open") ) {
			var any = false;
			for(e in en.Mob.ALL)
				if( e.cx<cx ) {
					any = true;
					break;
				}

			if( !any )
				open();
		}
	}
}