
import h2d.SpriteBatch;
class Level extends dn.Process {
	static final CHUNK_WID = 400;

	public var wid : Int;
	public var hei : Int;

	var lights : h2d.SpriteBatch;
	var clouds : h2d.SpriteBatch;

	var farSky : h2d.TileGroup;
	var farWrapper : h2d.Object;
	var farChunks : Array<h2d.TileGroup> = [];

	var bgWrapper : h2d.Object;
	var bgChunks : Array<h2d.TileGroup> = [];

	public var waterY : Int;
	var waves : Array<h2d.Bitmap>;
	var circles : Array<h2d.Bitmap>;
	var sun : HSprite;
	var sun2 : HSprite;

	static var WID : Int;
	static var HEI : Int;
	static var SPOTS : Map<String,Array<Point>>;
	static var FAST_SPOTS : Map<String,Bool>;

	public function new() {
		super(Game.ME);

		var time = haxe.Timer.stamp();

		createRootInLayers(Game.ME.scroller, 0);

		if( SPOTS==null ) {
			SPOTS = new Map();
			FAST_SPOTS = new Map();
			var bd = hxd.Res.level.toBitmap();
			wid = WID = bd.width;
			hei = HEI = bd.height;

			for(cx in 0...wid)
			for(cy in 0...hei) {
				var c = bd.getPixel(cx,cy) & 0x00FFFFFF;
				switch( c ) {
					case 0xFFFFFF : addSpot("wall",cx,cy); addSpot("coll",cx,cy);
					case 0xff0000 : addSpot("turret",cx,cy);
					case 0x42d188 : addSpot("splasher",cx,cy);
					case 0x00FF00 : addSpot("hero",cx,cy);
					case 0x5d5d5d : addSpot("check",cx,cy);
					case 0x825d3c : addSpot("door",cx,cy);
					case 0xffc000 : addSpot("liner",cx,cy);
					case 0x806000 : addSpot("linerDir",cx,cy);
					case 0x51b2ff : addSpot("waterLevel",cx,cy);
				}
			}
			bd.dispose();
		}
		else {
			wid = WID;
			hei = HEI;
		}
		initDoorColls();
		waterY = getSpot("waterLevel").cy;


		// Waves
		waves = [];
		var t = hxd.Res.wavesLoop.toTile();
		t.setSize(wid*Const.GRID+128, t.height);
		var tf = hxd.Res.wavesLoopFlip.toTile();
		tf.setSize(wid*Const.GRID+128, t.height);
		for(i in 0...4) {
			var t = i%2==0 ? t.clone() : tf.clone();
			var e = new h2d.Bitmap(t);
			Game.ME.scroller.add(e, i<=1 ? Const.DP_BG : Const.DP_WAVE_FRONT);
			waves.push(e);
			e.tileWrap = true;
			e.tile.setPosition( i*17 + irnd(0,30,true), 0 );
			e.alpha = 0.45 + i*0.2;
		}

		// Circles
		circles = [];
		var t = hxd.Res.waterCircles.toTile();
		t.setSize(wid*Const.GRID+128, t.height);
		for(i in 0...3) {
			var e = new h2d.Bitmap( t.clone() );
			Game.ME.scroller.add(e, Const.DP_BG);
			circles.push(e);
			e.scaleY = 2-i*0.25;
			e.tileWrap = true;
			e.tile.setPosition( i*17 + irnd(0,10,true), 0 );
			e.alpha = 0.04;
		}

		render();
	}


	override public function onDispose() {
		super.onDispose();
		sun.remove();
		sun2.remove();
		for(e in waves)
			e.remove();
		waves = null;
		for(e in circles)
			e.remove();
		circles = null;
	}


	public inline function coordId(x,y) return x+y*wid;

	public inline function hasSpot(k:String,x,y) return FAST_SPOTS.exists(k+coordId(x,y));
	public inline function getSpots(k) return SPOTS.exists(k) ? SPOTS.get(k) : [];
	public inline function getSpot(k) return SPOTS.exists(k) ? SPOTS.get(k)[0] : null;
	inline function addSpot(k,x,y) {
		if( !SPOTS.exists(k) )
			SPOTS.set(k, [new Point(x,y)]);
		else
			SPOTS.get(k).push( new Point(x,y) );
		FAST_SPOTS.set(k+coordId(x,y), true);
	}

	public function initDoorColls() {
		var all = getSpots("doorColl");
		for(pt in all)
			FAST_SPOTS.remove("doorColl"+coordId(pt.cx, pt.cy));
		SPOTS.remove("doorColl");
	}
	public function addDoorColl(x,y) {
		if( !hasSpot("doorColl",x,y) )
			addSpot("doorColl",x,y);
	}

	public function removeDoorColl(x,y) {
		var all = getSpots("doorColl");
		var i = 0;
		while(i<all.length) {
			if( all[i].cx==x && all[i].cy==y ) {
				FAST_SPOTS.remove("doorColl"+coordId(x,y));
				all.splice(i,1);
			}
			else
				i++;
		}
	}

	public inline function hasCollision(x,y) return x<0 || x>=wid || y<0 || y>=hei || hasSpot("coll", x,y) || hasSpot("doorColl",x,y);


	public function render() {
		root.removeChildren();

		for(c in farChunks) c.remove();
		farChunks = [];

		for(c in bgChunks) c.remove();
		bgChunks = [];

		farSky = new h2d.TileGroup(Assets.tiles.tile, root);
		farWrapper = new h2d.Object(root);

		sun = Assets.tiles.h_get("sun", 0.5, 0.85, root);
		sun.blendMode = Add;
		sun.y = waterY*Const.GRID;

		sun2 = Assets.tiles.h_get("sun", 0.5, 0.85, root);
		sun2.blendMode = Add;
		sun2.y = waterY*Const.GRID;

		clouds = new h2d.SpriteBatch(Assets.tiles.tile, root);
		clouds.hasRotationScale = true;

		bgWrapper = new h2d.Object(root);

		lights = new h2d.SpriteBatch(Assets.tiles.tile, root);
		lights.hasRotationScale = true;
		lights.blendMode = Add;

		// bg = new h2d.TileGroup(Assets.tiles.tile, root);

		var g = Const.GRID;

		addTg(farSky, "farSky", 0,0, 0,0, wid, waterY);
		addTg(farSky, "skyGrad", 0, (waterY-8)*Const.GRID, 0,0, wid);
		addTg(farSky, "far", 0,waterY*Const.GRID, 0,0, wid, hei-waterY);
		addTg(farSky, "waterGrad", 0,waterY*Const.GRID, 0,0, wid);

		for(cx in 0...wid)
		for(cy in 0...hei) {
			var x = cx*Const.GRID;
			var y = cy*Const.GRID;

			if( cx%3==0 && cy==waterY && Std.random(100)<80 ) {
				var e = addBatch(clouds, "cloud", x,y-rnd(5,20), 0.5, 1);
				e.scale = rnd(1,1.5);
			}

			if( cy==waterY && Std.random(100)<60 ) {
				for(i in 0...irnd(1,3)) {
					var e = addBatch(lights, "godLight", x+rnd(0,12,true),y);
					e.scaleX = rnd(0.6, 1);
					e.scaleY = rnd(0.6, 1);
					e.rotation = 0.1;
					e.alpha = rnd(0.05, 0.10);
				}
			}


			if( hasSpot("wall",cx,cy) ) {
				if( cx>=213 ) {
					for(i in 0...2 ) {
						var s = rnd(1, 1.5);
						addToChunks(bgChunks, "rockSand", x+rnd(0,3,true), y+i*3+rnd(0,3,true), 0,0, s,s, rnd(0,0.2,true));
					}
				}
				else if( cx>=150 ) {
					for(i in 0...2 ) {
						var s = rnd(1, 1.5);
						addToChunks(bgChunks, "rockRed", x+rnd(0,3,true), y+i*3+rnd(0,3,true), 0,0, s,s, rnd(0,0.5,true));
					}
				}
				else  {
					if( cy>=waterY+1 ) {
						addToChunks(farChunks, "fatDirt", x+g*0.5, y+g*0.5, 0.5,0.5, 1,1, rnd(0,M.PI2));
					}
					addToChunks(bgChunks, "dirt", x,y);

					if( cy<=waterY ) {
						for(i in 0...2 ) {
							var s = rnd(1, 1.5);
							addToChunks(bgChunks, "rockOut", x+rnd(0,3,true), y+i*3+rnd(0,3,true), 0,0, s,s);
						}
						if( Std.random(100)<20 )
							addToChunks(bgChunks, "bush", x+rnd(0,5,true), y+rnd(0,5,true));
					}
					else if( Std.random(100)<20 )
						for(i in 0...2 )
							addToChunks(bgChunks, "coral", x+rnd(0,3,true), y+rnd(0,3,true));
					else
						for(i in 0...2 ) {
							var s = rnd(1, 1.5);
							addToChunks(bgChunks, "rock", x+rnd(0,3,true), y+i*3+rnd(0,3,true), 0,0, s,s, rnd(0,0.5,true));
						}
				}

				if( cy>=waterY+5 && Std.random(100)<30 && ( !hasSpot("wall", cx+1, cy) || !hasSpot("wall", cx-1,cy) ) ) {
					var s = rnd(0.25, 1);
					addToChunks(bgChunks, "fatBubble", x+rnd(0,5,true), y+rnd(0,5,true), 0.5,0.5, s,s, 0, rnd(0.4,1));
				}
			}
		}

		addToChunks(bgChunks, "ending", 234*Const.GRID, 10*Const.GRID, 0.5,0.8);
	}

	inline function addToChunks(chunks:Array<h2d.TileGroup>, k:String, x:Float, y:Float, xr=0., yr=0., sx=1.0, sy=1.0, r=0., a=1.0) {
		var id = Std.int( x / CHUNK_WID );
		if( chunks[id]==null )
			chunks[id] = new h2d.TileGroup( Assets.tiles.tile, chunks==farChunks ? farWrapper : bgWrapper );

		var chunkX = id*CHUNK_WID;
		chunks[id].x = chunkX;
		chunks[id].setDefaultColor(0xffffff, a);
		chunks[id].addTransform(
			x-chunkX, y,
			sx, sy, r,
			Assets.tiles.getTileRandom(k, xr,yr)
		);
	}

	inline function addTg(tg:h2d.TileGroup, k:String, x:Float, y:Float, xr=0., yr=0., sx=1.0, sy=1.0, r=0., a=1.0) {
		tg.setDefaultColor(0xffffff, a);
		tg.addTransform(
			x,y,
			sx, sy, r,
			Assets.tiles.getTileRandom(k, xr,yr)
		);
	}

	inline function addBatch(sb:h2d.SpriteBatch, k:String, x:Float, y:Float, ?xr=0., ?yr=0.) : BatchElement {
		var e = new h2d.SpriteBatch.BatchElement( Assets.tiles.getTileRandom(k) );
		e.t.setCenterRatio(xr,yr);
		e.x = x;
		e.y = y;
		if( e.y>=waterY*Const.GRID ) {
			var c = dn.Color.intToRgb( dn.Color.interpolateInt(0xFFFFFF, 0x3E3993, 0.6) );
			e.r = c.r/255;
			e.g = c.g/255;
			e.b = c.b/255;
		}
		sb.add(e);
		return e;
	}


	override function postUpdate() {
		super.postUpdate();
		var pad = 32;
		for(c in bgChunks)
			c.visible = Game.ME.viewport.isOnScreenX(c.x, pad) || Game.ME.viewport.isOnScreenX(c.x+CHUNK_WID,pad);

		for(c in farChunks)
			c.visible = Game.ME.viewport.isOnScreenX(c.x, pad) || Game.ME.viewport.isOnScreenX(c.x+CHUNK_WID,pad);
	}

	override public function update() {
		super.update();
		var v = Game.ME.viewport;

		var i = 0;
		for(e in waves) {
			e.x -= i*0.2;
			while( e.x<-128 ) e.x+=128;
			e.y = waterY*Const.GRID-10 + i*(10-15*(v.y/(hei*Const.GRID))) + Math.cos(i*0.5+ftime*0.02)*3;
			//e.y = waterY*Const.GRID-7 + i*(10-Game.ME.viewport.y*0.040);
			i++;
		}

		var i = 1;
		for(e in circles) {
			e.x -= i*0.3;
			while( e.x<-128 ) e.x+=128;
			e.y = waterY*Const.GRID;
			i++;
		}
		sun.x = 370 - 0.5*Game.ME.scroller.x;
		sun2.x = 2000 - 0.5*Game.ME.scroller.x;

		clouds.x = -0.3*Game.ME.scroller.x;
	}
}