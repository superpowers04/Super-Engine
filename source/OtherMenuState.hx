package;


import flixel.FlxG;

class OtherMenuState extends SickMenuState{
	override function create(){
		options = ["story mode","freeplay","Convert Charts from other mods","download charts","download characters"];
		descriptions = ['Play through the story mode', 'Play any song from the game', 'Convert charts from other mods to work here. Will put them in Multi Songs, will not be converted to work with FNF Multiplayer though.',"Download charts made for or ported to Super Engine","Download characters made for or ported to Super Engine"];
		if (TitleState.osuBeatmapLoc != '') {options.push("osu beatmaps"); descriptions.push("Play osu beatmaps converted over to FNF");}
		bgImage = 'menuBG';
		options.push("back"); descriptions.push("Go back to the main menu");
		super.create();
	} 
	override function select(sel:Int){
		selected=true;
		switch (options[sel]) {
			// case "Setup characters":
			// 	FlxG.switchState(new SetupCharactersList());
			case "download charts":
				FlxG.switchState(new ChartRepoState());
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
			case 'freeplay':
				FlxG.switchState(new FreeplayState());
			case 'osu beatmaps':
				FlxG.switchState(new osu.OsuMenuState());
			case "Convert Charts from other mods":
				FlxG.switchState(new ImportMod());
			case 'download characters':
				FlxG.switchState(new RepoState());
			
			case "back":
				goBack();
		}
	}
}