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

import haxe.Json;

import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
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

import CharacterJson;

using StringTools;



class AnimationDebug extends MusicBeatState
{
	static var INTERNALANIMATIONLIST:Array<String> = ["idle","singLEFT","singDOWN","singUP","singRIGHT","singLEFTmiss","singDOWNmiss","singUPmiss","singRIGHTmiss","Idle-alt","singLEFT-alt","singDOWN-alt","singUP-alt","singRIGHT-alt","hey","lose","dodge"]; // Why is this yelling you ask? Because yes
	public static var instance:AnimationDebug;
	var gf:Character;
	public var dad:Character;
	public var dadBG:Character;
	//var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isPlayer:Bool = false;
	var daAnim:String = 'bf';
	var charType:Int = 0;

	var camFollow:FlxObject;
	var pressArray:Array<Bool> = [];
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	var offset:Map<String, Array<Float>> = [];
	var offsetText:Map<String, FlxText> = [];
	var offsetList:Array<String> = [];
	var offsetTextSize:Int = 20;
	var offsetCount:Int = 1;
	var charSel:Bool = false;
	var charX:Float = 0;
	var charY:Float = 0;
	var characterX:Float = 0;
	var characterY:Float = 0;
	var UI:FlxGroup = new FlxGroup();
	// var tempMessage:FlxText;
	// var tempMessTimer:FlxTimer;
	var offsetTopText:FlxText;
	var isAbsoluteOffsets:Bool = false;
	var absPos:Bool = false;
	public static var charJson:CharacterJson;
	public static var inHelp:Bool = false;
	public static var canEditJson:Bool = false;
	public static var reloadChar:Bool = false;
	var animationList:Array<String> = [];
	var xmlAnimList:Array<String> = [];

	public var editMode:Int = 0;
	static var showOffsets:Bool = false;
	static var offsetTopTextList:Array<String> = [
	'Current offsets(Relative, These should be added to your existing ones):',
	'Current offsets(Absolute, these replace your existing ones):',
	'Offset Editing Mode(Relative)',
	'Offset Editing Mode(Absolute)',
	'Camera Positioning Mode',
	'Animation Editing Mode'
	];

	var quitHeld:Int = 0;
	var quitHeldBar:FlxBar;
	var quitHeldBG:FlxSprite;


	public function new(?daAnim:String = 'bf',?isPlayer=false,?charType_:Int=1,?charSel:Bool = false)
	{
		// if (!PlayState.hasStarted){
		// 	// try{
		// 	// 	PlayState.SONG = {
		// 	// 		song: "Nothing",
		// 	// 		notes: [],
		// 	// 		bpm: 120,
		// 	// 		needsVoices: false,
		// 	// 		player1: 'bf',
		// 	// 		player2: 'bf',
		// 	// 		gfVersion: 'gf',
		// 	// 		noteStyle: 'normal',
		// 	// 		stage: 'stage',
		// 	// 		speed: 2.0,
		// 	// 		validScore: false,
		// 	// 		difficultyString: "Unknown"
		// 	// 	};
		// 	// 	var e = new PlayState();
		// 	// 	e.destroy();
		// 	// }catch(e){
		// 	MainMenuState.handleError("A song needs to be loaded first!");
		// 	return;
		// 	// }
		// } 
			// MainMenuState.handleError("A song needs to be loaded first due to a crashing bug!");
		super();
		
		this.daAnim = daAnim;
		this.isPlayer = isPlayer;
		charType = charType_;
		this.charSel = charSel;
		canEditJson = false;
		instance = this;
		trace('Animation debug with ${daAnim},${if(isPlayer) "true" else "false"},${charType}');

	}
	override function beatHit(){
		super.beatHit();
		if(gf != null) gf.dance();
	}
	override function create()
	{
		try{
			camGame = new FlxCamera();
			camHUD = new FlxCamera();
			camHUD.bgColor.alpha = 0;

			FlxG.mouse.visible = true;

			FlxG.cameras.reset(camGame);
			FlxG.cameras.add(camHUD);

			FlxCamera.defaultCameras = [camGame];

			// if (!charSel){ // Music should still be playing, no reason to do anything to it
			FlxG.sound.music.looped = true;
			FlxG.sound.music.onComplete = null;
			FlxG.sound.music.play(); // Music go brrr
			// }

			var gridBG:FlxSprite = FlxGridOverlay.create(50, 20);
			gridBG.scrollFactor.set();
			gridBG.cameras = [camGame];
			add(gridBG);
			// Emulate playstate's setup
			try{

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/stagefront.png')));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = false;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				stageFront.cameras = [camGame];
				add(stageFront);

				if (charType != 2){
					gf = new Character(400, 100, "gf",false,2,true,
					FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/characters/GF_assets.png')), File.getContent('assets/shared/images/characters/GF_assets.xml'))
					);
					gf.scrollFactor.set(0.95, 0.95);
					gf.animation.finishCallback = function(name:String) gf.idleEnd(true);
					gf.cameras = [camGame];
					add(gf);
				}
				if (charType == 2){
					gf = new Character(790, 100, "bf",true,2,true,
					FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/characters/BOYFRIEND.png')), File.getContent('assets/shared/images/characters/BOYFRIEND.xml'))
					);
					gf.scrollFactor.set(0.95, 0.95);
					gf.dance();
					// gf.animation.finishCallback = function(name:String) gf.idleEnd(true);
					gf.cameras = [camGame];
					add(gf);
				}
			}catch(e){
				trace("Hey look, an error:" + e.stack + ";\n\\Message:" + e.message);
			}
			offsetTopText = new FlxText(30,20,0,'');
			offsetTopText.setFormat(CoolUtil.font, 24, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
			offsetTopText.scrollFactor.set();
			offsetTopText.cameras = [camHUD];
			animDropDown = new PsychDropDown(FlxG.width - 300, 50, FlxUIDropDownMenu.makeStrIdLabelArray([''], true), function(id:String)
			{
				trace('Drop: ${Std.parseInt(id)}');
				var anim = animList[Std.parseInt(id)];
				playAnim(anim);
				// animToPlay = anim;
			});

			animDropDown.selectedLabel = '';
			animDropDown.cameras = [camHUD];
			add(animDropDown);
			var animTxt = new FlxText(animDropDown.x, animDropDown.y - 20,0,"Cur Animation");
			offsetTopText.setFormat(CoolUtil.font, 24, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
			animTxt.cameras = [camHUD];
			add(animTxt);

			camFollow = new FlxObject(0, 0, 2, 2);
			camFollow.screenCenter();
			camFollow.setPosition(720, 500); 
			camFollow.cameras = [camGame];
			add(camFollow);


			camGame.follow(camFollow);
			super.create();
			spawnChar();
			if(dad == null)throw("Player object is null!");
			updateCharPos(0,0,false,false);



			var contText:FlxText = new FlxText(FlxG.width * 0.81,FlxG.height * 0.94,0,'Press H for help');
			contText.setFormat(CoolUtil.font, 24, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
			contText.color = FlxColor.BLACK;
			contText.scrollFactor.set();
			contText.cameras = [camHUD];
			// add(contText);

			add(offsetTopText);
			add(contText);

			quitHeldBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar','shared'));
			quitHeldBG.screenCenter(X);
			quitHeldBG.scrollFactor.set();
			add(quitHeldBG);


			quitHeldBar = new FlxBar(quitHeldBG.x + 4, quitHeldBG.y + 4, LEFT_TO_RIGHT, Std.int(quitHeldBG.width - 8), Std.int(quitHeldBG.height - 8), this,'quitHeld', 0, 1000);
			quitHeldBar.numDivisions = 1000;
			quitHeldBar.scrollFactor.set();
			quitHeldBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			quitHeldBar.cameras = quitHeldBG.cameras = [camHUD];
			add(quitHeldBar);

		}catch(e) {if(PlayState.SONG == null) MainMenuState.handleError('Error occurred, Try loading a song and then opening this again. ${e.details()}'); else MainMenuState.handleError('Error occurred, while loading Animation Debug. ${e.stack} ${e.message}');}
	}
	function spawnChar(?reload:Bool = false,?resetOffsets = true,?charProp:CharacterJson = null){
		try{
			TitleState.checkCharacters();
			reloadChar = false;
			if (reload) {
				// Destroy, otherwise there will be 4 characters
				dad.destroy();
				dadBG.destroy();

				for (i => v in offsetText) {
					v.destroy();
				}
				// Reset offsets
				if (resetOffsets){
					offsetText = [];
					offset = [];
					offsetCount = 1;
					offsetList = [];
					charX = 0;charY = 0;
				}
				animationList = [];
			}
			characterY=100;
			var flipX = isPlayer;
			switch(charType){
				case 0:characterX=790;flipX = true;
				case 1:characterX=100;
				case 2:characterX=400;
				default:characterX=100;
			};
			dad = new Character(characterX, characterY, daAnim,flipX,charType,true,null,charProp);
			// dad.screenCenter();
			dad.debugMode = true;
			dad.cameras = [camGame];

			
			dadBG = new Character(characterX, characterY, daAnim,flipX,charType,true,dad.tex,charProp);
			// dadBG.screenCenter();
			dadBG.debugMode = true;
			dadBG.alpha = 0.75;
			dadBG.color = 0xFF000000;
			dadBG.cameras = [camGame];
			// offsetTopText.text = offsetTopTextList[0];
			toggleOffsetText(showOffsets);
			isAbsoluteOffsets = false;
			absPos = false;

			add(dadBG);
			add(dad);
			if (charType == 2){remove(gf);add(gf);};
			charJson = dad.charProperties;
			animList = [];
			charAnims = ["**Unbind"];
			if (dad.charXml != null){
				var regTP:EReg = (~/<SubTexture name="([A-z0-9\-_ .,\\\|]+)[0-9][0-9][0-9][0-9]"/gm);
				var input:String = dad.charXml;
				while (regTP.match(input)) {
					input=regTP.matchedRight();
					if (!charAnims.contains(regTP.matched(1))){
						charAnims.push(regTP.matched(1));
					}
				}
			}
			try{
				if(charJson == null || dad.loadedFrom == "")
				   canEditJson = false; 
				else {
					canEditJson = true;
					if(charJson.animations != null && charJson.animations[0] != null){

						for (i => v in charJson.animations) {animList.push(v.anim);}
						if(charJson.animations_offsets != null) {for (i => v in charJson.animations) {animationList.push(v.name);}}
					}
				}
				animDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(animList, true));
			}catch(e){showTempmessage("Unable to load animation list",FlxColor.RED);}
		}catch(e) {MainMenuState.handleError('Error occurred in spawnChar, animdebug ${e.message}');trace(e.message);}
	}



	function moveOffset(?amountX:Float = 0,?amountY:Float = 0,?shiftPress:Bool = false,?ctrlPress:Bool = false,?animName:String = ""){
		try{

			if (shiftPress){amountX=amountX*5;amountY=amountY*5;}
			if (ctrlPress){amountX=amountX*0.1;amountY=amountY*0.1;}
			if (animName == "") animName = dad.animation.curAnim.name;
			if(animName == null){MainMenuState.handleError('Animation name is missing!');}
			if(offset[animName] == null){
				offsetCount += 1;
				offset[animName] = [amountX,amountY];
			}else{
				offset[animName][0] += amountX;
				offset[animName][1] += amountY;
			}
			if (offsetText[animName] == null){
				var text:FlxText = new FlxText(30,30 + (offsetTextSize * offsetCount),0,"");
				text.setFormat(CoolUtil.font, 24, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
				text.scrollFactor.set();
				text.visible = showOffsets;
				text.cameras = [camHUD];
				add(text);
				offsetText[animName] = text;
				offsetList.push(animName);
			}
			dad.playAnim(animName, true,false,0,offset[animName][0],offset[animName][1]);
			offsetText[animName].text = '${animName}: [${offset[animName][0]}, ${offset[animName][1]}]';
		}catch(e) MainMenuState.handleError('Error while handling offsets: ${e.message}');
		
	}
	function swapSides(){
		var side = switch (charType) {
			case 0: 1;
			case 2: 1;
			default: 0;
		};
		FlxG.switchState(new AnimationDebug(daAnim,side == 0,side,charSel));
	}
	function exit(){
		FlxG.mouse.visible = false;
		if (charSel){
			FlxG.switchState(new CharSelection()); 
		}
		else switch(PlayState.stateType){
			case 2: LoadingState.loadAndSwitchState(new onlinemod.OfflinePlayState()); 
			case 4: LoadingState.loadAndSwitchState(new multi.MultiPlayState());
			default: LoadingState.loadAndSwitchState(new PlayState());
		}
	}
	override function showTempmessage(str:String,?color:FlxColor = FlxColor.LIME,?time = 5){
		if (tempMessage != null && tempMessTimer != null){tempMessage.destroy();tempMessTimer.cancel();}
		trace(str);
		tempMessage = new FlxText(40,60,24,str);
		tempMessage.setFormat(CoolUtil.font, 24, color, LEFT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		tempMessage.scrollFactor.set();
		tempMessage.autoSize = true;
		tempMessage.wordWrap = false;tempMessage.cameras = [camHUD];
		add(tempMessage);
		tempMessTimer = new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if (tempMessage != null) tempMessage.destroy();
		},1);}

	function outputCharOffsets(){
		var text = (if(isAbsoluteOffsets) "These are absolute, these should replace the offsets in the config.json." else 'These are not absolute, these should be added to the existing offsets in your config.json.') + (if (dad.clonedChar != dad.curCharacter) ' This character is cloning ${dad.clonedChar}' else '') +
			'\nExported offsets for ${dad.curCharacter}/Player ${charType + 1}:\n' +
			if(charX != 0 || charY != 0) '\ncharPos: [${charX}, ${charY}]' else ""; 
		for (i => v in offset) {
			var name = i;

			text+='\n"${name}" : { "player${charType + 1}": [${v[0]}, ${v[1]}] }';
		}
		sys.io.File.saveContent(Sys.getCwd() + "offsets.txt",text);
		showTempmessage("Saved to output.txt successfully");
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

	}
	function outputChar(){
		var errorStage = 0;
		try{
			if(dad.loadedFrom == "") {
				@:privateAccess
				var e = '{
								"animations" : ${Json.stringify(dad.animationList)},
								"flip_x" : false,
								"scale" : ${dad.scale.x},
								"no_antialiasing" : ${!dad.antialiasing},
								"dance_idle" : ${dad.dance_idle},
								"animations_offsets" : [],
								"sing_duration" : ${dad.dadVar},
								"spirit_trail" : ${dad.spiritTrail}
				
							}';
				trace(e);
				charJson = Json.parse(e);
				dad.loadedFrom = "output.json";
			}
			if(charJson == null) {FlxG.sound.play(Paths.sound('cancelMenu'));showTempmessage("Can't save, Character has no JSON?",FlxColor.RED);return;}
			errorStage = 1; // Offsets
			var animOffsetsJSON:String = "[";
			var animOffsets:Map<String, Map<String,Array<Float>>> = [];
			for (name => v in dad.animOffsets) {
				var x:Float = v[0];
				var y:Float = v[1];
				if (offset.get(name) != null){
					x+=offset[name][0];
					y+=offset[name][1];
				}
				animOffsets[name] = ['player${charType + 1}' =>[x,y]];

			}
			for (i => v in offset){
				if (animOffsets.get(i) == null){
					animOffsets[i] = [ 'player${charType + 1}' => [v[0],v[1]]];
				}
			}
			errorStage = 2; // Offsets
			if (charJson.animations_offsets != null && charJson.animations_offsets[0] != null){
				for (i => v in charJson.animations_offsets){
					var name:String = v.anim;
					if (animOffsets[name] == null){
						animOffsets[name] = new Map();
					}
					if(v.player1 != null && animOffsets[name]["player1"] == null) animOffsets[name]["player1"] = v.player1;
					if(v.player2 != null && animOffsets[name]["player2"] == null) animOffsets[name]["player2"] = v.player2;
					if(v.player3 != null && animOffsets[name]["player3"] == null) animOffsets[name]["player3"] = v.player3;

				}
			}
			errorStage = 3; // Offsets
			charJson.animations_offsets = [];
			for (name => v in animOffsets){
				if(name == "all") {
					dad.x += v['player${charType + 1}'][0];
					dad.y -= v['player${charType + 1}'][1];
					continue;
				}
				if(animOffsets[name]["player1"] == null) animOffsets[name]["player1"] = [0.0,0.0];
				if(animOffsets[name]["player2"] == null) animOffsets[name]["player2"] = [0.0,0.0];
				if(animOffsets[name]["player3"] == null) animOffsets[name]["player3"] = [0.0,0.0];
				charJson.animations_offsets.push({
					"anim" : name,
					"player1" : animOffsets[name]["player1"],
					"player2" : animOffsets[name]["player2"],
					"player3" : animOffsets[name]["player3"]
				});
			}

			errorStage = 4; // metadata

			charJson.char_pos = charJson.common_stage_offset = [];
			charJson.offset_flip = 1;
			charJson.like = charJson.clone;
			charJson.clone = "";
			// Compensate for the game moving the character's position

			charJson.cam_pos = [0,0];
			trace('${dad.x},${dad.y}');

			dad.x -= characterX;
			dad.y -= characterY;
			dad.y = -dad.y;

			trace('${dad.x},${dad.y}');
			errorStage = 5; // Position
			switch (charType) {
				case 0: {
					charJson.char_pos1 = [dad.x,dad.y];
					charJson.cam_pos1 = [dad.camX,dad.camY];
				};
				case 1: {
					charJson.char_pos2 = [dad.x,dad.y];
					charJson.cam_pos2 = [dad.camX,dad.camY];
				};
				case 2: {
					charJson.char_pos3 = [dad.x,dad.y];
					charJson.cam_pos3 = [dad.camX,dad.camY];
				};
			}
			charJson.genBy = "FNFBR; Animation Editor";
			errorStage = 6; // Saving
			var backed = false;
			if (FileSystem.exists(dad.loadedFrom)) {backed=true;File.copy(dad.loadedFrom,dad.loadedFrom + "-bak.json");}
			File.saveContent(dad.loadedFrom,haxe.Json.stringify(charJson, "\t"));
			showTempmessage('Saved to ${if (dad.loadedFrom.length > 20) '...' + dad.loadedFrom.substring(-20) else dad.loadedFrom} successfully.' + (if(backed) "Old json was backed up to -bak.json." else ""));
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
			spawnChar(true);


		}catch(e){FlxG.sound.play(
			Paths.sound('cancelMenu'));
			showTempmessage('Error: ${e.message} Debug Info: ${errorStage}',FlxColor.RED);
			trace('ERROR: ${e.message}');
			return;
		}
	}



	function updateCharPos(?x:Float = 0,?y:Float = 0,?shiftPress:Bool = false,?ctrlPress:Bool = false){
		if (shiftPress){x=x*5;y=y*5;}
		if (ctrlPress){x=x*0.1;y=y*0.1;}
		charX+=x;charY-=y;
		// dad.x += x;
		// dad.y -= y;
		// dadBG.x += x;
		// dadBG.y -= y;
		dad.animOffsets['all'][0] -= x;
		dad.animOffsets['all'][1] += y;

		dad.setOffsets(dad.animation.curAnim.name);
		dadBG.animOffsets['all'][0] -= x;
		dadBG.animOffsets['all'][1] += y;
		dadBG.setOffsets(dad.animation.curAnim.name);

		if (offsetText["charPos_internal"] == null){
			offsetCount += 1;
			var text:FlxText = new FlxText(30,30 + (offsetTextSize * offsetCount),0,"");
			text.setFormat(CoolUtil.font, 24, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
			// text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
			text.width = FlxG.width;
			text.scrollFactor.set();
			text.visible = showOffsets;
			text.cameras = [camHUD];
			add(text);
			offsetText["charPos_internal"] = text;
			offsetList.push("charPos_internal");
		}
		offsetText["charPos_internal"].text = 'Character Position: [${charX}, ${charY}]';

	}

	function resetOffsets(){
		dad.animOffsets = ["all" => [0,0]];
		charX = 0;charY = 0;
		dad.offset.set(0,0);
		dadBG.offset.set(0,0);
		absPos = true;
		isAbsoluteOffsets = true;
		offsetTopText.text = offsetTopTextList[1];
	}
	function toggleOffsetText(?value:Bool = false){
		showOffsets = value;
		for (i => v in offsetList) {
			offsetText[v].visible = showOffsets;
		};
		if(editMode == 0){
			offsetTopText.text = offsetTopTextList[0 + (if(isAbsoluteOffsets) 1 else 0) + (if(showOffsets) 0 else 2 )];
		}else if (offsetTopTextList[3 + editMode] != null){
			offsetTopText.text = offsetTopTextList[3 + editMode];
		}
		if(editMode == 2){
			updateCameraPos(false,dad.getMidpoint().x, dad.getMidpoint().y);
		}else if(editMode == 1){
			updateCameraPos(false,get_Dad_X(), get_Dad_Y());
		}else{
			updateCameraPos(false,720, 500);
		}

	}
	inline function get_Dad_X(){return dad.getMidpoint().x + (if (charType == 0) 100 else 150) + dad.camX;}
	inline function get_Dad_Y(){return dad.getMidpoint().y - 100 + dad.camY;}

	function playAnim(?animName:String = ""){
		if (animName == "") animName = animToPlay;
		var localOffsets:Array<Float>=[0,0];
		if(offset[animName] != null) localOffsets = offset[animName];
		dad.playAnim(animName, true, false, 0, localOffsets[0], localOffsets[1]);
		animToPlay = "";
	}

	function updateCameraPos(?modify:Bool = true,?x:Float=0,?y:Float=0,?shiftPress:Bool = false,?ctrlPress:Bool = false){
		if (modify){
			if (shiftPress){x=x*5;y=y*5;}
			if (ctrlPress){x=x*0.1;y=y*0.1;}
			dad.camX += x;
			dad.camY += y;
			camFollow.setPosition(get_Dad_X(), get_Dad_Y());

		}else{
			camFollow.setPosition(x,y);
		}
	}


	// var editorAnim:Map;


	function editAnimation(Anim:String,charAnim:CharJsonAnimation,?replace:Bool = false,?unbind:Bool = false){
		var exists:Bool = false;
		var id:Int = 0;
		trace(haxe.Json.stringify(charAnim,"\t"));
		for (i => v in charJson.animations) {
			if (v.anim == Anim) {exists=true;id = i;break;}
		}

		if (replace){
			if (unbind){
				if (exists)
					charJson.animations[id] = null;
				return;
			}
			if (exists){
				charJson.animations[id] = charAnim;
			}else{
				charJson.animations.push(charAnim);
			}
		}else{

		} // Finish this later
	}

	var uiMap:Map<String,Dynamic> = new Map<String,Dynamic>(); 
	var uiBox:FlxUITabMenu;
	var animDropDown:PsychDropDown;
	var charAnims:Array<String> = [];
	var animUICurAnim:String = "idle";
	var animUICurName:String = "";
	function playTempAnim(name:String){
		dad.addAnimation("ANIMATIONDEBUG_tempAnim",name,24);
		dad.playAnim("ANIMATIONDEBUG_tempAnim");
	}
	function setupUI(dest:Bool = false){
		if (dest){
			uiBox.destroy();
			uiBox = null;
			animDropDown.visible = true;
			// if (animDropDown3 != null) animDropDown3.destroy();
			// if (animDropDown2 != null) animDropDown2.destroy();
			for (_ => v in uiMap) {
				if (v.destroy != null) v.destroy();
			}
			return;
		}

		animDropDown.visible = false;
		uiBox = new FlxUITabMenu(null, [{name:"Animation binder",label:"Animation binder"}], true);
		uiBox.cameras = [camHUD];

		uiBox.resize(250, 330);
		uiBox.x = FlxG.width - 275;
		uiBox.y = 80;
		uiBox.scrollFactor.set();
		add(uiBox);
		uiMap["animSel"] = new FlxInputTextUpdatable(11, 230, 100, '');
		// animSel.text = "idle";

		var animDropDown2 = new PsychDropDown(10, 260, FlxUIDropDownMenu.makeStrIdLabelArray(INTERNALANIMATIONLIST, true), function(anim:String)
		{			// animUICurAnim = INTERNALANIMATIONLIST[Std.parseInt(anim)];

			uiMap["animSel"].updateText(INTERNALANIMATIONLIST[Std.parseInt(anim)]);
			// uiMap["animSel"].textField.text = INTERNALANIMATIONLIST[Std.parseInt(anim)];
		});
		animDropDown2.cameras = [camHUD];
		// animFPS.checked = false;
		uiBox.add(animDropDown2);
		uiBox.add(uiMap["animSel"]);
		
		animUICurName = charAnims[0];
		uiMap["animSel"].text = "idle";
		animDropDown2.selectedLabel = animUICurName;
		animDropDown3 = new PsychDropDown(125, 150, FlxUIDropDownMenu.makeStrIdLabelArray(charAnims, true), function(anim:String)
		{
			// trace('Drop3: ${Std.parseInt(anim)}');
			animUICurName = charAnims[Std.parseInt(anim)];
			playTempAnim(animUICurName);
			// uiMap["animSel"].text = charAnims[Std.parseInt(anim)];
		});
		animDropDown3.selectedLabel = '';animDropDown3.cameras = [camHUD];
		uiBox.add(animDropDown3);

		var animTxt = new FlxText(10, 200,0,"Internal Name");
		uiBox.add(animTxt);

		var animTxt = new FlxText(140, 135,0,"XML Name");
		uiBox.add(animTxt);
		if(dad.charType == 0){

			var warning = new FlxText(2, 180,0,"Anims might not add correctly when editing as BF.\nIt is recommended to add anims as Dad, save and then swap back to editing BF");
			uiBox.add(warning);
		}

		// Togglables 

		var looped = new FlxUICheckBox(30, 20, null, null, "Loop anim");
		looped.checked = false;
		uiMap["loop"] = looped;
		uiBox.add(looped);
		var oneshot = new FlxUICheckBox(30, 40, null, null, "Oneshot/High priority");
		oneshot.checked = false;
		uiMap["oneshot"] = oneshot;
		uiBox.add(oneshot);
		var animTxt = new FlxText(30, 60,0,"Animation FPS");
		uiMap["FPStxt"] = animTxt;
		var animFPS = new FlxUIInputText(30, 80, null, "24");
		// animFPS.customFilterPattern = ~/[^0-9]/;
		// animFPS.text = "24";
		animFPS.filterMode = 2;
		// animFPS.checked = false;
		uiMap["FPS"] = animFPS;
		uiBox.add(animFPS);
		uiBox.add(animTxt);
		// var animTxt = new FlxText(140, 130,0,"XML Name");
		// uiBox.add(animTxt);
		var animTxt = new FlxText(30, 100,0,"Loop Start Frame");
		uiMap["lstxt"] = animTxt;
		uiBox.add(animTxt);
		var animFPS = new FlxUIInputText(30, 120, null, "0");
		animFPS.filterMode = 2;
		uiMap["loopStart"] = animFPS;
		uiBox.add(animFPS);
		var commitButton = new FlxUIButton(20,160,"Add animation",function(){
			var Anim = uiMap["animSel"].text;
			editAnimation(Anim,{
				anim: Anim,
				name: animUICurName,
				loop: uiMap["loop"].checked,
				fps: Std.parseInt(uiMap["FPS"].text),
				loopStart:Std.parseInt(uiMap["loopStart"].text),
				indices: [],
				oneshot: (uiMap["oneshot"].checked || animUICurAnim == "hey" || animUICurAnim == "lose")
			},true,(animUICurName == "**Unbind"));
			spawnChar(true,false,charJson);
		});
		uiBox.add(commitButton);



		// ----------------
		// Config editor
		// ----------------


		var uiBox2 = new FlxUITabMenu(null, [{name:"Config Editor",label:"Config Editor"}], true);
		uiBox2.cameras = [camHUD];

		uiBox2.resize(250, 330);
		uiBox2.x = 15;
		uiBox2.y = 80;
		uiBox2.scrollFactor.set();
		add(uiBox2);
		uiMap["uiBox2"] = uiBox2;

		var looped = checkBox(30, 40,"No antialiasing","no_antialiasing");
		uiBox2.add(looped);
		var looped = checkBox(30, 60,"Flip X","flip_x");
		uiBox2.add(looped);
		var looped = checkBox(30, 80,"Spirit Trail","spirit_trail");
		uiBox2.add(looped);


		var commitButton = new FlxUIButton(20,240,"Update character to show changes",function(){
			spawnChar(true,false,charJson);
		});
		commitButton.resize(120,30);
		uiBox2.add(commitButton);

		var commitButton = new FlxUIButton(20,280,"Back to Offsetting",function(){
			editMode = 0;
			setupUI(true);
			toggleOffsetText(false);
		});
		commitButton.resize(120,20);
		uiBox2.add(commitButton);

	}
	// static function textBox(x:Float,y:Float,defText:String,name:String,internalName:String):FlxInputTextUpdatable{
	// 	var ret = new FlxUIInputText(30, 100, null, "24");
	// 	ret.checked = Reflect.field(charJson,internalName);
	// 	ret.callback = function(){
	// 		Reflect.setField(charJson,internalName,uiMap[name].checked);
	// 	}
	// 	uiMap[name] = ret;
	// 	var animTxt = new FlxText(140, 130,0,"XML Name");
	// 	return ret;
	// }
	function checkBox(x:Float,y:Float,name:String,internalName:String):FlxUICheckBox{
		var ret = new FlxUICheckBox(x, y, null, null, name);
		ret.checked = Reflect.field(charJson,internalName);
		ret.callback = function(){
			Reflect.setField(charJson,internalName,uiMap[name].checked);
		}
		uiMap[name] = ret;
		return ret;
	}
	// function textBox(x:Float,y:Float,name:String,internalName:String):FlxUICheckBox{
	// 	var ret = new FlxUIInputText(x, y, null, null, name);
	// 	ret.checked = Reflect.field(charJson,internalName);
	// 	ret.callback = function(){
	// 		Reflect.setField(charJson,internalName,uiMap[name].checked);
	// 	}
	// 	uiMap[name] = ret;
	// 	return ret;
	// }
	var animToPlay:String = "";
	var animDropDown3:PsychDropDown;
	var animDropDown2:PsychDropDown;
	// inline function canSwitch():Bool {return uiMap["FPS"] == null || (!uiMap["FPS"].focused && !uiMap["animSel"].focused );} // This is disgusting but whatever


	override function update(elapsed:Float)
	{
		// textAnim.text = dad.animation.curAnim.name;
		if (quitHeldBar.visible && quitHeld <= 0){
			quitHeldBar.visible = false;
			quitHeldBG.visible = false;
    		}
		if (FlxG.keys.pressed.ESCAPE)
		{
			quitHeld += 5;
			quitHeldBar.visible = true;
			quitHeldBG.visible = true;
			if (quitHeld > 1000) exit(); 
			}else if (quitHeld > 0){
			quitHeld -= 10;

		}
		var shiftPress = FlxG.keys.pressed.SHIFT;
		var ctrlPress = FlxG.keys.pressed.CONTROL;
		var rPress = FlxG.keys.justPressed.R;
		var hPress = FlxG.keys.justPressed.H;
		dadBG.y = dad.y;
		if (hPress && editMode != 2) openSubState(new AnimHelpScreen(canEditJson,editMode));
		switch(editMode){
			case 0:{
				if (FlxG.keys.justPressed.B) {toggleOffsetText(!showOffsets);}

				pressArray = [
					 (FlxG.keys.pressed.A), // Play note animation
					 (FlxG.keys.pressed.S),
					 (FlxG.keys.pressed.W),
					 (FlxG.keys.pressed.D),
					 (FlxG.keys.pressed.V),
					 (FlxG.keys.justPressed.UP), // Adjust offsets
					 (FlxG.keys.justPressed.LEFT),
					 (FlxG.keys.justPressed.DOWN),
					 (FlxG.keys.justPressed.RIGHT),
					 (FlxG.keys.justPressed.I), // Adjust Character position
					 (FlxG.keys.justPressed.J),
					 (FlxG.keys.justPressed.K),
					 (FlxG.keys.justPressed.L),
					 (FlxG.keys.justPressed.ONE),
					 (FlxG.keys.justPressed.TWO),
					 (FlxG.keys.justPressed.THREE),
					 (FlxG.keys.justPressed.M),
					 (FlxG.keys.justPressed.FOUR),
					 // Shift to move when pressed instead of hammering key
					 (FlxG.keys.pressed.UP), // Adjust offsets
					 (FlxG.keys.pressed.LEFT),
					 (FlxG.keys.pressed.DOWN),
					 (FlxG.keys.pressed.RIGHT),
					 (FlxG.keys.pressed.I), // Adjust Character position
					 (FlxG.keys.pressed.J),
					 (FlxG.keys.pressed.K),
					 (FlxG.keys.pressed.L),
				];

				var modifier = "";
				if (shiftPress) {modifier += "miss";}
				if (ctrlPress) modifier += "-alt";
				if(FlxG.keys.pressed.SEVEN)swapSides();
				// var animToPlay = "";
				for (i => v in pressArray) {
					if (v){
						switch(i){
							case 0: // Play notes
								animToPlay = 'singLEFT' + modifier;
							case 1:
								animToPlay = 'singDOWN' + modifier;
							case 2:
								animToPlay = 'singUP' + modifier;
							case 3:
								animToPlay = 'singRIGHT' + modifier;
							case 4:
								dad.dance();
								
							case 5: // Offset adjusting
								moveOffset(0,1,false,ctrlPress);
							case 6:
								moveOffset(1,0,false,ctrlPress);
							case 7:
								moveOffset(0,-1,false,ctrlPress);
							case 8:
								moveOffset(-1,0,false,ctrlPress);

							case 9: // Char position
								updateCharPos(0,1,false,ctrlPress);
							case 10:
								updateCharPos(-1,0,false,ctrlPress);
							case 11:
								updateCharPos(0,-1,false,ctrlPress);
							case 12:
								updateCharPos(1,0,false,ctrlPress);

							case 13: // Unload character offsets
								resetOffsets();
							case 14: // Write to file
								outputCharOffsets();
							case 15: // Save Char JSON
								outputChar();
							case 16:
								editMode = 1;
								toggleOffsetText(false);

							case 17: // Unload character offsets
								dad.animOffsets['all'] = [0.0,0.0];
								charX = 0;charY = 0;
								updateCharPos(0,0,false,false);
								dad.dance();
								absPos = true;

							case 18: // Offset adjusting
								if (shiftPress)
									moveOffset(0,1,false,ctrlPress);
							case 19:
								if (shiftPress)
									moveOffset(1,0,false,ctrlPress);
							case 20:
								if (shiftPress)
									moveOffset(0,-1,false,ctrlPress);
							case 21:
								if (shiftPress)
									moveOffset(-1,0,false,ctrlPress);
							case 22: // Char position
								if (shiftPress)
									updateCharPos(0,1,false,ctrlPress);
							case 23:
								if (shiftPress)
									updateCharPos(-1,0,false,ctrlPress);
							case 24:
								if (shiftPress)
									updateCharPos(0,-1,false,ctrlPress);
							case 25:
								if (shiftPress)
									updateCharPos(1,0,false,ctrlPress);
						}	
					}
				}
				if (animToPlay != "") {
					playAnim();
				}
			}
			case 1:{

				pressArray = [
					 (FlxG.keys.justPressed.M),
					 (FlxG.keys.justPressed.UP), // Adjust camera position
					 (FlxG.keys.justPressed.LEFT),
					 (FlxG.keys.justPressed.DOWN),
					 (FlxG.keys.justPressed.RIGHT),
					 (FlxG.keys.pressed.UP), // Adjust camera position
					 (FlxG.keys.pressed.LEFT),
					 (FlxG.keys.pressed.DOWN),
					 (FlxG.keys.pressed.RIGHT),
				];
				for (i => v in pressArray) {
					if (v){
						switch(i){
							case 0:
								editMode = 2;
								setupUI(false);
								toggleOffsetText(false);
							case 1: // Offset adjusting
								updateCameraPos(true,0,-1,false,ctrlPress);
							case 2:
								updateCameraPos(true,-1,0,false,ctrlPress);
							case 3:
								updateCameraPos(true,0,1,false,ctrlPress);
							case 4:
								updateCameraPos(true,1,0,false,ctrlPress);
							case 5: // Offset adjusting
								if (shiftPress)
									updateCameraPos(true,0,-1,false,ctrlPress);
							case 6:
								if (shiftPress)
									updateCameraPos(true,-1,0,false,ctrlPress);
							case 7:
								if (shiftPress)
									updateCameraPos(true,0,1,false,ctrlPress);
							case 8:
								if (shiftPress)
									updateCameraPos(true,1,0,false,ctrlPress);
						}	
					}
				}
			}
			case 2:{
				// if (FlxG.keys.justPressed.M && canSwitch()){
				// 	editMode = 0;
				// 	setupUI(true);
				// 	toggleOffsetText(false);

				// }
			}
		}
		if (rPress && !pressArray.contains(true)) spawnChar(true);
		if (reloadChar) spawnChar(true,false,charJson);

		super.update(elapsed);
	}
	override function draw(){ // Dunno how inefficient this is but it works
		super.draw();

		// if (!inHelp) UI.draw();
	} 
}
class AnimHelpScreen extends FlxUISubState{

	var helpObjs:Array<FlxObject> = [];

	var animDebug:Dynamic;
	var canEditJson:Bool = false;
	var editMode:Int = 0;


	function createHelpUI(){
		AnimationDebug.inHelp = true;
		helpObjs = [];
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.8;
		bg.scrollFactor.set();
		helpObjs.push(bg);
		var exitText:FlxText = new FlxText(FlxG.width * 0.7, FlxG.height * 0.9,0,'Press ESC to close.');
		exitText.setFormat(CoolUtil.font, 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		exitText.scrollFactor.set();
		helpObjs.push(exitText);
		var controlsText:FlxText = new FlxText(10,145,0,'Controls:'
		+(switch(editMode) {
			case 0:
				'\n\nWASD - Note anims'
				+'\nV - Idle'
				+'\n *Shift - Miss variant'
				+'\n *Ctrl - Alt Variant'
				+'\nIJKL - Move char, Moves per press for accuracy'
				+'\nArrows - Move Offset, Moves per press for accuracy'
				+'\n *Shift - Hold to move'
				+'\n *Ctrl - Move by *0.1'
				+"\n\nUtilities:\n"
				+'\n1 - Unloads all offsets from the game or json file, including character position.\n'
				+'\n2 - Write offsets to offsets.txt in FNFBR\'s folder for easier copying'
				+(if(canEditJson)'\n3 - Write character info to characters JSON' else '\n3 - Write character info to output.json in FNFBR folder')
				+'\n4 - Unloads character position from json file.(Useful if the game refuses to save the character\'s position)\n'	
				+'\n7 - Reloads Animation debug with the character\'s side swapped\n'
				+"\nB - Hide/Show offset text";
			case 1:
				'\n\nArrows - Move camera, Moves per press for accuracy'
				+'\n *Shift - Hold to move'
				+'\n *Ctrl - Move by *0.1'
				+'\n\nUtilities:\n';
			case 2:
				'';
			default:
				'This should not happen, please report this!.\nEdit mode:${editMode}';
		})
		+'\nR - Reload character'
		+"\nM - Cycle between Offsetting, Camera and config/animation editing modes"
		+'\n\nC - Open property editor in help screen\nEscape - Close animation debug');
		controlsText.setFormat(CoolUtil.font, 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		controlsText.scrollFactor.set();
		helpObjs.push(controlsText);
		animDebug = AnimationDebug.instance;
		// if(animDebug.canEditJson)createUI();
		if(!canEditJson){

			var importantText:FlxText = new FlxText(10, 48,0,'You cannot save offsets for this character, You have to manually copy them');
			importantText.setFormat(CoolUtil.font, 28, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);

			// importantText.color = FlxColor.BLACK;
			importantText.scrollFactor.set();
			helpObjs.push(importantText);
		}

		for (i => v in helpObjs) {
			add(helpObjs[i]);
		}

		// if(AnimationDebug.charJson != null){
		// 	FlxG.mouse.visible = true;
		// 	var reloadCharacter:FlxUIButton = new FlxUIButton(FlxG.width - 200, 70, "Reload Char", function() {animDebug.spawnChar(true,true);});
		// 	var charSettings:FlxUIButton = new FlxUIButton(FlxG.width - 200, 30, "Char Settings", function() {openSubState(new AnimDebugOptions());}); // Todo, make UI for character settings
		// 	reloadCharacter.resize(100, 30);
		// 	charSettings.resize(100, 30);

		// 	helpObjs.push(reloadCharacter);
		// 	helpObjs.push(charSettings);
		// 	add(reloadCharacter);
		// 	add(charSettings);

		// }

	}

	override public function new(?canEditJson:Bool = false,?mode:Int = 0) {
		super();
		this.canEditJson = canEditJson;
		this.editMode = mode;
	}
	override function create(){
		// helpShown = true;

		createHelpUI();
	}
	override function update(elapsed:Float){
		if (canEditJson && FlxG.keys.justPressed.C)
			openSubState(new AnimDebugOptions());
		if (FlxG.keys.justPressed.ESCAPE)
			closeHelp();
	}
	function clearObjs(){
		for (i => v in helpObjs) {
			helpObjs[i].destroy();
		}
		helpObjs = [];
	}
	function closeHelp(){
		// FlxG.mouse.visible = false;

		AnimationDebug.inHelp = false;
		close();
	} 
}

typedef AnimSetting={
	var ?max:Float;
	var ?min:Float;
	var type:Int; // 0 = bool, 1 = int, 2 = float
	var value:Dynamic;
	var description:String;
}

class AnimDebugOptions extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var animDebug:AnimationDebug;
	var settings:Map<String,AnimSetting> = [];
	var menuItems:Array<String> = [];
	var curSelected:Int = 0;
	var infotext:FlxText;
	function getSetting(setting:Dynamic,defValue:Dynamic){ // Function to make sure all data passed through is not null
		if (setting == null) return defValue;
		return setting;
	}
	inline function getValue(str:String,defValue:Dynamic){
		return getSetting(Reflect.field(AnimationDebug.charJson,str),defValue);
	}
	function setValue(str:String,value:Dynamic){
		Reflect.setField(AnimationDebug.charJson,str,value);
		settings[str].value = Reflect.field(AnimationDebug.charJson,str);
	}

	function reloadList():Void{
		grpMenuShit.clear();
		

		menuItems = [];
		var i = 0;
		for (name => value in settings)
		{
			menuItems.push(name);
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, '${name}: ${value.value}', true, false,70,false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
			i++;
		}
		changeSelection();
	}


	public function new()
	{
		AnimationDebug.reloadChar = true;
		super();
		settings = [
			"flip_x" => {type:0,value:getValue("flip_x",false),
				description:"Whether to flip the character, useful for BF clones"},
			"scale" => {type:2,value:getValue("scale",1),description:"Scale for the character",min:0.1,max:10},
			"no_antialiasing" => {type:0,value:getValue("no_antialiasing",false),
				description:"Disables smoothing out pixels, Enabled for pixel characters"},
			"spirit_trail" => {type:0,value:getValue("spirit_trail",false),
				description:"Enables the trail used for the Spirit character"},
			"flip_notes" => {type:0,value:getValue("flip_notes",true),
				description:"Whether to flip left/right when on the right, true by default"},
			"sing_duration" => {type:2,value:getValue("sing_duration",4),
				description:"How long to play the Character's sing animations for"}
		];

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.0;
		bg.scrollFactor.set();
		add(bg);
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		var infotexttxt:String = "";
		infotext = new FlxText(5, FlxG.height - 40, FlxG.width - 100, infotexttxt, 16);
		infotext.wordWrap = true;
		infotext.scrollFactor.set();
		infotext.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		var blackBorder = new FlxSprite(-30,FlxG.height - 40).makeGraphic((Std.int(FlxG.width)),Std.int(50),FlxColor.BLACK);
		blackBorder.alpha = 0.5;
		add(blackBorder);
		add(infotext);
		FlxTween.tween(bg, {alpha: 0.7}, 0.4, {ease: FlxEase.quartInOut});
		reloadList();
		changeSelection(0);


		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;

		if (upP)
		{
			changeSelection(-1);
   
		}else if (downP)
		{
			changeSelection(1);
		}
		
		if (FlxG.keys.pressed.ESCAPE) close(); 

		if (accepted && settings[menuItems[curSelected]].type != 1) changeSetting(curSelected);
		if (leftP || rightP) changeSetting(curSelected,rightP);
	}

	function changeSetting(sel:Int,?dir:Bool = true){
		if (settings[menuItems[sel]].type == 0) setValue(menuItems[sel],settings[menuItems[sel]].value = !settings[menuItems[sel]].value );
		if (settings[menuItems[sel]].type == 1 || settings[menuItems[sel]].type == 2) {
			var val = settings[menuItems[sel]].value;
			var inc:Float = 1;
			if(settings[menuItems[sel]].type == 2 && FlxG.keys.pressed.SHIFT) inc=0.1;
			val += if(dir) inc else -inc;
			if (val > settings[menuItems[sel]].max) val = settings[menuItems[sel]].min; 
			if (val < settings[menuItems[sel]].min) val = settings[menuItems[sel]].max - 1; 
			setValue(menuItems[sel],val);
		}

		grpMenuShit.members[sel].destroy();
		var songText:Alphabet = new Alphabet(0, (70) + 30, '${menuItems[sel]}: ${settings[menuItems[sel]].value}', true, false,70,false);
		songText.isMenuItem = true;
		songText.targetY = 0;
		grpMenuShit.members[sel] = songText;
		// reloadList();
	}

	function changeSelection(?change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		if (settings[menuItems[curSelected]].description != null)
			infotext.text = settings[menuItems[curSelected]].description;
		else
			infotext.text = "No description";
	}
}