package;
// About 90% of code used from OfflineMenuState
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import SEInputText as FlxInputText;

import sys.io.File;
import sys.FileSystem;

using StringTools;
class TextBoxSubstate extends MusicBeatSubState{
	var retText = "";
	var questionText = "";
	var textBox:FlxInputText;
	override function new(x:Int,y:Int,text:String){
		super(0,0);
		questionText = text;
	}
	override function create()
	{
		super();
		var bg:FlxSprite = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
		bg.alpha = 0.0;
		add(bg);
		var infoText = FlxText
        FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});
        FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
	}
	override function update(elapsed:Float){
		super.update(elapsed);

	}
}