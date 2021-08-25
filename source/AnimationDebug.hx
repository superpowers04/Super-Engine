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

import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;


using StringTools;

typedef ToggleBox ={
	var x:Int;
	var y:Int;
	var name:String;
	var callback:Dynamic;
	var checked:Dynamic;
	var labelW:Int;
}

class AnimationDebug extends MusicBeatState
{
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
	var offsetTextSize:Int = 20;
	var offsetCount:Int = 1;
	var charSel:Bool = false;
	var charX:Float = 0;
	var charY:Float = 0;
	var characterX:Float = 0;
	var characterY:Float = 0;
	var UI:FlxGroup = new FlxGroup();
	var tempMessage:FlxText;
	var tempMessTimer:FlxTimer;
	var offsetTopText:FlxText;
	var isAbsoluteOffsets:Bool = false;
	public var charJson:CharacterJson;
	public static var inHelp:Bool = false;
	public var canEditJson:Bool = false;
	var animationList:Array<String> = [];
	var UI_box:FlxUITabMenu;

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
			FlxG.sound.music.onComplete = null;
			FlxG.sound.music.play(); // Music go brrr
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
			offsetTopText = new FlxText(30,20,0,'');
			offsetTopText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
			offsetTopText.scrollFactor.set();
			if (charType != 2){
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



			var contText:FlxText = new FlxText(FlxG.width * 0.8,FlxG.height * 0.92,0,'Press H for help');
			contText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
			contText.color = FlxColor.BLACK;
			contText.scrollFactor.set();
			// add(contText);

			UI.add(offsetTopText);
			UI.add(contText);
			
		}catch(e) MainMenuState.handleError('Error occurred, try loading a song first. ${e.message}');
	}
	function spawnChar(?reload:Bool = false,?resetOffsets = true){
		try{

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
			dad = new Character(characterX, characterY, daAnim,flipX,charType,true);
			// dad.screenCenter();
			dad.debugMode = true;

			
			dadBG = new Character(characterX, characterY, daAnim,flipX,charType,true,dad.tex);
			// dadBG.screenCenter();
			dadBG.debugMode = true;
			dadBG.alpha = 0.75;
			dadBG.color = 0xFF000000;
			offsetTopText.text = 'Current offsets(Relative, These should be added to your existing ones):';
			isAbsoluteOffsets = false;

			add(dadBG);
			add(dad);
			charJson = dad.charProperties;
			if(charJson == null || dad.loadedFrom == "" || !FileSystem.exists(dad.loadedFrom))
			   canEditJson = false; 
			else {
				canEditJson = true;
				if(charJson.animations_offsets != null) {for (i => v in charJson.animations) {animationList.push(v.name);}}
			}

			
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
				text.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
				text.scrollFactor.set();
				UI.add(text);
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
	function showTempmessage(str:String,?color:FlxColor = FlxColor.LIME,?time = 5){
		if (tempMessage != null && tempMessTimer != null){tempMessage.destroy();tempMessTimer.cancel();}
		trace(str);
		tempMessage = new FlxText(40,30,24,str);
		tempMessage.setFormat(Paths.font("vcr.ttf"), 24, color, LEFT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		tempMessage.scrollFactor.set();
		tempMessage.width = FlxG.width - tempMessage.x;
		UI.add(tempMessage);
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
		if(charJson == null) {FlxG.sound.play(Paths.sound('cancelMenu'));showTempmessage("Can't save, Character has no JSON?",FlxColor.RED);return;}
		if(dad.loadedFrom == "" || !FileSystem.exists(dad.loadedFrom)) {FlxG.sound.play(Paths.sound('cancelMenu'));showTempmessage("Unable to save! Character does't use a specific JSON?",FlxColor.RED);return;}
		try{
			var animOffsetsJSON = "[";
			var animOffsets:Map<String, Map<String,Array<Float>>> = [];
			for (name => v in dad.animOffsets) {
				var x = v[0];
				var y = v[1];
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
			for (i => v in charJson.animations_offsets){
				var name = v.anim;
				// if (animOffsets.get(name) == null){
				// 	animOffsets[name] = [];
				// }
				if(v.player1 != null && animOffsets[name]["player1"] == null) animOffsets[name]["player1"] = v.player1;
				if(v.player2 != null && animOffsets[name]["player2"] == null) animOffsets[name]["player2"] = v.player2;
				if(v.player3 != null && animOffsets[name]["player3"] == null) animOffsets[name]["player3"] = v.player3;

			}
			charJson.animations_offsets = [];
			for (name => v in animOffsets){
				if(animOffsets[name]["player1"] == null) animOffsets[name]["player1"] = [];
				if(animOffsets[name]["player2"] == null) animOffsets[name]["player2"] = [];
				if(animOffsets[name]["player3"] == null) animOffsets[name]["player3"] = [];
				charJson.animations_offsets.push({
					"anim" : name,
					"player1" : animOffsets[name]["player1"],
					"player2" : animOffsets[name]["player2"],
					"player3" : animOffsets[name]["player3"]
				});
			}
			charJson.common_stage_offset = [];
			charJson.char_pos = [];
			switch (charType) {
				case 0: charJson.char_pos1 = [dad.x,-dad.y];
				case 1: charJson.char_pos2 = [dad.x,-dad.y];
				case 2: charJson.char_pos3 = [dad.x,-dad.y];
			}
			charJson.genBy = "FNFBR; Animation Editor";
			
			File.copy(dad.loadedFrom,dad.loadedFrom + "-bak.json");
			File.saveContent(dad.loadedFrom,haxe.Json.stringify(charJson, "\t"));
			showTempmessage("Saved to character.json successfully");
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		}catch(e){FlxG.sound.play(Paths.sound('cancelMenu'));showTempmessage('Error: ${e.message}',FlxColor.RED);trace('ERROR: ${e.message}');return;}
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
			text.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.WHITE);
			// text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
			text.width = FlxG.width;
			text.scrollFactor.set();
			UI.add(text);
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
		];

		var modifier = "";
		if (shiftPress) modifier += "miss";
		if (ctrlPress) modifier += "-alt";
		if (hPress) openSubState(new AnimHelpScreen(this));
		var animToPlay = "";
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
						moveOffset(0,1,shiftPress,ctrlPress);
					case 6:
						moveOffset(1,0,shiftPress,ctrlPress);
					case 7:
						moveOffset(0,-1,shiftPress,ctrlPress);
					case 8:
						moveOffset(-1,0,shiftPress,ctrlPress);

					case 9: // Char position
						updateCharPos(0,-1,shiftPress,ctrlPress);
					case 10:
						updateCharPos(-1,0,shiftPress,ctrlPress);
					case 11:
						updateCharPos(0,1,shiftPress,ctrlPress);
					case 12:
						updateCharPos(1,0,shiftPress,ctrlPress);

					case 13: // Unload character offsets
						dad.animOffsets = ["all" => [0,0]];
						charX = 0;charY = 0;
						dad.offset.set(0,0);
						dadBG.offset.set(0,0);
						isAbsoluteOffsets = true;
						offsetTopText.text = 'Current offsets(Absolute, these replace your existing ones):';
					case 14: // Write to file
						outputCharOffsets();
					// case 15: // Save Char JSON
					// 	if(canEditJson) outputChar();
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
	override function draw(){ // Dunno how inefficient this is but it works
		super.draw();

		if (!inHelp) UI.draw();
	}
}
class AnimHelpScreen extends FlxSubState{

	var helpObjs:Array<FlxObject> = [];

	var animDebug:Dynamic;
	var UI_box:FlxUITabMenu;



	// function createUI(){
	// 	var tab_group = new FlxUI(null, UI_box);
	// 	tab_group.name = "Character Settings";
	// 	var toggleBoxes:Array<ToggleBox> = [
	// 		{
	// 			x:10,
	// 			y:60,
	// 			name:"FlipX",
	// 			labelW:100,
	// 			checked:function(){return animDebug.charJson.flip_x;},
	// 			callback:function(){
	// 				animDebug.dad.flipX = !animDebug.dad.flipX;
	// 				animDebug.dadBG.flipX = !animDebug.dadBG.flipX;
	// 				animDebug.charJson.flip_x = !animDebug.charJson.flip_x;
	// 			}
	// 		}
	// 	];
	// 	for (i => v in toggleBoxes) {
	// 		var toggleBox = new FlxUICheckBox(v.x, v.y, null, null, v.name, v.labelW,null,v.callback);
	// 		toggleBox.checked = v.checked();

	// 		tab_group.add(toggleBox);
	// 	}

	// 	// var check_player = new FlxUICheckBox(10, 60, null, null, "Playable Character", 100);
	// 	// check_player.checked = ;
	// 	// check_player.callback = function()
	// 	// {
	// 	// 	char.isPlayer = !char.isPlayer;
	// 	// 	char.flipX = !char.flipX;
	// 	// 	loadChar(!check_player.checked);
	// 	// 	updatePresence();
	// 	// 	reloadCharacterDropDown();
	// 	// 	reloadBGs();
	// 	// };

	// 	// var charDropDown = new FlxUIDropDownMenuCustom(10, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(character:String)
	// 	// {
	// 	// 	daAnim = characterList[Std.parseInt(character)];
	// 	// 	check_player.checked = daAnim.startsWith('bf');
	// 	// 	loadChar(!check_player.checked);
	// 	// 	updatePresence();
	// 	// 	reloadCharacterDropDown();
	// 	// });
	// 	// charDropDown.selectedLabel = daAnim;
	// 	// reloadCharacterDropDown();

	// 	var reloadCharacter:FlxButton = new FlxButton(140, 30, "Reload Char", function() {animDebug.spawnChar(true,true);});
		
	// 	// tab_group.add(new FlxText(charDropDown.x, charDropDown.y - 18, 0, 'Character:'));
	// 	// tab_group.add(check_player);
	// 	// tab_group.add(reloadCharacter);
	// 	// tab_group.add(charDropDown);
	// 	// tab_group.add(reloadCharacter);
	// 	UI_box.addGroup(tab_group);
	// }

	override public function new(?_animDebug:Dynamic):Void {
		super();
		animDebug = _animDebug;
	}

	override function create(){
		// helpShown = true;

		AnimationDebug.inHelp = true;
		helpObjs = [];
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.8;
		bg.scrollFactor.set();
		helpObjs.push(bg);
		var exitText:FlxText = new FlxText(FlxG.width * 0.7, FlxG.height * 0.9,0,'Press ESC to close.');
		exitText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		exitText.scrollFactor.set();
		helpObjs.push(exitText);
		var controlsText:FlxText = new FlxText(10,145,0,'Controls:'
		+'\n\nWASD - Note anims'
		+'\nV - Idle'
		+'\n *Shift - Miss variant'
		+'\n *Ctrl - Alt Variant'
		+'\nIJKL - Move char, Moves per press for accuracy'
		+'\nArrows - Move Offset, Moves per press for accuracy'
		+'\n *Shift - Move by 5(Combine with CTRL to move 5)'
		+'\n *Ctrl - Move by *0.1'
		+"\n"
		+'\n1 - Unloads all offsets from the game or json file, including character position.**\n **Making offsets absolute(Meaning they should replace existing offsets your character has)'
		+'\n2 - Write offsets to offsets.txt in FNFBR\'s folder for easier copying'
		// +if(animDebug.canEditJson)'\n3 - Write character info to characters JSON'else''
		+'\nR - Reload character'
		+'\nEscape - Close animation debug');
		controlsText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		controlsText.scrollFactor.set();
		helpObjs.push(controlsText);
		// if(animDebug.canEditJson)createUI();

		var importantText:FlxText = new FlxText(10, 48,0,'You cannot save offsets, You have to manually copy them');
		importantText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);

		// importantText.color = FlxColor.BLACK;
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
		AnimationDebug.inHelp = false;
		close();
	} 
}