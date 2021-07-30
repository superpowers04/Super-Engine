package;

import flixel.FlxG;

class OtherMenuState extends SickMenuState{
	override function create(){
		options = ["story mode","freeplay"];
		descriptions = ['Play through the story mode', 'Play any song from the game'];
		if (TitleState.osuBeatmapLoc != '') options.push("osu beatmaps"); descriptions.push("Play osu beatmaps converted over to FNF");

		options.push("back"); descriptions.push("Go back to the main menu");
		super.create();
	}
	override function select(sel:Int){
		switch (options[sel]) {
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
			case 'freeplay':
				FlxG.switchState(new FreeplayState());
			case 'osu beatmaps':
				FlxG.switchState(new osu.OsuMenuState());
			
			case "back":
				goBack();
		}
	}
}