package;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import sys.FileSystem;
import sys.io.File;
import openfl.net.FileReference;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;

import tjson.Json;

import flixel.graphics.FlxGraphic;
import SEInputText as FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUISubState;
import flixel.addons.ui.FlxUIInputText;
import Controls.Control;
import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.addons.ui.FlxUIDropDownMenu;

import StageJson;

using StringTools;

typedef StageOutput = {
	var objects:Array<Dynamic<FlxObject>>;
	var bfPos:Array<Float>;
	var dadPos:Array<Float>;
	var gfPos:Array<Float>;
	var tags:Array<String>;
	var ?jsonFile:String;
	var showGF:Bool;
}

class StageEditor extends MusicBeatState{
	public static function loadStage(state:FlxState,json:String):StageOutput{
		var objects:Dynamic = [];
		var bfPos:Array<Float> = [770, 100];
		var dadPos:Array<Float> = [100,100];
		var gfPos:Array<Float> = [400, 100];
		var showGF = true;
		var stageTags = [];
		if(json == ""){
			return {
				objects:[],
				bfPos:[770, 100],
				dadPos:[100,100],
				gfPos:[400, 100],
				tags:[],showGF:true,
			};
		}
		try{
			var stagePropJson:String = File.getContent(json);
			var stageProperties:StageJSON = cast haxe.Json.parse(CoolUtil.cleanJSON(json));
			var stagePath = json.substr(0,json.lastIndexOf("/") + 1); 
			if (stageProperties == null || stageProperties.layers == null || stageProperties.layers[0] == null){throw('No layers?');} // Boot to main menu if character's JSON can't be loaded
			// defaultCamZoom = stageProperties.camzoom;
			for (layer in stageProperties.layers) {
				// if(layer.song != null && layer.song != "" && layer.song.toLowerCase() != SONG.song.toLowerCase()){continue;}
				var curLayer:FlxSprite = new FlxSprite(0,0);
				if(layer.animated){
					var xml:String = File.getContent('$stagePath/${layer.name}.xml');
					if (xml == null || xml == "")throw('$stagePath/${layer.name}.xml is invalid!');
					curLayer.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('$stagePath/${layer.name}.png')), xml);
					curLayer.animation.addByPrefix(layer.animation_name,layer.animation_name,layer.fps,false);
					curLayer.animation.play(layer.animation_name);
				}else{
					var png:BitmapData = BitmapData.fromFile('$stagePath/${layer.name}.png');
					if (png == null) MainMenuState.handleError('$stagePath/${layer.name}.png is invalid!');
					curLayer.loadGraphic(png);
				}

				if (layer.centered) curLayer.screenCenter();
				if (layer.flip_x) curLayer.flipX = true;
				curLayer.setGraphicSize(Std.int(curLayer.width * layer.scale));
				curLayer.updateHitbox();
				curLayer.x += layer.pos[0];
				curLayer.y += layer.pos[1];
				curLayer.antialiasing = layer.antialiasing;
				curLayer.alpha = layer.alpha;
				curLayer.active = false;
				curLayer.scrollFactor.set(layer.scroll_factor[0],layer.scroll_factor[1]);
				state.add(curLayer);
			}
			bfPos = stageProperties.bf_pos;
			dadPos = stageProperties.dad_pos;
			gfPos = stageProperties.gf_pos;
			showGF = !stageProperties.no_gf;
			stageTags = stageProperties.tags;
		}catch(e){
			MusicBeatState.instance.showTempmessage('Invalid, broken or empty stage! ${e.message}',FlxColor.RED);
			return {
				objects:[],
				bfPos:[770, 100],
				dadPos:[100,100],
				gfPos:[400, 100],
				tags:[],
				showGF:true,
			};
		}
		return {
			objects:objects,
			bfPos:bfPos,
			dadPos:dadPos,
			gfPos:gfPos,
			tags:stageTags,
			showGF:showGF,
		}
	}
	// Don't enable this, I'm just too lazy to comment out code
	#if STAGEEDITOR
	var curStage = "";
	public override function new(stage:String = ""){
		curStage = stage;
		super();
	}
	public var objects:Array<Dynamic> = [];
	// public var objectList:Map<String,Int> = [];
	public var objectListArr:Array<String> = [];
	public var bf:Character;
	public function updateObjectList(){
		objectList = [];
		for (i => v in objects){
			objectListArr.push(v.name);
		}
		objectListArr.push("boyfriend");
		objectListArr.push("girlfriend");
		objectListArr.push("opponent");
	}

	public override function create(){

		super.create();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.mouse.enabled = true;
		FlxG.mouse.visible = true;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		// Music should still be playing, no reason to do anything to it
		FlxG.sound.music.looped = true;
		FlxG.sound.music.onComplete = null;
		FlxG.sound.music.play(); // Music go brrr


		var out:StageOutput = loadStage(this,curStage);





	}


	#end
}