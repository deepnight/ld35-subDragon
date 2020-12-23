class Const {
	public static var FPS = 40;
	public static var GP_FPS = 30;
	public static var UPSCALE = 4; // auto-set in Game.onResize()
	public static var GUARANTEED_HEI = 280; // auto-set in Game.onResize()
	public static var GRID = 16;
	public static var INFINITE = 9999999;

	static var uniq=0;
	public static var DP_FAR = uniq++;
	public static var DP_BG = uniq++;
	public static var DP_ENTITY = uniq++;
	public static var DP_WAVE_FRONT = uniq++;
	public static var DP_FX = uniq++;
	public static var DP_BULLET = uniq++;
}