package;

import flixel.FlxG;

class OtherMenuState extends SickMenuState{
	override function create(){
		options = ["story mode","freeplay","Convert Charts from other mods"];
		descriptions = ['Play through the story mode', 'Play any song from the game', 'Convert charts from other mods to work here. Will put them in Multi Songs, will not be converted to work with FNF Multi though.'];
		if (TitleState.osuBeatmapLoc != '') {options.push("osu beatmaps"); descriptions.push("Play osu beatmaps converted over to FNF");}
		bgImage = 'menuBG';
		options.push("back"); descriptions.push("Go back to the main menu");
		super.create();
		bg.color = 0xccccccff;
	}
	override function select(sel:Int){
		selected=true;
		switch (options[sel]) {
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
			case 'freeplay':
				FlxG.switchState(new FreeplayState());
			case 'osu beatmaps':
				FlxG.switchState(new osu.OsuMenuState());
			case "Convert Charts from other mods":
				FlxG.switchState(new ImportMod());
			
			case "back":
				goBack();
		}
	}
}