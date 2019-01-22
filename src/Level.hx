import mt.MLib;
import h2d.SpriteBatch;
import mt.heaps.slib.*;

class Level extends mt.Process {
	public var wid : Int;
	public var hei : Int;
	var spots : Map<String,Array<Point>>;
	var fastSpots : Map<String,Bool>;

	var lights : h2d.SpriteBatch;
	var far : h2d.SpriteBatch;
	var clouds : h2d.SpriteBatch;
	var bg : h2d.SpriteBatch;
	public var waterY : Int;
	var waves : Array<h2d.Bitmap>;
	var circles : Array<h2d.Bitmap>;
	var sun : HSprite;
	var sun2 : HSprite;

	public function new() {
		super(Game.ME);

		createRootInLayers(Game.ME.scroller, 0);
		spots = new Map();
		fastSpots = new Map();

		var bd = hxd.Res.level.toBitmap();
		wid = bd.width;
		hei = bd.height;
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
				case 0x51b2ff : waterY = cy;
			}
		}
		bd.dispose();

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


		// Circles
		//var t = hxd.Res.waterCircles.toTile();
		//t.setSize(wid*Const.GRID, t.height);
		//var e = new h2d.Bitmap( t.clone() );
		//Game.ME.scroller.add(e, Const.DP_BG);
		//e.tileWrap = true;
		//e.y = Const.GRID*waterY;
		//e.alpha = 0.1;

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

	public inline function hasSpot(k:String,x,y) return fastSpots.exists(k+coordId(x,y));
	public inline function getSpots(k) return spots.exists(k) ? spots.get(k) : [];
	public inline function getSpot(k) return spots.exists(k) ? spots.get(k)[0] : null;
	public inline function addSpot(k,x,y) {
		if( !spots.exists(k) )
			spots.set(k, [new Point(x,y)]);
		else
			spots.get(k).push( new Point(x,y) );
		fastSpots.set(k+coordId(x,y), true);
	}

	public function removeCollision(x,y) {
		var all = getSpots("coll");
		var i = 0;
		while(i<all.length) {
			if( all[i].cx==x && all[i].cy==y ) {
				fastSpots.remove("coll"+coordId(x,y));
				all.splice(i,1);
			}
			else
				i++;
		}

	}

	public inline function hasCollision(x,y) return x<0 || x>=wid || y<0 || y>=hei || hasSpot("coll", x,y);


	public function render() {
		root.removeChildren();

		far = new h2d.SpriteBatch(Assets.tiles.tile, root);
		far.hasRotationScale = true;


		sun = Assets.tiles.h_get("sun", 0.5, 0.85, root);
		sun.blendMode = Add;
		sun.y = waterY*Const.GRID;

		sun2 = Assets.tiles.h_get("sun", 0.5, 0.85, root);
		sun2.blendMode = Add;
		sun2.y = waterY*Const.GRID;

		clouds = new h2d.SpriteBatch(Assets.tiles.tile, root);
		clouds.hasRotationScale = true;

		lights = new h2d.SpriteBatch(Assets.tiles.tile, root);
		lights.hasRotationScale = true;
		lights.blendMode = Add;
		//far.filters.push( new h2d.filter.Displacement(hxd.Res.disp.toTile()) );

		bg = new h2d.SpriteBatch(Assets.tiles.tile, root);
		bg.hasRotationScale = true;

		var g = Const.GRID;

		var e = add(far, "farSky", 0,0);
		e.scaleX = wid;
		e.scaleY = waterY;

		var e = add(far, "skyGrad", 0, (waterY-8)*Const.GRID);
		e.scaleX = wid;

		var e = add(far, "far", 0,waterY*Const.GRID);
		e.scaleX = wid;
		e.scaleY = hei-waterY;

		var e = add(far, "waterGrad", 0,waterY*Const.GRID);
		e.scaleX = wid;


		for(cx in 0...wid)
		for(cy in 0...hei) {
			var x = cx*Const.GRID;
			var y = cy*Const.GRID;

			if( cx%3==0 && cy==waterY && Std.random(100)<80 ) {
				var e = add(clouds, "cloud", x,y-rnd(5,20), 0.5, 1);
				e.scale = rnd(1,1.5);
				//e.alpha = rnd(0.4, 0.7);
			}

			if( cy==waterY && Std.random(100)<60 ) {
				for(i in 0...irnd(1,3)) {
					var e = add(lights, "godLight", x+rnd(0,12,true),y);
					e.scaleX = rnd(0.6, 1);
					e.scaleY = rnd(0.6, 1);
					e.rotation = 0.1;
					e.alpha = rnd(0.05, 0.10);
				}
			}


			//if( cy==hei-1 ) {
				//for(i in 0...3) {
					//var e = add(bg, "bgWeed", x+rnd(0,Const.GRID*0.5,true), y, 0, 0.9);
					//e.alpha = rnd(0.2, 0.5);
				//}
			//}


			if( hasSpot("wall",cx,cy) ) {
				if( cx>=213 ) {
					for(i in 0...2 ) {
						var e = add(bg, "rockSand", x+rnd(0,3,true), y+i*3+rnd(0,3,true));
						e.rotation = rnd(0,0.2,true);
						e.scale = rnd(1, 1.5);
					}
				}
				else if( cx>=150 ) {
					for(i in 0...2 ) {
						var e = add(bg, "rockRed", x+rnd(0,3,true), y+i*3+rnd(0,3,true));
						e.rotation = rnd(0,0.5,true);
						e.scale = rnd(1, 1.5);
					}
				}
				else  {
					if( cy>=waterY+1 ) {
						var e = add(far, "fatDirt", x+g*0.5,y+g*0.5, 0.5,0.5);
						e.rotation = rnd(0,6.28);
						//e.alpha = rnd(0.4, 0.6);
					}
					add(bg, "dirt", x,y);

					if( cy<=waterY ) {
						for(i in 0...2 ) {
							var e = add(bg, "rockOut", x+rnd(0,3,true), y+i*3+rnd(0,3,true));
							e.scale = rnd(1, 1.5);
						}
						if( Std.random(100)<20 )
							add(bg, "bush", x+rnd(0,5,true), y+rnd(0,5,true));
					}
					else if( Std.random(100)<20 )
						for(i in 0...2 )
							add(bg, "coral", x+rnd(0,3,true), y+rnd(0,3,true));
					else
						for(i in 0...2 ) {
							var e = add(bg, "rock", x+rnd(0,3,true), y+i*3+rnd(0,3,true));
							e.rotation = rnd(0,0.5,true);
							e.scale = rnd(1, 1.5);
						}
				}

				if( cy>=waterY+5 && Std.random(100)<30 && ( !hasSpot("wall", cx+1, cy) || !hasSpot("wall", cx-1,cy) ) ) {
					var e = add(bg, "fatBubble", x+rnd(0,5,true), y+rnd(0,5,true), 0.5,0.5);
					e.scale = rnd(0.25, 1);
					e.alpha = rnd(0.4, 1);
				}
			}
		}

		var e = add(bg, "ending", 234*Const.GRID, 10*Const.GRID, 0.5,0.8);
	}

	function add(sb:h2d.SpriteBatch, k:String, x:Float, y:Float, ?xr=0., ?yr=0.) : BatchElement {
		var e = new h2d.SpriteBatch.BatchElement( Assets.tiles.getTileRandom(k) );
		e.t.setCenterRatio(xr,yr);
		e.x = x;
		e.y = y;
		if( e.y>=waterY*Const.GRID ) {
			var c = mt.deepnight.Color.intToRgb( mt.deepnight.Color.interpolateInt(0xFFFFFF, 0x3E3993, 0.6) );
			e.r = c.r/255;
			e.g = c.g/255;
			e.b = c.b/255;
		}
		//e.x = x - e.t.width*xr;
		//e.y = y - e.t.height*yr;
		sb.add(e);
		return e;
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
		sun.x = 370 - 0.5*Game.ME.scroller.x/Const.UPSCALE;
		sun2.x = 2000 - 0.5*Game.ME.scroller.x/Const.UPSCALE;

		clouds.x = -0.3*Game.ME.scroller.x/Const.UPSCALE;
	}
}