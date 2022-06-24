package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
// import flixel.math.FlxMath;
import flixel.util.FlxColor;
import sys.FileSystem;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flash.display.BitmapData;
import sys.io.File;

class StrumArrow extends FlxSprite{
	public static var defColor:FlxColor = 0xFFFFFFFF;
	var noteColor:FlxColor = 0xFFFFFFFF; 
	public var id:Int = 0; 
	override public function new(nid:Int = 0,?x:Float = 0,?y:Float = 0){
		super(x,y);
		id = nid;
		ID = nid;
	}

	public function changeSprite(?name:String = "default",?_frames:FlxAtlasFrames,?anim:String = "",?setFrames:Bool = true,path_:String = "mods/noteassets"){
		try{
			var curAnim = if(anim == "" && animation.curAnim != null) animation.curAnim.name else anim;
			if(setFrames && (_frames != null || name != "")){
				if(_frames == null){
					if(name == "skin"){
						frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
					}else if (name == 'default' || (!FileSystem.exists('${path_}/${name}.png') || !FileSystem.exists('${path_}/${name}.xml'))){
						frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets.png')),File.getContent("assets/shared/images/NOTE_assets.xml"));
					}else{
						frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('${path_}/${name}.png')),File.getContent('${path_}/${name}.xml'));
					}
				}else{
					frames = _frames;
				}
			}
			frames = frames.addBorder(new FlxPoint(1,1));
			antialiasing = true;
			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			animation.addByPrefix('static', 'arrow' + arrowIDs[id].toUpperCase());
			animation.addByPrefix('pressed', arrowIDs[id].toLowerCase() + ' press', 24, false);
			animation.addByPrefix('confirm', arrowIDs[id].toLowerCase() + ' confirm', 24, false);
			animation.play(curAnim);
			centerOffsets();
		}catch(e){MainMenuState.handleError(e,'Error while changing sprite for arrow:\n ${e.message}');
		}
	}
	static var arrowIDs:Array<String> = ['left','down','up',"right"];
	public function init(){
		TitleState.loadNoteAssets();
		changeSprite("skin","static",(frames == null));
		// if (frames == null) {
		// 	frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
		// }
		// animation.addByPrefix('static', 'arrow' + arrowIDs[id].toUpperCase());
		// animation.addByPrefix('pressed', arrowIDs[id].toLowerCase() + ' press', 24, false);
		// animation.addByPrefix('confirm', arrowIDs[id].toLowerCase() + ' confirm', 24, false);
	}
	public override function update(e:Float){
		super.update(e);

	}
	public function playAnim(name:String,?forced:Bool = true, ?Reversed:Bool = false, ?Frame:Int = 0){
		if(animation.getByName(name) == null) return;
		animation.play(name,forced,Reversed,Frame);
		centerOffsets();
	}
	public function playStatic(?forced:Bool = false){
		// color = defColor;
		animation.play("static",forced);
		centerOffsets();
	}
	public function press(?forced:Bool = false){
		// if (color != noteColor) color = noteColor;
		animation.play("pressed",forced);
		centerOffsets();
	}
	public function confirm(?forced:Bool = false){
		// if (color != noteColor) color = noteColor;
		animation.play("confirm",forced);

		centerOffsets();
		if(animation.curAnim.name != "confirm") return;
		offset.x -= 13;
		offset.y -= 13;

	}

}