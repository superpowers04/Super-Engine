package se.objects;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.FlxState;
import flixel.FlxSprite;
import TitleState;

@:publicFields class Stage extends FlxGroup{
	var objects:Array<Dynamic<FlxObject>> = [];
	var bfPos:Array<Float> =  [0,0];
	var dadPos:Array<Float> = [0,0];
	var gfPos:Array<Float> =  [0,0];
	var tags:Array<String> = [];
	var jsonFile:String;
	var showGF:Bool = true;
	var defaultCamZoom:Float = 0.9;
	var name:String = "";
	var interps:Array<Dynamic> = []; 
	var stageInfo:StageInfo;
	// TODO MAKE LESS SHIT
	function callInterp(state:ScriptMusicBeatState, name:String,args:Array<Dynamic>){
		for (interp in interps){
			state.callSingleInterp(name,args,this.name,interp);
		}
	}
	function apply(state:FlxState,boyfriend:Character,dad:Character,gf:Character){
		if(boyfriend != null) {
			boyfriend.x+=bfPos[0];
			boyfriend.y+=bfPos[1];
		}
		if(dad != null) {
			dad.x+=dadPos[0];
			dad.y+=dadPos[1];
		}
		if(gf != null) {
			gf.x+=gfPos[0];
			gf.y+=gfPos[1];
		}
		if(state is PlayState){
			final state:PlayState = cast state;
			state.defaultCamZoom = defaultCamZoom;
			PlayState.stageTags = tags;
			PlayState.curStage = name;
			PlayState.stageInfo = stageInfo;
		}
		if(state is ScriptMusicBeatState){
			
			callInterp(cast state,'apply',[this]);
		}

	}
	function unload(state:FlxState, boyfriend:Character, dad:Character, gf:Character){
		if(boyfriend != null) {
			boyfriend.x-=bfPos[0];
			boyfriend.y-=bfPos[1];
		}
		if(dad != null) {
			dad.x-=dadPos[0];
			dad.y-=dadPos[1];
		}
		if(gf != null) {
			gf.x-=gfPos[0];
			gf.y-=gfPos[1];
		}
		if(state is ScriptMusicBeatState){
			callInterp(cast state,'unload',[this]);
		}
	}

}
/* TODO REMOVE Paths REFERENCES*/
class BaseStage extends Stage{
	override function callInterp(state:ScriptMusicBeatState, name:String,args:Array<Dynamic>){}
	public function new(?simple:Bool = false){
		super();
		defaultCamZoom = 0.9;
		name = 'stage';
		tags = ["inside","stage"];
		if(simple) {
			tags.push('performance');
			tags.push('simple');
		}else {
			final bg:FlxSprite = SELoader.loadFlxSprite(-600, -200,'assets/shared/images/stageback.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);
		}
		final stageFront:FlxSprite = SELoader.loadFlxSprite(-650, 600,'assets/shared/images/stagefront.png');
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);
		if(!simple){
			final stageCurtains:FlxSprite = SELoader.loadFlxSprite(-500, -300,'assets/shared/images/stagecurtains.png');
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			add(stageCurtains);
		}
	}
}