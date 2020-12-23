import hxd.Key;

class Game extends dn.Process {
	public static var ME : Game;

	var ctrl : dn.heaps.Controller.ControllerAccess;
	public var hero : en.Head;
	public var level : Level;
	public var scroller : h2d.Layers;
	public var fx : Fx;
	public var viewport : Viewport;
	var ctrap : h2d.Interactive;
	var dark : HSprite;

	public var curCheckPoint : Null<Point>;

	public var cm : dn.Cinematic;
	var mask : h2d.Bitmap;

	public function new() {
		super();

		ME = this;
		createRoot(Main.ME.root);
		ctrl = Main.ME.controller.createAccess("game");

		scroller = new h2d.Layers(root);
		scroller.x = 200;
		viewport = new Viewport(scroller);

		var actx = new h2d.Object();
		scroller.add(actx, Const.DP_FX);
		var nctx = new h2d.Object();
		scroller.add(nctx, Const.DP_FX);
		fx = new Fx(this, actx, nctx);

		ctrap = new h2d.Interactive(1,1, root);
		ctrap.onPush = onMouseDown;
		ctrap.onRelease = onMouseUp;

		dark = Assets.tiles.h_get("dark", root);
		dark.alpha = 0;

		mask = new h2d.Bitmap( h2d.Tile.fromColor(addAlpha(0x0),1,1), root);

		cm = new dn.Cinematic(Const.FPS);

		startLevel();
		delayer.addF(function() {
			#if !debug
			Assets.music.playOnGroup(1,true);
			#end
		},1);

		#if !debug
		cm.create({
			hero.goto(6,23)>end;
			hero.goto(7,18)>end;
			hero.setFrozen(true);
			showHelp(false)>end("help");
			hero.setFrozen(false);
		});
		#end

		tw.createMs(mask.alpha, 1>0, 2000);

		onResize();

		// #if debug
		new dn.heaps.StatsBox(this);
		// #end
	}

	function showHelp(complete:Bool) {
		cm.create({
			imageMessage("tutoBase", 0) > end;
			imageMessage("tutoShield", 0) > end;
			imageMessage("tutoShoot", 0) > end;
			imageMessage("tutoDeath", 0) > end;
			if( complete ) {
				imageMessage("tutoFreeze", 0) > end;
				message("Don't touch enemies or you will die.") > end;
			}
			else
				message("Press H at any time to view this help again.") > end;
			cm.signal("help");
		});
	}

	var curMsg : Null<h2d.Object>;
	public function message(str:String, ?col=0x151B3C) {
		clearMessage();

		var wrapper = new h2d.Object(root);
		curMsg = wrapper;

		var out = new h2d.Graphics(wrapper);
		out.beginFill(0xFFFFFF);

		var bg = new h2d.Graphics(wrapper);
		bg.beginFill(col);

		var t = new h2d.Text(Assets.font, wrapper);
		t.text = str;
		t.maxWidth = 200;
		t.dropShadow = { dx:0, dy:1, color:0x0, alpha:0.5 }

		var p = 5;
		out.drawRect(-p-1,-p-1, t.textWidth+p*2+2, t.textHeight+p*2+2);
		bg.drawRect(-p,-p, t.textWidth+p*2, t.textHeight+p*2);

		var tip = new h2d.Text(Assets.font, wrapper);
		tip.text = "Press SPACE to skip";
		tip.setPosition(t.textWidth-tip.textWidth, t.textHeight+p);
		tw.createMs(tip.alpha, 500|0>1, 1000);

		var b = wrapper.getBounds();
		wrapper.y = viewport.hei*0.5 - b.height*0.5 + rnd(0,30,true);
		tw.createMs(wrapper.x, -b.width>100, 800);
	}


	public function notify(str:String, c=0xffffff) {
		var t = new h2d.Text(Assets.font, root);
		t.text = str;
		t.textColor = c;
		t.dropShadow = { dx:0, dy:1, color:0x0, alpha:0.5 }
		t.x = viewport.wid*0.5 - t.textWidth*t.scaleX*0.5;
		tw.createMs(t.y, viewport.hei>viewport.hei-t.textHeight*t.scaleY-30, 150);

		var time = secToFrames(2);
		createChildProcess(function(p) {
			if( --time<=0 ) {
				p.destroy();
				tw.createMs(t.y, viewport.hei, 400).end( t.remove );
			}
		});
	}

	public function imageMessage(k:String, ?f=0) {
		clearMessage();

		var wrapper = new h2d.Object(root);
		curMsg = wrapper;

		var bg = new h2d.Graphics(wrapper);
		bg.beginFill(0x0, 0.7);
		bg.drawRect(0,0,viewport.wid, viewport.hei);

		var img = Assets.tiles.h_get(k,f, wrapper);
		img.setCenterRatio(0.5,0.5);
		img.setPosition( viewport.wid*0.5, viewport.hei*0.5 );

		var tip = new h2d.Text(Assets.font, wrapper);
		tip.text = "Press SPACE to skip";
		tip.setPosition(img.x-tip.textWidth*0.5, img.y+img.tile.height*0.5 + 20);
		tw.createMs(tip.alpha, 1000|0>1, 1000);

		tw.createMs(wrapper.alpha, 0>1, 600);
	}

	function clearMessage() {
		if( curMsg!=null ) {
			var e = curMsg;
			curMsg = null;
			tw.createMs(e.alpha, 0).end( e.remove );
		}
	}

	public inline function hasMsg() return curMsg!=null;
	public inline function isLocked() return hasMsg() || !cm.isEmpty() || cd.has("lock");


	var dtf : h2d.Text;
	function debug(str:Dynamic, ?col=0xFFFFFF) {
		if( dtf==null )
			dtf = new h2d.Text(Assets.font, root);
		dtf.text = Std.string(str);
		dtf.textColor = col;
		dtf.setPosition( viewport.wid-dtf.textWidth-10, 5 );
	}

	function startLevel() {
		if( level!=null ) {
			deathTimer = 0;

			for(e in Entity.ALL)
				e.destroy();
			for(e in Entity.GC)
				e.onDispose();
			Entity.GC = [];

			level.destroy();
		}

		level = new Level();

		#if debug
		//if( curCheckPoint==null ) setCheckPoint(220,9);
		#end

		for(pt in level.getSpots("door"))
			if( !level.hasSpot("door", pt.cx, pt.cy-1) && ( curCheckPoint==null || pt.cx>=curCheckPoint.cx ) ) {
				var h = 0;
				var y = pt.cy;
				while( level.hasSpot("door",pt.cx,y) ) {
					y++;
					h++;
				}
				new en.Door(pt.cx, pt.cy, h);
			}

		if( curCheckPoint==null ) {
			var pt = level.getSpot("hero");
			hero = new en.Head(pt.cx, pt.cy);
		}
		else {
			hero = new en.Head(curCheckPoint.cx-4, curCheckPoint.cy);
		}

		for(pt in level.getSpots("turret"))
			if( curCheckPoint==null || pt.cx>=curCheckPoint.cx )
				new en.m.SimpleTurret(pt.cx, pt.cy);

		for(pt in level.getSpots("liner"))
			if( curCheckPoint==null || pt.cx>=curCheckPoint.cx ) {
				var ang =
					if( level.hasSpot("linerDir", pt.cx, pt.cy-1) ) -1.57;
					else if( level.hasSpot("linerDir", pt.cx, pt.cy+1) ) 1.57;
					else if( level.hasSpot("linerDir", pt.cx+1, pt.cy) ) 0;
					else 3.14;
				new en.m.Liner(pt.cx, pt.cy, ang);
			}

		for(pt in level.getSpots("splasher"))
			if( curCheckPoint==null || pt.cx>=curCheckPoint.cx )
				new en.m.Splasher(pt.cx, pt.cy);
	}

	public function setCheckPoint(x,y) {
		curCheckPoint = new Point(x,y);
		notify("Checkpoint reached.");
	}

	override function onDispose() {
		if( ME==this )
			ME = null;
		ctrl.dispose();

		for( e in Entity.ALL )
			e.onDispose();
	}

	function onMouseDown(e:hxd.Event) {
		if( !hero.isDead() && hero.mouseControl )
			hero.setFrozen(true);
	}

	function onMouseUp(e:hxd.Event) {
		if( hero.mouseControl )
			hero.setFrozen(false);
	}

	override function onResize() {
		super.onResize();
		mask.scaleX = viewport.wid;
		mask.scaleY = viewport.hei;
		ctrap.scaleX = viewport.wid;
		ctrap.scaleY = viewport.hei;
		dark.scaleX = viewport.wid / dark.tile.width;
		dark.scaleY = viewport.hei / dark.tile.height;
	}

	override public function postUpdate() {
		super.postUpdate();
		// Assets.tiles.updateChildren(dt);
	}

	public function getMouse() {
		var gx = hxd.Window.getInstance().mouseX;
		var gy = hxd.Window.getInstance().mouseY;
		return {
			gx : gx,
			gy : gy,

			sx : (gx-scroller.x)/Const.UPSCALE,
			sy : (gy-scroller.y)/Const.UPSCALE,

			cx : Std.int( (gx-scroller.x)/Const.UPSCALE / Const.GRID ),
			cy : Std.int( (gy-scroller.y)/Const.UPSCALE / Const.GRID ),
		}
	}

	var deathTimer = 0;
	override function update() {
		super.update();

		ctrap.visible = hero.mouseControl;
		mask.visible = mask.alpha>0;

		cm.update(tmod);

		for( e in Entity.ALL ) {
			if( !e.destroyed )
				e.updateOnScreenStatus();
			if( !e.destroyed )
				e.update();
		}

		for( e in Entity.ALL )
			if( !e.destroyed )
				if( e.isOnScreen() )
					e.postUpdate();
				else
					e.outOfScreenUpdate();

		if( Entity.GC.length>0 ) {
			for( e in Entity.GC )
				e.onDispose();
			Entity.GC = [];
		}

		if( !hero.isDead() && ctrl.isKeyboardPressed(hxd.Key.R) )
			hero.hit(1000);

		// if( !hero.isDead() && ctrl.isKeyboardPressed(hxd.Key.I) ) {
		// 	if( mt.heaps.Controller.toggleInvert(AXIS_LEFT_Y) )
		// 		notify("Vertical gamepad inversion: ON");
		// 	else
		// 		notify("Vertical gamepad inversion: off");
		// }

		#if debug
		if( !hero.isDead() && ctrl.isKeyboardPressed(hxd.Key.K) ) {
			curCheckPoint = null;
			hero.hit(1000);
		}
		#end

		if( ctrl.aPressed() && curMsg!=null ) {
			cd.setF("lock", secToFrames(0.2));
			clearMessage();
			cm.signal();
		}

		if( ctrl.isKeyboardPressed(hxd.Key.H) && !isLocked() ) {
			showHelp(true);
		}

		if( ctrl.isKeyboardPressed(hxd.Key.M) ) {
			if( Assets.music.togglePlayPause() )
				notify("Music ON");
			else
				notify("Music OFF... oh rly? :(");
		}

		#if !js
		// Exit
		if( ctrl.isKeyboardPressed(Key.ESCAPE) )
			if( !cd.hasSetS("exitWarn",3) )
				notify("Press ESCAPE again to exit.");
			else
				hxd.System.exit();
		#end

		#if debug
		if( ctrl.isKeyboardPressed(hxd.Key.C) ) {
			var m = getMouse();
			debug(m.cx+","+m.cy+" "+scroller.x/Const.GRID);
		}
		#end

		if( hero.isDead() && ++deathTimer>=secToFrames(1) ) {
			for(e in en.Ring.ALL)
				fx.ringExplode(e.centerX, e.centerY);
			deathTimer = -9999;
			tw.createMs(mask.alpha, 0>1, 800).end( function() {
				startLevel();
				tw.createMs(mask.alpha, 0, 1000);
			});
		}

		if( hero.cy>=level.waterY+3 )
			dark.alpha += (0.9-dark.alpha)*0.04;
		else
			dark.alpha += (0-dark.alpha)*0.03;

		// Tuto
		if( hero.cx>=32 && !cd.hasSetF("frozenTuto", 999999) ) {
			cm.create({
				hero.setFrozen(true);
				imageMessage("tutoFreeze")>end;
				hero.setFrozen(false);
			});
		}
		if( !cd.has("warnContact") && hero.distSqrFree(32*Const.GRID, 28*Const.GRID)<=M.pow(Const.GRID*3,2) ) {
			var any = false;
			for(e in en.Mob.ALL)
				if( e.cx<=41 && !e.isDead() ) {
					any = true;
					break;
				}
			if( !any ) {
				cd.setF("warnContact", 999999);
				cm.create({
					hero.setFrozen(true);
					message("Also, don't touch enemies or you will explode.") > end;
					hero.setFrozen(false);
				});
			}
		}
		if( hero.cx>=238 && !cd.hasSetF("ending", 999999) ) {
			cm.create({
				hero.setFrozen(true);
				message("Thank you for playing!") > end;
				message("A 48h game by Sebastien Benard for Ludum Dare 35 (theme: Shapeshift)") > end;
				message("More games on DEEPNIGHT.NET.") > end;
				1500;
				message("I need some sleep.") > end;
				1000;
				message("It's 3am here...") > end;
				message("I wish I had more time!") > end;
				500;
				message("I would also appreciate some coffee.") > end;
				message("Coffee is nice.") > end;
				500;
				message("Coffee is friend.") > end;
				1500;
				message("Are you still here?") > end;
				message("This can last forever you know.") > end;
				message("You really should go now.") > end;
				hero.setFrozen(false);
			});
		}

	}

}
