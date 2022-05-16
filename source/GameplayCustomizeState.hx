import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;


import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.ui.Keyboard;
import flixel.FlxSprite;
import flixel.FlxG;
import KadeEngineData;
import flixel.system.FlxSound;

class GameplayCustomizeState extends PlayState
{


	var background:FlxSprite;
	var curt:FlxSprite;
	var front:FlxSprite;

	// var rating:FlxSprite;
	var objs:Array<String> = [
		"songPosBar",
		"HealthBar",
		"playerStrums",
		"cpuStrums",
		"kadeEngineWatermark",

	];
	
	public override function create() {
		PlayState.SONG = {
				song: "Gameplay thing",
				notes: [{
					sectionNotes:[],
					typeOfSection:0,
					changeBPM:false,
					bpm:120,
					lengthInSteps:1000,
					mustHitSection:true,
				},{
					sectionNotes:[],
					typeOfSection:0,
					changeBPM:false,
					bpm:120,
					lengthInSteps:1000,
					mustHitSection:true,
				}],
				bpm: 120,
				needsVoices: false,
				player1: 'bf',
				player2: 'bf',
				gfVersion: 'gf',
				noteStyle: 'normal',
				stage: 'stage',
				speed: 2.0,
				validScore: false,
				difficultyString: "e"
			};
		
		super.create();
		FlxG.mouse.enabled = true;
		var text = new FlxText(5, FlxG.height + 40, 0, "Drag around gameplay elements, R to reset, Escape to go back.", 12);
		text.scrollFactor.set();
		text.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(text);

		healthBar.visible = healthBarBG.visible = true;
		practiceMode = false;

	}
	inline function resetValues(){
		FlxG.save.data.playStateObjectLocations = new Map<String,ObjectInfo>();
	}
	override function generateSong(?dataPath:String = ""){
		PlayState.SONG.needsVoices = false;
		vocals = new FlxSound();
		FlxG.sound.list.add(vocals);
		SickMenuState.musicHandle();
		if (notes == null) 
			notes = new FlxTypedGroup<Note>();
		notes.clear();
		// add(notes);
		add(notes);
		Note.lastNoteID = -1;
	}
	override function startSong(?alrLoaded:Bool = false){
		super.startSong(true);
		FlxG.sound.music.onComplete = null;
	}
	var isPressed:Bool = false;
	var lastMouseX:Float = 0;
	var lastMouseY:Float = 0;
	var currentObjectName:String = "";
	var currentObject:Dynamic;

	override function update(elapsed:Float) {
		canPause = false;
		super.update(elapsed);
		// if (FlxG.mouse.overlaps(sick) && FlxG.mouse.pressed)
		// {
		//     sick.x = FlxG.mouse.x - sick.width / 2;
		//     sick.y = FlxG.mouse.y - sick.height;
		// }

		// for (i in playerStrums)
		//     i.y = strumLine.y;
		// for (i in strumLineNotes)
		//     i.y = strumLine.y;
		if(!isPressed && FlxG.mouse.pressed){
			for (i in objs) {
				var object = Reflect.getProperty(this,i);
				if(object != null && FlxG.mouse.overlaps(object)){
					isPressed = true;
					currentObject = object;
					currentObjectName = i;
				}
			}
			lastMouseX = FlxG.mouse.x;
			lastMouseX = FlxG.mouse.y;
		}
		if(isPressed && FlxG.mouse.pressed && currentObject != null){
			currentObject.x += lastMouseX - FlxG.mouse.x;
			currentObject.y += lastMouseY - FlxG.mouse.y;
			lastMouseX = FlxG.mouse.x;
			lastMouseX = FlxG.mouse.y;
			// var map:Map<String,KadeEngineData.ObjectInfo> = cast FlxG.save.data.playStateObjectLocations;
			// map[currentObjectName] = {
			// 	x:currentObject.x,
			// 	y:currentObject.y
			// }
		}
		if(!FlxG.mouse.pressed){
			isPressed = false;
		}
		// if (FlxG.mouse.overlaps(sick) && FlxG.mouse.justReleased)
		// {
		//     FlxG.save.data.changedHitX = sick.x;
		//     FlxG.save.data.changedHitY = sick.y;
		//     FlxG.save.data.changedHit = true;
		// }

		if (FlxG.keys.justPressed.R)
		{
			resetValues();
		}

		if (controls.BACK)
		{
			FlxG.mouse.enabled = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new OptionsMenu());
		}

	}


	// ripped from play state cuz im lazy
}