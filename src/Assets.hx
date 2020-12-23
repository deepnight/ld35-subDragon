import dn.heaps.assets.*;
import dn.heaps.Sfx;

class Assets {
	public static var SBANK = SfxDirectory.load("sfx");

	public static var music : Sfx;
	public static var font : h2d.Font;
	public static var tiles : SpriteLib;
	public static function init() {
		tiles = Atlas.load("tiles.atlas");
		font = hxd.Res.minecraftiaOutline.toFont();

		music = new Sfx(hxd.Res.music);
		Sfx.setGroupVolume(0, 1.0);
		Sfx.setGroupVolume(1, 0.66);
		// music.setChannel(1);
		// Sfx.setChannelVolume(0, 1);
		// Sfx.setChannelVolume(1, 1);
	}
}