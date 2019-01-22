import mt.heaps.slib.*;
import mt.heaps.slib.assets.*;
import mt.deepnight.Sfx;

class Assets {
	public static var SBANK = mt.deepnight.Sfx.importDirectory("res/sfx");

	public static var music : Sfx;
	public static var font : h2d.Font;
	public static var tiles : SpriteLib;
	public static function init() {
		tiles = Atlas.load("tiles.atlas");
		font = hxd.Res.minecraftiaOutline.toFont();

		music = SBANK.music();
		Sfx.setGroupVolume(0, 1.0);
		Sfx.setGroupVolume(1, 1.0);
		// music.setChannel(1);
		// Sfx.setChannelVolume(0, 1);
		// Sfx.setChannelVolume(1, 1);
	}
}