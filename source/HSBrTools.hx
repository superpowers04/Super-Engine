package;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flash.media.Sound;
import sys.io.File;
import flash.display.BitmapData;
import Xml;


using StringTools;

class HSBrTools {
	var path:String;
    var spriteArray:Map<String,FlxGraphic> = [];
	var xmlArray:Map<String,String> = [];
    var soundArray:Map<String,Sound> = [];
	public function new(_path:String){
        path = _path;
        if (!path.endsWith('/')) path = path + "/";
		trace('HSBrTools initialised in ${path}');
	}
    public function loadFlxSprite(x:Int,y:Int,pngPath:String):FlxSprite{
        if(spriteArray[pngPath] == null) spriteArray[pngPath] = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}${pngPath}'));
        return new FlxSprite(x, y).loadGraphic(spriteArray[pngPath]);
    }
	public function loadSparrowSprite(x:Int,y:Int,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24):FlxSprite{
        trace('${path}${pngPath}.png');
        if(spriteArray[pngPath + ".png"] == null) spriteArray[pngPath + ".png"] = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}${pngPath}.png'));
		var spr = new FlxSprite(x, y);
        if(xmlArray[pngPath + ".xml"] == null) xmlArray[pngPath + ".xml"] = File.getContent('${path}${pngPath}.xml');

        spr.frames= FlxAtlasFrames.fromSparrow(spriteArray[pngPath + ".png"],xmlArray[pngPath + ".xml"]);
        if (anim != ""){
            spr.animation.addByPrefix(anim,anim,fps,loop);
            spr.animation.play(anim);
        }
        return spr;
	}
    // public function loadSound(?x:Int=0,?y:Int=0,path:String):Sound{
    //     if(soundArray[path] == null) soundArray[path] = BitmapData.fromFile('${path}${pngName}'));
    //     return new FlxSprite(x, y).loadGraphic(spriteArray[path]);
    // }
    public function playSound(soundPath:String,?volume:Float = 1):FlxSound{
        if(soundArray[soundPath] == null) soundArray[soundPath] = Sound.fromFile('${path}${soundPath}');
        return FlxG.sound.play(soundArray[soundPath],volume);
    }
    public function cacheSound(soundPath:String){
        if(soundArray[soundPath] == null) soundArray[soundPath] = Sound.fromFile('${path}${soundPath}');
    }
    public function cacheSprite(pngPath:String){
        if(spriteArray[pngPath] == null) spriteArray[pngPath] = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}${pngPath}'));
    }
}