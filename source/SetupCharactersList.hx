package;


import flixel.FlxG;

class SetupCharactersList extends SickMenuState{
	override public function create(){
		options = TitleState.invalidCharacters;
		bgImage = 'menuBG';
		if (PlayState.inputEngineName == "Unspecified"){ // Really dumb way of checking but whatever

			try{

				var ps = new PlayState();
				ps.destroy();
			}catch(e){MainMenuState.handleError(e,"Something went wrong when trying to cache PlayState, please open a song first!");
			}
		}
		super.create();
	}
	override function goBack(){
		FlxG.switchState(new OtherMenuState());
	}
	override function select(sel:Int){
		selected=true;
		SetupCharacterState.selected = options[sel];
		FlxG.switchState(new SetupCharacterState());
	}
}
class SetupCharacterState extends MusicBeatState{
	static var selected:String = "";
	override public function create(){
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(if(Math.random() > 0.5) 'week54prototype' else "zzzzzzzz", 'shared'));
		bg.scale.x *= 1.55;
		bg.scale.y *= 1.55;
		bg.screenCenter();
		add(bg);
		
	}
}
