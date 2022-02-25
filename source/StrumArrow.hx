package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
// import flixel.math.FlxMath;
import flixel.util.FlxColor;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import flash.display.BitmapData;
import sys.io.File;

class StrumArrow extends FlxSprite{
	public static var defColor:FlxColor = 0xFFFFFFFF;
	var noteColor:FlxColor = 0xFFFFFFFF; 
	public var id:Int = 0; 
	static var path_:String = "mods/noteassets";
	override public function new(nid:Int = 0,?x:Float = 0,?y:Float = 0){
		super(x,y);
		id = nid;
		ID = nid;
	}

	public function changeSprite(?name:String = "default"){
		try{

		var curAnim = animation.curAnim.name;
		trace('Changing skin!');
		if (name == 'default' || (!FileSystem.exists('${path_}/${name}.png') || !FileSystem.exists('${path_}/${name}.xml'))){
			frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets.png')),File.getContent("assets/shared/images/NOTE_assets.xml"));
		}else{
			frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('${path_}/${name}.png')),File.getContent('${path_}/${name}.xml'));
		}
		animation.addByPrefix('static', 'arrow' + arrowIDs[id].toUpperCase());
		animation.addByPrefix('pressed', arrowIDs[id].toLowerCase() + ' press', 24, false);
		animation.addByPrefix('confirm', arrowIDs[id].toLowerCase() + ' confirm', 24, false);
		animation.play(curAnim);
		centerOffsets();
		}catch(e){
			MainMenuState.handleError('Error while changing sprite for arrow:\n ${e.message}');
		}
	}
	static var arrowIDs:Array<String> = ['left','down','up',"right"];
	public function init(){
		TitleState.loadNoteAssets();
		if (frames == null) {
			frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
		}
		// trace('Created new strumline');
		// animation.addByPrefix('green', 'arrowUP');
		// animation.addByPrefix('blue', 'arrowDOWN');
		// animation.addByPrefix('purple', 'arrowLEFT');
		// animation.addByPrefix('red', 'arrowRIGHT');

		antialiasing = true;
		setGraphicSize(Std.int(width * 0.7));

		// animation.addByPrefix('static', 'arrow' + arrowIDs[id].toUpperCase());
		// animation.addByPrefix('pressed', arrowIDs[id].toLowerCase() + ' press', 24, false);
		// animation.addByPrefix('confirm', arrowIDs[id].toLowerCase() + ' confirm', 24, false);
		switch (id)
		{
			case 0:
				animation.addByPrefix('static', 'arrowLEFT');
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
			case 1:
				animation.addByPrefix('static', 'arrowDOWN');
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 2:
				animation.addByPrefix('static', 'arrowUP');
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
				animation.addByPrefix('static', 'arrowRIGHT');
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		// switch (id){
		// 	case 0:
		// 		noteColor = FlxG.save.data.noteColorL;
		// 	case 1:
		// 		noteColor = FlxG.save.data.noteColorD;
		// 	case 2:
		// 		noteColor = FlxG.save.data.noteColorU;
		// 	case 3:
		// 		noteColor = FlxG.save.data.noteColorR;
		// }
	}
	public function playStatic(){
		// color = defColor;
		animation.play("static");
		centerOffsets();
	}
	public function press(){
		// if (color != noteColor) color = noteColor;
		animation.play("pressed");
		centerOffsets();
	}
	public function confirm(){
		// if (color != noteColor) color = noteColor;
		animation.play("confirm");

		centerOffsets();
		offset.x -= 13;
		offset.y -= 13;

	}

}