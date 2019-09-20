package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];


	private function new(x,y) {
		super(x,y);
		spr.set("mob");
		circColRadius = Const.GRID;
		ALL.push(this);
		weight = 999;
	}

	override public function hit(dmg, ?from:Entity) {
		super.hit(dmg, from);
		fx.hit(centerX, centerY, from!=null?from.angTo(this):null);
		Assets.SBANK.hit2(0.5);
	}

	var prepareCb : Void->Void;
	function prepare(d:Float, cb:Void->Void) {
		prepareCb = cb;
		cd.setF("preparing", d);
	}

	override function onDie() {
		super.onDie();
		fx.explode(centerX, centerY);
		viewport.shake(rnd(3,4), 1);
	}

	override public function onDispose() {
		super.onDispose();
		ALL.remove(this);
	}

	override public function postUpdate() {
		super.postUpdate();
		if( cd.has("preparing") )
			fx.prepare(spr.x, spr.y, 1-cd.getRatio("preparing"));
	}

	override public function update() {
		super.update();

		if( prepareCb!=null && !cd.has("preparing") ) {
			prepareCb();
			prepareCb = null;
		}
	}
}