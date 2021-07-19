package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

using StringTools;

/**
	*DEBUG MODE
 */
class AnimationDebug extends MusicBeatState
{
	var gf:Character;
	var dad:Character;
	var dadBG:Character;
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
	var offsetTextSize:Int = 20;
	var offsetCount:Int = 1;
	var charSel:Bool = false;
	var charX:Float = 0;
	var charY:Float = 0;
	var characterX:Float = 0;
	var characterY:Float = 0;

	// var flippedChars:Array<String> = ["pico"];


	public function new(?daAnim:String = 'bf',?isPlayer=false,?charType_:Int=1,?charSel:Bool = false)
	{
		if (PlayState.SONG == null) MainMenuState.handleError("A song needs to be loaded first due to a crashing bug!");
		super();
		this.daAnim = daAnim;
		this.isPlayer = isPlayer;
		charType = charType_;
		this.charSel = charSel;
		trace('Animation debug with ${daAnim},${if(isPlayer) "true" else "false"},${charType}');

	}

	override function create()
	{
		try{
			camGame = new FlxCamera();
			camHUD = new FlxCamera();
			camHUD.bgColor.alpha = 0;

			FlxG.cameras.reset(camGame);
			FlxG.cameras.add(camHUD);

			FlxCamera.defaultCameras = [camGame];

			// if (!charSel){ // Music should still be playing, no reason to do anything to it
			FlxG.sound.music.looped = true;
			// 	FlxG.sound.music.play(); // Music go brrr
			// }

			var gridBG:FlxSprite = FlxGridOverlay.create(50, 20);
			gridBG.scrollFactor.set();
			add(gridBG);
			// Emulate playstate's setup

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = false;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);
			if (charType != 3){
				gf = new Character(400, 100, "gf",false,2,true);
				gf.scrollFactor.set(0.95, 0.95);
				gf.animation.finishCallback = function(name:String) gf.idleEnd(true);
				add(gf);
			}
			spawnChar();


			camFollow = new FlxObject(0, 0, 2, 2);
			camFollow.screenCenter();
			camFollow.setPosition(720, 500); 
			add(camFollow);


			FlxG.camera.follow(camFollow);
			super.create();
			updateCharPos(0,0,false,false);



			var contText:FlxText = new FlxText(FlxG.width - 90,FlxG.height * 0.92,0,'Press H for help');
			contText.size = 16;
			contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
			contText.color = FlxColor.WHITE;
			contText.scrollFactor.set();
			add(contText);
			var offsetTopText:FlxText = new FlxText(30,20,0,'Current offsets(This is in addition to the existing offsets):');
			offsetTopText.size = 16;
			offsetTopText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
			offsetTopText.color = FlxColor.WHITE;
			offsetTopText.scrollFactor.set();
			add(offsetTopText);

			
		}catch(e) MainMenuState.handleError('Error occurred, try loading a song first. ${e.message}');
	}
	function spawnChar(?reload:Bool = false){
		try{

			if (reload) {
				dad.destroy();
				dadBG.destroy();
				for (i => v in offsetText) {
					v.destroy();
				}
				offsetText = [];
				offset = [];
			}
			characterY=100;
			var flipX = isPlayer;
			switch(charType){
				case 0:characterX=790;flipX = true;
				case 1:characterX=100;
				case 2:characterX=400;
				default:characterX=100;
			};
			dad = new Character(characterX, characterY, daAnim,flipX,charType,true);
			// dad.screenCenter();
			dad.debugMode = true;

			
			dadBG = new Character(characterX, characterY, daAnim,flipX,charType,true,dad.tex);
			// dadBG.screenCenter();
			dadBG.debugMode = true;
			dadBG.alpha = 0.75;
			dadBG.color = 0xFF000000;
			// dad.x = FlxG.camera.width * 0.2;
			// dadBG.x = FlxG.camera.width * 0.2;

			add(dadBG);
			add(dad);
			// dad.dance();
			
		}catch(e) MainMenuState.handleError('Error occurred in spawnChar, animdebug ${e.message}');
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
				text.size = 16;
				text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				text.color = FlxColor.WHITE;
				text.scrollFactor.set();
				add(text);
				offsetText[animName] = text;
			}
			dad.playAnim(animName, true,false,0,offset[animName][0],offset[animName][1]);
			offsetText[animName].text = '${animName}: [${offset[animName][0]}, ${offset[animName][1]}]';
		}catch(e) MainMenuState.handleError('Error while handling offsets: ${e.message}');
		
	}

	function exit(){
		if (charSel){
			FlxG.switchState(new CharSelection());
		}
		else switch(PlayState.stateType){
			case 2: LoadingState.loadAndSwitchState(new onlinemod.OfflinePlayState()); 
			case 4: LoadingState.loadAndSwitchState(new multi.MultiPlayState());
			default: LoadingState.loadAndSwitchState(new PlayState());
		}
	}
	function updateCharPos(?x:Float = 0,?y:Float = 0,?shiftPress:Bool = false,?ctrlPress:Bool = false){
		if (shiftPress){x=x*5;y=y*5;}
		if (ctrlPress){x=x*0.1;y=y*0.1;}
		charX+=x;charY+=y;
		dad.x += x;
		dad.y += y;
		dadBG.x += x;
		dadBG.y += y;
		if (offsetText["charPos_internal"] == null){
			offsetCount += 1;
			var text:FlxText = new FlxText(30,30 + (offsetTextSize * offsetCount),0,"");
			text.size = 16;
			text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
			text.color = FlxColor.WHITE;
			text.scrollFactor.set();
			add(text);
			offsetText["charPos_internal"] = text;
		}
		offsetText["charPos_internal"].text = 'Character Position: [${charX}, ${charY}]';

	}

	override function update(elapsed:Float)
	{
		// textAnim.text = dad.animation.curAnim.name;
		if (FlxG.keys.justPressed.ESCAPE)
			exit();
		var shiftPress = FlxG.keys.pressed.SHIFT;
		var ctrlPress = FlxG.keys.pressed.CONTROL;
		var rPress = FlxG.keys.justPressed.R;
		var hPress = FlxG.keys.justPressed.H;
		
		pressArray = [
			 (FlxG.keys.justPressed.W), // Adjust offset
			 (FlxG.keys.justPressed.A),
			 (FlxG.keys.justPressed.S),
			 (FlxG.keys.justPressed.D),
			 (FlxG.keys.pressed.V),
			 (FlxG.keys.pressed.LEFT),
			 (FlxG.keys.pressed.DOWN),
			 (FlxG.keys.pressed.UP),
			 (FlxG.keys.pressed.RIGHT),
			 (FlxG.keys.justPressed.I), // Adjust Camera
			 (FlxG.keys.justPressed.J),
			 (FlxG.keys.justPressed.K),
			 (FlxG.keys.justPressed.L),
		];

		var modifier = "";
		if (shiftPress) modifier += "miss";
		if (ctrlPress) modifier += "-alt";
		if (hPress) openSubState(new AnimHelpScreen());
		var animToPlay = "";
		for (i => v in pressArray) {
			if (v){
				switch(i){
					case 0:
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
						moveOffset(0,1,shiftPress,ctrlPress);
					case 6:
						moveOffset(1,0,shiftPress,ctrlPress);
					case 7:
						moveOffset(0,-1,shiftPress,ctrlPress);
					case 8:
						moveOffset(-1,0,shiftPress,ctrlPress);
					case 9:
						updateCharPos(0,-1,shiftPress,ctrlPress);
					case 10:
						updateCharPos(-1,0,shiftPress,ctrlPress);
					case 11:
						updateCharPos(0,1,shiftPress,ctrlPress);
					case 12:
						updateCharPos(1,0,shiftPress,ctrlPress);
				}
			}
		}
		if (animToPlay != "") {
			var localOffsets:Array<Float>=[0,0];
			if(offset[animToPlay] != null) localOffsets = offset[animToPlay];
			dad.playAnim(animToPlay, true, false, 0, localOffsets[0], localOffsets[1]);
		}
		if (rPress && !pressArray.contains(true)) spawnChar(true);


		super.update(elapsed);
	}
}
class AnimHelpScreen extends FlxSubState{

	var helpObjs:Array<FlxObject> = [];
	override function create(){
		// helpShown = true;
		helpObjs = [];
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		helpObjs.push(bg);
		var exitText:FlxText = new FlxText(FlxG.width - 1000, FlxG.height * 0.9,0,'Press ESC to close.');
		exitText.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		exitText.scrollFactor.set();
		helpObjs.push(exitText);
		var controlsText:FlxText = new FlxText(20,145,0,'Controls:\n\nArrows - Note anims\nShift - Miss variant/Move by 5(Combine with CTRL to move 5)\nI - Idle\nCtrl - Alt Variant/Move by *0.1\n WASD - Move Offset, Moves per press for accuracy\n IJKL - Move char, Moves per press for accuracy\nR - Reload character\nEscape - Close animation debug');
		controlsText.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		controlsText.scrollFactor.set();
		helpObjs.push(controlsText);

		var importantText:FlxText = new FlxText(2, 48,0,'You cannot save offsets, You have to manually copy them');
		importantText.setFormat("VCR OSD Mono", 28, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// importantText.color = FlxColor.WHITE;
		importantText.scrollFactor.set();
		helpObjs.push(importantText);

		for (i => v in helpObjs) {
			add(helpObjs[i]);
		}
	}
	override function update(elapsed:Float){
		if (FlxG.keys.justPressed.ESCAPE)
			closeHelp();
	}
	function closeHelp(){
		for (i => v in helpObjs) {
			helpObjs[i].destroy();
		}
		this.destroy();
	} 
}