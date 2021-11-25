package;
// About 90% of code used from OfflineMenuState
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;

import sys.io.File;
import sys.FileSystem;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class ArrowSelection extends SearchMenuState
{
	public var playerStrums:FlxTypedGroup<StrumArrow> = new FlxTypedGroup<StrumArrow>();
	function generateStaticArrows(player:Int):Void
	{

		for (i in 0...PlayState.keyAmmo[PlayState.mania])
		{
			// FlxG.log.add(i);
			var babyArrow:StrumArrow = new StrumArrow(i,0, if (FlxG.save.data.downscroll) FlxG.height - 165 else 50);

			babyArrow.init();
			babyArrow.x += Note.swagWidth * i + i;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();


			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			// babyArrow.ID = i;

			
			playerStrums.add(babyArrow);
			

			babyArrow.playStatic(); 
			// Todo, clean this shitty code up
			babyArrow.x += 50;

			babyArrow.x += (FlxG.width / 4) * 1;
			babyArrow.y += 200;
			



			// strumLineNotes.add(babyArrow);
		}
	}
	override function create()
	{try{
		{ // Looks for all notes, This will probably be rarely accessed, so loading like this shouldn't be a problem
			searchList = ["default"];
			var dataDir:String = Sys.getCwd() + "mods/noteassets/";
			var customArrows:Array<String> = [];
			if (FileSystem.exists(dataDir))
			{
				for (file in FileSystem.readDirectory(dataDir))
				{
					if (file.endsWith(".png") && !file.endsWith("-bad.png") && !file.endsWith("splash.png")){
						var name = file.substr(0,-4);
						if (FileSystem.exists('${dataDir}${name}.xml'))
						{
							customArrows.push(name);

						}
					}
				}
			}else{MainMenuState.handleError('mods/noteassets is not a folder!');}
			// customCharacters.sort((a, b) -> );
			haxe.ds.ArraySort.sort(customArrows, function(a, b) {
						if(a < b) return -1;
						else if(b > a) return 1;
						else return 0;
					});
			for (char in customArrows){
				searchList.push(char);
			}
		}
		generateStaticArrows(1);
		super.create();
		add(playerStrums);

	}catch(e) MainMenuState.handleError('Error with notesel "create" ${e.message}');}
	override function changeSelection(change:Int = 0){
		super.changeSelection(change);
		playerStrums.forEach(
			function(arrow:StrumArrow){
				arrow.changeSprite(songs[curSelected]);
				arrow.playStatic(); 
			}
		);
	}
	override function select(sel:Int = 0){
		FlxG.save.data.noteAsset = songs[curSelected];
	}
	/*override function extraKeys(){
		if (FlxG.keys.justPressed.ONE){PlayState.mania = 0;trace('mania = ${PlayState.mania}');}
		if (FlxG.keys.justPressed.TWO){PlayState.mania = 1;trace('mania = ${PlayState.mania}');}
		if (FlxG.keys.justPressed.THREE){PlayState.mania = 2;trace('mania = ${PlayState.mania}');}
		if (FlxG.keys.justPressed.FOUR){PlayState.mania = 3;trace('mania = ${PlayState.mania}');}
	}it doesn't work and if you press it you can't go back in ArrowSelectoion until you play any song*/
}