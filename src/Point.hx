class Point {
	public var cx : Int;
	public var cy : Int;

	public var centerX(get,never) : Float; inline function get_centerX() return (cx+0.5)*Const.GRID;
	public var centerY(get,never) : Float; inline function get_centerY() return (cy+0.5)*Const.GRID;

	public function new(x,y) {
		cx = x;
		cy = y;
	}
}