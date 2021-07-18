package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
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
class AnimationDebug extends FlxState
{
	var dad:Character;
	var dadBG:Character;
	//var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	var pressArray:Array<Bool> = [false,false,false,false];
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	var helpObjs:Array<FlxObject> = [];
	var helpShown:Bool = false;
	var offset:Map<String, Array<Float>> = [];
	var offsetText:Map<String, FlxText> = [];
	var offsetTextSize:Int = 20;
	var offsetCount:Int = 1;

	// var flippedChars:Array<String> = ["pico"];

	var charType:Int = 1;

	public function new(daAnim:String = 'spooky',?isPlayer=false,?charType:Int=1)
	{
		super();
		this.daAnim = daAnim;
		this.isDad = !isPlayer;
		this.charType = charType;
	}

	override function create()
	{

		// openfl.Lib.current.stage.frameRate = 144;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		// FlxG.sound.music.stop();
		FlxG.sound.music.looped = true;
		FlxG.sound.music.play(); // Music go brrr

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);
		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.screenCenter();
		stageFront.y += FlxG.height * 0.5;
		stageFront.antialiasing = true;
		stageFront.active = false;
		add(stageFront);
		spawnChar();
		var bf = new Character(0, 0, "bf",true,0,true);
		bf.screenCenter();
		bf.x = FlxG.width * 0.8;
		bf.debugMode = true;
		var contText:FlxText = new FlxText(FlxG.width - 30,FlxG.height * 0.92,0,'Press H for help');
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

		

		// dad.flipX = flippedChars.contains(dad.curCharacter);
		// dadBG.flipX = flippedChars.contains(dadBG.curCharacter);   Handled by character.hx, Not needed here

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);


		FlxG.camera.follow(camFollow);

		super.create();
	}
	function spawnChar(?reload:Bool = false){
		if (reload) {dad.destroy();dadBG.destroy();}
		dad = new Character(0, 0, daAnim,isDad,charType,true);
		dad.screenCenter();
		dad.debugMode = true;
		
		dadBG = new Character(0, 0, daAnim,isDad,charType,true,dad.tex);
		dadBG.screenCenter();
		dadBG.debugMode = true;
		dadBG.alpha = 0.75;
		dadBG.color = 0xFF000000;
		dad.x = FlxG.camera.width * 0.2;
		dadBG.x = FlxG.camera.width * 0.2;

		add(dadBG);
		add(dad);
	}

	function showHelp(){
		helpShown = true;
		helpObjs = [];
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		helpObjs.push(bg);
		var contText:FlxText = new FlxText(FlxG.width - 1000, FlxG.height * 0.9,0,'Press ESC to close.');
		contText.size = 28;
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		helpObjs.push(contText);
		var comboText:FlxText = new FlxText(20,145,0,'Controls:\n\nArrows/WASD - Note anims\nShift - Miss variant/Move by 5(Combine with CTRL to move 5)\nV - Idle\nCtrl - Alt Variant/Move by *0.1\n Press IJKL - Move Offset, Moves per press for accuracy\nR - Reload character\nEscape - Close animation debug');
		comboText.size = 28;
		comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
		comboText.color = FlxColor.WHITE;
		comboText.scrollFactor.set();
		helpObjs.push(comboText);

		for (i => v in helpObjs) {
			add(helpObjs[i]);
		}
	}

	function closeHelp(){
		for (i => v in helpObjs) {
			helpObjs[i].destroy();
		}
		helpShown = false;
	} 
	function moveOffset(?amountX:Float = 0,?amountY:Float = 0,?shiftPress:Bool = false,?ctrlPress:Bool = false){
		try{

			if (shiftPress){amountX=amountX*5;amountY=amountY*5;}
			if (ctrlPress){amountX=amountX*0.1;amountY=amountY*0.1;}
			var animName = dad.animation.curAnim.name;
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

	override function update(elapsed:Float)
	{
		// textAnim.text = dad.animation.curAnim.name;
		if (helpShown){
			if (FlxG.keys.justPressed.ESCAPE)
			{
				closeHelp();
			}
		}else{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				FlxG.switchState(new PlayState());
			}
			var shiftPress = FlxG.keys.pressed.SHIFT;
			var ctrlPress = FlxG.keys.pressed.CONTROL;
			var rPress = FlxG.keys.justPressed.R;
			var hPress = FlxG.keys.justPressed.H;
			var modifier = "";
			pressArray = [
				 (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT),
				 (FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN),
				 (FlxG.keys.pressed.W || FlxG.keys.pressed.UP),
				 (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT),
				 (FlxG.keys.pressed.V),
				 (FlxG.keys.justPressed.I), // Adjust offset
				 (FlxG.keys.justPressed.J),
				 (FlxG.keys.justPressed.K),
				 (FlxG.keys.justPressed.L),
			];

			if (shiftPress) modifier += "MISS";
			if (ctrlPress) modifier += "-alt";
			if (hPress) showHelp();
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
							animToPlay = 'Idle' + modifier;
						case 5: // Offset adjusting
							moveOffset(0,1,shiftPress,ctrlPress);
						case 6:
							moveOffset(1,0,shiftPress,ctrlPress);
						case 7:
							moveOffset(0,-1,shiftPress,ctrlPress);
						case 8:
							moveOffset(-1,0,shiftPress,ctrlPress);
					}
				}
			}
			if (animToPlay != "") {
				var localOffsets:Array<Float>=[0,0];
				if(offset[animToPlay] != null) localOffsets = offset[animToPlay];
				dad.playAnim(animToPlay, true,false,0,localOffsets[0],localOffsets[1]);
			}
			if (rPress && !pressArray.contains(true)) spawnChar(true);
		}


		super.update(elapsed);
	}
}