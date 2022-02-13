package;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;
import flash.display.BitmapData;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	var vanIcon:Bool = false;
	var isPlayer:Bool = false;
	var isMenuIcon:Bool = false;
	// public var pathh = "mods/characters";

	public function new(?char:String = 'bf', ?isPlayer:Bool = false,?clone:String = "",?isMenuIcon:Bool = false,?path:String = "mods/characters")
	{
		super();
		this.isPlayer = isPlayer;
		this.isMenuIcon = isMenuIcon;
		changeSprite(char,"",path);
	}

	public function updateAnim(health:Float){
		if (health < 20)
			animation.curAnim.curFrame = 1;
		else
			animation.curAnim.curFrame = 0;
	}

	public function changeSprite(?char:String = 'bf',?clone:String = "face",?useClone:Bool = true,?pathh:String = "mods/characters")
	{
		var path = pathh + "/";
		var chars:Array<String> = ["bf","spooky","pico","mom","mom-car",'parents-christmas',"senpai","senpai-angry","spirit","spooky","bf-pixel","gf","dad","monster","monster-christmas","parents-christmas","bf-old","gf-pixel","gf-christmas","face","tankman"];
		var relAnims:Bool = true;
		if (!chars.contains(char) &&FileSystem.exists(path+char+"/healthicon.png")){
			// trace('Custom character with custom icon! Loading custom icon.');
			loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}$char/healthicon.png')), true, 150, 150);
			char = "bf";
			vanIcon = false;
		}else if ((chars.contains(char) || chars.contains(clone)) && FileSystem.exists(path+char+"/icongrid.png")){
			// trace('Custom character with custom icongrid! Loading custom icon.');
			loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}$char/icongrid.png')), true, 150, 150);
			if (clone != "") char = clone;
			vanIcon = false;
		}else{
			if (clone != "" && (useClone || !chars.contains(char))) char = clone;
			if (!vanIcon) loadGraphic(Paths.image('iconGrid'), true, 150, 150); else relAnims = false;
			vanIcon = true;
		}
		
		antialiasing = true;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		if(chars.contains(char.toLowerCase())){ // For vanilla characters
			if (relAnims){
				animation.add('bf-car', [0, 1], 0, false, isPlayer);
				animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
				animation.add('bf-pixel', [21, 21], 0, false, isPlayer);
				animation.add('spooky', [2, 3], 0, false, isPlayer);
				animation.add('pico', [4, 5], 0, false, isPlayer);
				animation.add('mom', [6, 7], 0, false, isPlayer);
				animation.add('mom-car', [6, 7], 0, false, isPlayer);
				animation.add('tankman', [8, 9], 0, false, isPlayer);
				animation.add('face', [10, 11], 0, false, isPlayer);
				animation.add('dad', [12, 13], 0, false, isPlayer);
				animation.add('senpai', [22, 22], 0, false, isPlayer);
				animation.add('senpai-angry', [22, 22], 0, false, isPlayer);
				animation.add('spirit', [23, 23], 0, false, isPlayer);
				animation.add('bf-old', [14, 15], 0, false, isPlayer);
				animation.add('gf', [16], 0, false, isPlayer);
				animation.add('gf-christmas', [16], 0, false, isPlayer);
				animation.add('gf-pixel', [16], 0, false, isPlayer);
				animation.add('parents-christmas', [17, 18], 0, false, isPlayer);
				animation.add('monster', [19, 20], 0, false, isPlayer);
				animation.add('monster-christmas', [19, 20], 0, false, isPlayer);
			}
			animation.play(char.toLowerCase());
		}else{trace('Invalid character icon $char, Using BF!');animation.play("bf");}
		switch(char)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				antialiasing = false;
		}

		scrollFactor.set();
		if(isMenuIcon) offset.set(75,75);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
