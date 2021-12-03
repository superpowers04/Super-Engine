package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.animation.FlxAnimation;
import flixel.animation.FlxAnimationController;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.DynamicAccess;
import lime.utils.Assets;
import lime.graphics.Image;
import CharacterJson;
import flixel.util.FlxColor;

import flash.media.Sound;

import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import Xml;
import flixel.system.FlxSound;

import hscript.Expr;
import hscript.Interp;
import hscript.InterpEx;
import hscript.ParserEx;





using StringTools;

class CharAnimController extends FlxAnimationController{
	override function findByPrefix(AnimFrames:Array<FlxFrame>, Prefix:String):Void
	{
		var regTP:EReg = new EReg('${Prefix}[- ]*[0-9][0-9]?[0-9]?[0-9]?','ig'); // Fixes the game improperly registering frames from other animations
		for (frame in _sprite.frames.frames)
		{
			if (frame.name != null && regTP.match(frame.name))
			{
				AnimFrames.push(frame);
			}
		}
	}
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Float>>;
	public var animLoopStart:Map<String,Int>;
	public var debugMode:Bool = false;
	public var spiritTrail:Bool = false;
	public var camPos:Array<Int> = [0,0];
	public var charX:Float = 0;
	public var charY:Float = 0;
	public var camX:Float = 0;
	public var camY:Float = 0;
	public var dadVar:Float = 4; // Singduration?
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var hasAlts:Bool = false;
	public var clonedChar:String = "";
	public var charType:Int = 0;
	public var dance_idle:Bool = false;
	public var amPreview:Bool = false;
	public var useMisses:Bool = false;
	public var useVoices:Bool = false;
	public var missSounds:Array<Sound> = [];
	public var voiceSounds:Array<FlxSound> = [];
	public var oneShotAnims:Array<String> = ["hey"];
	public var tintedAnims:Array<String> = [];
	public var loopAnimFrames:Map<String,Int> = [];
	public var loopAnimTo:Map<String,String> = [];
	public var flip:Bool = true;
	public var tex:FlxAtlasFrames = null;
	public var holdTimer:Float = 0;
	public var stunned:Bool = false;
	public var loadedFrom:String = "";
	public var isCustom:Bool = false;
	public var charProperties:CharacterJson;
	public var charXml:String;
	public var definingColor:FlxColor;
	public var animationList:Array<CharJsonAnimation> = [];
	public var hscriptGen:Bool = false;
	public var useHscript:Bool = true;
	var customColor = false;
	var flipNotes:Bool = true;
	var needsInverted:Int= 1;
	var danced:Bool = false;
	var lonely:Bool = false;
	var altAnims:Array<String> = []; 
	public var skipNextAnim:Bool = false;
	public var nextAnimation:String = "";
	// HScript related shit


	var interp:Interp;
	public static function hasCharacter(char:String):Bool{
		return (TitleState.retChar(char) != "");
	}
	@privateAccess
	public function callInterp(func_name:String, args:Array<Dynamic>,?important:Bool = false) { // Modified from Modding Plus, I am too dumb to figure this out myself 
			if ((!useHscript || amPreview) || (interp == null || !interp.variables.exists(func_name) ) && !important) {return;}
			try{
			args.insert(0,this);
			var method = interp.variables.get(func_name);
			Reflect.callMethod(interp,method,args);
			}catch(e){handleError('Something went wrong with ${func_name} for ${curCharacter}, ${e.message}'); return;}
		}
	function parseHScript(scriptContents:String){
		if (amPreview || !useHscript){
			interp = null;
			trace("Skipping HScript for " + curCharacter);
			return; // Don't load in editor
		} 
		var interp = HscriptUtils.createSimpleInterp();
		var parser = new hscript.Parser();
		var program:Expr;
		try{
			parser.allowTypes = parser.allowJSON = true;
			program = parser.parseString(scriptContents);
			
			interp.variables.set("hscriptPath", 'mods/characters/$curCharacter');
			interp.variables.set("charName", curCharacter);
			interp.variables.set("charProperties", charProperties);
			interp.variables.set("PlayState", PlayState );
			interp.variables.set("BRtools",new HSBrTools('mods/characters/$curCharacter/'));
			interp.execute(program);
			this.interp = interp;
		}catch(e){
			handleError('Error parsing char ${curCharacter} hscript, Line:${parser.line}; Error:${e.message}');
			
		}
	}

	function addOffsets(?character:String = "") // Handles offsets for characters with support for clones
	{
		if(character == null || character == "" ) return;
		if (Reflect.field(TitleState.defCharJson.characters,curCharacter) == null){

			switch(character){
				case 'gf','gf-christmas':
					addOffset('all',0,30);
					addOffset('cheer');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);

					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);

					addOffset('scared', -2, -17);
					flip = false;
				case 'gf-car':
					addOffset('all',0,30);
					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);
					flip = false;
				case 'gf-pixel':
					addOffset('all',0,30);
					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);
					flip = false;
				case "dad":
					addOffset('idle');
					addOffset("singUP", -6, 50);
					addOffset("singRIGHT", 0, 27);
					addOffset("singLEFT", -10, 10);
					addOffset("singDOWN", 0, -30);
				case 'mom','mom-car':
					addOffset('idle');
					addOffset("singUP", 14, 71);
					addOffset("singRIGHT", 10, -60);
					addOffset("singLEFT", 250, -23);
					addOffset("singDOWN", 20, -160);
				case 'spooky':
					addOffset('danceLeft');
					addOffset('danceRight');

					addOffset("singUP", -20, 26);
					addOffset("singRIGHT", -130, -14);
					addOffset("singLEFT", 130, -10);
					addOffset("singDOWN", -50, -130);
					charY+=130;
				case "pico":
					if(isPlayer){
						// needsInverted = true;
						addOffset('singDOWN', 87, -80);
						addOffset('singDOWNmiss', 87, -29);
						addOffset('singRIGHT', -48, 0);
						addOffset('singRIGHTmiss', -40, 50);
						addOffset('singUP', 19, 27);
						addOffset('singUPmiss', 19, 67);
						addOffset('singLEFT', 75, -9);
						addOffset('singLEFTmiss', 75, 25);
					}else{
						addOffset("singUP", -43, 29);
						addOffset("singRIGHT", -85, -11);
						addOffset("singLEFT", 54, 2);
						addOffset("singDOWN", 198, -76);
						addOffset("singUPmiss", -29, 67);
						addOffset("singRIGHTmiss", -70, 28);
						addOffset("singLEFTmiss", 62, 50);
						addOffset("singDOWNmiss", 200, -34);}

					charY+=330;
					if(!isPlayer){camX-=100;}
				case 'bf','bf-christmas','bf-car':
					charY+=330;
					needsInverted = 0;
					if (isPlayer){
						addOffset('idle', 0);
						addOffset("singUP", -34, 27);
						addOffset("singRIGHT", -48, -7);
						addOffset("singLEFT", 22, -6);
						addOffset("singDOWN", -10, -50);
						addOffset("singUPmiss", -29, 27);
						addOffset("singRIGHTmiss", -30, 21);
						addOffset("singLEFTmiss", 12, 24);
						addOffset("singDOWNmiss", -11, -19);
						addOffset("hey", 7, 4);
						addOffset('scared', -4);
					}else{
						addOffset("singUP", 5, 30);
						addOffset("singRIGHT", -30, -5);
						addOffset("singLEFT", 38, -5);
						addOffset("singDOWN", -15, -50);
						addOffset("singUPmiss", 1, 30);
						addOffset("singRIGHTmiss", -31, 21);
						addOffset("singLEFTmiss", 2, 23);
						addOffset("singDOWNmiss", -15, -20);
						addOffset("hey", 7, 4);
						addOffset('scared', -4);
					}
				case "bf-pixel":
					needsInverted = 0;
					charY+=330;
				case 'spirit':
					addOffset('idle', -220, -280);
					addOffset('singUP', -220, -240);
					addOffset("singRIGHT", -220, -280);
					addOffset("singLEFT", -200, -280);
					addOffset("singDOWN", 170, 110);
					charX-=150;
					charY-=100;
					// camX+=300;

				case 'senpai':
					addOffset('idle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);
					charX+=150;
					charY+=320;
					camX+=300;

				case 'senpai-angry':
					addOffset('idle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);
					charX+=150;
					charY+=320;
					// camX+=300;
				case 'parents-christmas':
					addOffset('idle');
					addOffset("singUP", -47, 24);
					addOffset("singRIGHT", -1, -23);
					addOffset("singLEFT", -30, 16);
					addOffset("singDOWN", -31, -29);
					addOffset("singUP-alt", -47, 24);
					addOffset("singRIGHT-alt", -1, -24);
					addOffset("singLEFT-alt", -30, 15);
					addOffset("singDOWN-alt", -30, -27);
					charX-=500;
				case 'monster':
					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", -51);
					addOffset("singLEFT", -30);
					addOffset("singDOWN", -30, -40);
					charY+=100;
				case 'monster-christmas':
					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", -51);
					addOffset("singLEFT", -30);
					addOffset("singDOWN", -30, -40);
					charY+=130;
			}
		}else{
			var e:Dynamic = Reflect.field(TitleState.defCharJson.characters,curCharacter);
			loadOffsetsFromJSON(e);
			getDefColor(e);

		}
	}
	function loadVanillaChar(charProperties:CharacterJson){
		if(tex == null){
			if (charProperties.embedded){
				// tex = Paths.getSparrowAtlas(charProperties.path);
				charXml = File.getContent('assets/shared/images/${charProperties.path}.xml'); // Loads the XML as a string
				if (charXml == null){handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's XML can't be loaded
	
				tex = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/${charProperties.path}.png')), charXml);
			}else{
				var pngPath:String = '${charProperties.path}.png';
				var xmlPath:String = '${charProperties.path}.xml';
				if (charProperties.asset_files != null){
					var forced = 0;
					var invChIDs:Array<Int> = [1,0,2];
					var selAssets = -10;
					for (i => charFile in charProperties.asset_files) {
						if (charFile.char_side != null && charFile.char_side != 3 && charFile.char_side == charType){continue;} // This if statement hurts my brain
						if (charFile.stage != "" && charFile.stage != null && (PlayState.curStage.toLowerCase() != charFile.stage.toLowerCase()) ){continue;} // Check if charFiletion specifies stage, skip if it doesn't match PlayState's stage
						if (charFile.song != "" && charFile.song != null && (PlayState.SONG.song.toLowerCase() != charFile.song.toLowerCase()) ){continue;} // Check if charFiletion specifies song, skip if it doesn't match PlayState's song
						var tagsMatched = 0;
						if (charFile.tags != null && charFile.tags[0] != null && PlayState.stageTags != null){
							for (i in charFile.tags) {if (PlayState.stageTags.contains(i)) tagsMatched++;}
							if (tagsMatched == 0) continue;
						}
						
						if (forced == 0 || tagsMatched == forced) selAssets = i;
					}
					if (selAssets != -10){
						if (charProperties.asset_files[selAssets].png != null ) pngPath=charProperties.asset_files[selAssets].png;
						if (charProperties.asset_files[selAssets].xml != null ) xmlPath=charProperties.asset_files[selAssets].xml;
						if (charProperties.asset_files[selAssets].animations != null )charProperties.animations=charProperties.asset_files[selAssets].animations;
						if (charProperties.asset_files[selAssets].animations_offsets != null )charProperties.animations_offsets=charProperties.asset_files[selAssets].animations_offsets;
					}
				}
				if(!FileSystem.exists(pngPath) || !FileSystem.exists(xmlPath)) handleError('Invalid xml/png path for ${curCharacter}');
				charXml = File.getContent(xmlPath); // Loads the XML as a string
				if (charXml == null){handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's XML can't be loaded
				// if (amPreview) this.charXml = charXml;
				tex = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile(pngPath)), charXml);
			}
			if(tex == null) handleError('Invalid texture for ${curCharacter}');
		}
		frames = tex;
		loadJSONChar(charProperties);
	}
	function loadOffsetsFromJSON(?charProperties:CharacterJson){
		if (charProperties == null) return;
		if (charProperties.offset_flip != null ) needsInverted = charProperties.offset_flip;
		var offsetCount = 0;
		if (charProperties.animations_offsets != null && charProperties.animations_offsets.length > 0){

			for (offset in charProperties.animations_offsets){ // Custom offsets
				offsetCount++;
				if (needsInverted == 1)
					switch (charType) {
						case 0:
							if (offset.player1 != null && offset.player1.length > 1) addOffset(offset.anim,offset.player1[0],offset.player1[1]);
						case 1:
							if (offset.player2 != null && offset.player2.length > 1) addOffset(offset.anim,offset.player2[0],offset.player2[1]); else if (offset.player1 != null && offset.player1.length > 1) addOffset(offset.anim,offset.player1[0],offset.player1[1]);
						case 2:
							if (offset.player3 != null && offset.player3.length > 1) addOffset(offset.anim,offset.player3[0],offset.player3[1]); else if (offset.player1 != null && offset.player1.length > 1) addOffset(offset.anim,offset.player1[0],offset.player1[1]);
					}
				else
					addOffset(offset.anim,offset.player1[0],offset.player1[1]);
			}	
		}


		switch(charType){
			case 0: 
				if (charProperties.char_pos1 != null){addOffset('all',charProperties.char_pos1[0],charProperties.char_pos1[1]);}
				if (charProperties.cam_pos1 != null){camX += charProperties.cam_pos1[0];camY += charProperties.cam_pos1[1];}
			case 1: 
				if (charProperties.char_pos2 != null){addOffset('all',charProperties.char_pos2[0],charProperties.char_pos2[1]);}
				if (charProperties.cam_pos2 != null){camX += charProperties.cam_pos2[0];camY += charProperties.cam_pos2[1];}
			case 2: 
				if (charProperties.char_pos3 != null){addOffset('all',charProperties.char_pos3[0],charProperties.char_pos3[1]);}
				if (charProperties.cam_pos3 != null){camX += charProperties.cam_pos3[0];camY += charProperties.cam_pos3[1];}
		}


		if(charProperties.common_stage_offset != null){
			if (needsInverted == 1 && !isPlayer){
				addOffset('all',charProperties.common_stage_offset[2],charProperties.common_stage_offset[3]); // Load common stage offset
				camX+=charProperties.common_stage_offset[2];
				camY-=charProperties.common_stage_offset[3]; // Load common stage offset for camera too
			}else{
				addOffset('all',charProperties.common_stage_offset[0],charProperties.common_stage_offset[1]); // Load common stage offset
				camX+=charProperties.common_stage_offset[0];
				camY-=charProperties.common_stage_offset[1]; // Load common stage offset for camera too
			}
		}
		if(!customColor && charProperties.color != null)
			definingColor = FlxColor.fromRGB(isValidInt(charProperties.color[0]),isValidInt(charProperties.color[1]),isValidInt(charProperties.color[2],255));
		
		if (charProperties.char_pos != null){addOffset('all',charProperties.char_pos[0],charProperties.char_pos[1]);}
		if (charProperties.cam_pos != null){camX+=charProperties.cam_pos[0];camY+=charProperties.cam_pos[1];}
		trace('Loaded ${offsetCount} offsets!');
	}
	function isValidInt(num:Null<Int>,?def:Int = 0) {return if (num == null) def else num;}
	function getDefColor(e:CharacterJson){
		if(!customColor && e.color != null){
			// switch(Type.typeof(e.color)){
				if(Std.isOfType(e.color,String)){

					definingColor = FlxColor.fromString(e.color);
					customColor = true;
				}else if (Std.isOfType(e.color,Int)){
					definingColor = FlxColor.fromInt(e.color);
					customColor = true;
				}else{
					if(e.color[0] != null){
						definingColor = FlxColor.fromRGB(isValidInt(e.color[0]),isValidInt(e.color[1]),isValidInt(e.color[2],255));
						customColor = true;
					}
					else
						customColor = false;
				}
			// }
		}
	}
	function loadJSONChar(charProperties:CharacterJson){
		
		trace('Loading Json animations!');
		// Check if the XML has BF's animations, if so, add them





		dadVar = charProperties.sing_duration; // As the varname implies
		flipX=charProperties.flip_x; // Flip for BF clones
		spiritTrail=charProperties.spirit_trail; // Spirit TraiL
		antialiasing = !charProperties.no_antialiasing; 
		dance_idle = charProperties.dance_idle; // Handles if the character uses Spooky/GF's dancing animation

		if (charProperties.flip_notes) flipNotes = charProperties.flip_notes;

		// if(!customColor && charProperties.color != null){
		// 	definingColor = FlxColor.fromRGB(isValidInt(charProperties.color[0]),isValidInt(charProperties.color[1]),isValidInt(charProperties.color[2],255));
		// 	customColor = true;
		// }
		getDefColor(charProperties);
		
		trace('Loading Animations!');
		var animCount = 0;
		var hasIdle = false;
		if(charProperties.animations.length > 0){
			for (anima in charProperties.animations){
				try{if (anima.anim.substr(-4) == "-alt"){hasAlts=true;} // Alt Checking
				if (anima.stage != "" && anima.stage != null){if(PlayState.curStage.toLowerCase() != anima.stage.toLowerCase()){continue;}} // Check if animation specifies stage, skip if it doesn't match PlayState's stage
				if (anima.song != "" && anima.song != null){if(PlayState.SONG.song.toLowerCase() != anima.song.toLowerCase()){continue;}} // Check if animation specifies song, skip if it doesn't match PlayState's song
				if (animation.getByName(anima.anim) != null){continue;} // Skip if animation has already been defined
				if (anima.char_side != null && anima.char_side != 3 && anima.char_side == charType){continue;} // This if statement hurts my brain
				if (anima.ifstate != null){
					trace("Loading a animation with ifstatement...");
					if (anima.ifstate.check == 1 ){ // Do on step or beat
						if (PlayState.stepAnimEvents[charType] == null) PlayState.stepAnimEvents[charType] = [anima.anim => anima.ifstate]; else PlayState.stepAnimEvents[charType][anima.anim] = anima.ifstate;
					} else {
						if (PlayState.beatAnimEvents[charType] == null) PlayState.beatAnimEvents[charType] = [anima.anim => anima.ifstate]; else PlayState.beatAnimEvents[charType][anima.anim] = anima.ifstate;
					}
					
					// PlayState.regAnimEvent(charType,anima.ifstate,anima.anim);
				}
				if (anima.oneshot == true && !amPreview){ // "On static platforms, null can't be used as basic type Bool" bruh
					oneShotAnims.push(anima.anim);
					anima.loop = false; // Looping when oneshot is a terrible idea
				}
				if(anima.loopStart != null && anima.loopStart != 0 )loopAnimFrames[anima.anim] = anima.loopStart;
				if(anima.playAfter != null && anima.playAfter != '' )loopAnimTo[anima.anim] = anima.playAfter;
				if(anima.anim == "idle" || anima.anim == "danceLeft")hasIdle = true;
				if (anima.indices.length > 0) { // Add using indices if specified
					addAnimation(anima.anim, anima.name,anima.indices,"", anima.fps, anima.loop);
				}else{addAnimation(anima.anim, anima.name, anima.fps, anima.loop);}

				}catch(e){handleError('${curCharacter} had an animation error ${e.message}');break;}
				animCount++;
			}
		}
		trace('Registered ${animCount} animations');
		if(!amPreview && !hasIdle){
			
			var hasBFAnims:Bool = false;
			{
				var regTP:EReg = (~/<SubTexture name="BF idle dance/g);
				var input:String = charXml;
				while (regTP.match(input)) {
					hasBFAnims = true;
					break;
				}
			}
			if (hasBFAnims){
				addAnimation('idle', 'BF idle dance', 24, false);
				addAnimation('singUP', 'BF NOTE UP0', 24, false);
				// WHY DO THESE NEED TO BE FLIPPED?
				addAnimation('singLEFT', 'BF NOTE RIGHT0', 24, false); 
				addAnimation('singRIGHT', 'BF NOTE LEFT0', 24, false);
				addAnimation('singDOWN', 'BF NOTE DOWN0', 24, false);
				addAnimation('singUPmiss', 'BF NOTE UP MISS', 24, false);

				addAnimation('singRIGHTmiss', 'BF NOTE LEFT MISS', 24, false);
				addAnimation('singLEFTmiss', 'BF NOTE RIGHT MISS', 24, false);

				addAnimation('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				addAnimation('hey', 'BF HEY', 24, false);
			}
		}
		setGraphicSize(Std.int(width * charProperties.scale)); // Setting size
		updateHitbox();


		if(charProperties.flip != null) flip = charProperties.flip;
		clonedChar = charProperties.clone;
		if (clonedChar != null && clonedChar != "") {
			trace('Character clones $clonedChar copying their offsets!');
			addOffsets(clonedChar);
		}
		if (charProperties.like != null && charProperties.like != "") clonedChar = charProperties.like;
		trace('Adding custom offsets');
		loadOffsetsFromJSON(charProperties);

	}
	function isSelectedChar():Bool{
		switch ( charType ) {
			default: return FlxG.save.data.playerChar == curCharacter;
			case 1: return FlxG.save.data.opponent == curCharacter;
			case 2: return FlxG.save.data.gfChar == curCharacter;
		}
	}

	function loadCustomChar(){
		trace('Loading a custom character "$curCharacter"! ');				
		if(TitleState.retChar(curCharacter) != "" && !amPreview) curCharacter = TitleState.retChar(curCharacter); // Make sure you're grabbing the right character
		isCustom = true;
		var charPropJson:String = "";
		try{
			if (charProperties == null) {charPropJson = File.getContent('mods/characters/$curCharacter/config.json');charProperties = haxe.Json.parse(CoolUtil.cleanJSON(charPropJson));}
		}catch(e){
			if(amPreview){
				var idleName:String = "";
				{ // Load characters without an idle animation, hopefully
					var regTP:EReg = (~/<SubTexture name="([A-z 0-9]+[iI][dD][lL][eE][A-z 0-9]+)[0-9][0-9][0-9][0-9]"/gm);
					var input:String = charXml;
					while (regTP.match(input)) {
						input=regTP.matchedRight();
						// addAnimation("Idle", regTP.matched(1));
						idleName = regTP.matched(1);
						break;
					}
				}
				charProperties = haxe.Json.parse('{
					"clone":"",
					"flip_x":false,
					"sing_duration":6.1,
					"scale":1,
					"dance_idle":false,
					"voices":"",
					"no_antialiasing":false,
					"animations": [{
						"anim":"idle",
						"name":"${idleName}",
						"loop":false,
						"fps":24,
						"indices":[],
						"oneshot":false
					}]
				}');
			}else{
				MainMenuState.handleError('Character ${curCharacter} is missing a config.json! You need to set them up in character selection');
			}
		}
		if ((charProperties == null || charProperties.animations == null || charProperties.animations[0] == null) && !amPreview){handleError('$curCharacter\'s JSON is invalid!');} // Boot to main menu if character's JSON can't be loaded
		// if ((charProperties == null || charProperties.animations == null || charProperties.animations[0] == null) && amPreview){

		// }
		loadedFrom = 'mods/characters/$curCharacter/config.json';
		var pngName:String = "character.png";
		var xmlName:String = "character.xml";
		var forced:Int = 0;
		if (charProperties.asset_files != null){
			var invChIDs:Array<Int> = [1,0,2];
			var selAssets = -10;
			for (i => charFile in charProperties.asset_files) {
				if (charFile.char_side != null && charFile.char_side != 3 && charFile.char_side == charType){continue;} // This if statement hurts my brain
				if (charFile.stage != "" && charFile.stage != null){if(PlayState.curStage.toLowerCase() != charFile.stage.toLowerCase()){continue;}} // Check if charFiletion specifies stage, skip if it doesn't match PlayState's stage
				if (charFile.song != "" && charFile.song != null){if(PlayState.SONG.song.toLowerCase() != charFile.song.toLowerCase()){continue;}} // Check if charFiletion specifies song, skip if it doesn't match PlayState's song
				var tagsMatched = 0;
				if (charFile.tags != null && charFile.tags[0] != null && PlayState.stageTags != null){
					for (i in charFile.tags) {if (PlayState.stageTags.contains(i)) tagsMatched++;}
					if (tagsMatched == 0) continue;
				}
				
				if (forced == 0 || tagsMatched == forced)
					selAssets = i;
			}
			if (selAssets != -10){
				if (charProperties.asset_files[selAssets].png != null )pngName=charProperties.asset_files[selAssets].png;
				if (charProperties.asset_files[selAssets].xml != null )xmlName=charProperties.asset_files[selAssets].xml;
				if (charProperties.asset_files[selAssets].animations != null )charProperties.animations=charProperties.asset_files[selAssets].animations;
				if (charProperties.asset_files[selAssets].animations_offsets != null )charProperties.animations_offsets=charProperties.asset_files[selAssets].animations_offsets;
			}
		}


		if (tex == null){
			var charJsonF:String = ('mods/characters/$curCharacter/${xmlName}').substr(0,-3) + "json";
			if (FileSystem.exists(charJsonF)){
				charXml = File.getContent(charJsonF); 				
				if (charXml == null){handleError('$curCharacter is missing their sprite JSON?');} // Boot to main menu if character's XML can't be loaded

				tex = FlxAtlasFrames.fromTexturePackerJson(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$curCharacter/${pngName}')), charXml);
			} else {
				charXml = File.getContent('mods/characters/$curCharacter/${xmlName}'); // Loads the XML as a string
				if (charXml == null){handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's XML can't be loaded
				tex = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$curCharacter/${pngName}')), charXml);
			}
			if (tex == null){handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's texture can't be loaded
		}
		trace('Loaded "mods/characters/$curCharacter/${pngName}"');
		frames = tex;


		if (charProperties == null) trace("No charProperites?");
		// if(charProperties.sprites != null && charProperties.sprites[0] != null){
		// 	for (i in charProperties.sprites) {
		// 		var e = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$curCharacter/${i}.png')), File.getContent('mods/characters/$curCharacter/${i}.xml'));
		// 		for (i => v in e.framesHash) {
		// 			frames.framesHash[i] = v;
		// 		}
		// 	}
		// }


		loadJSONChar(charProperties);
		// Custom misses
		if (charType == 0 && !amPreview && !debugMode){
			switch(charProperties.custom_misses){
				case 1: // Custom misses using FNF Multi custom sounds
					useMisses = true;
					missSounds = [Sound.fromFile('mods/characters/$curCharacter/custom_left.ogg'), Sound.fromFile('mods/characters/$curCharacter/custom_down.ogg'), Sound.fromFile('mods/characters/$curCharacter/custom_up.ogg'),Sound.fromFile('mods/characters/$curCharacter/custom_right.ogg')];
				case 2: // Custom misses using Predefined sound names
					useMisses = true;
					missSounds = [Sound.fromFile('mods/characters/$curCharacter/miss_left.ogg'), Sound.fromFile('mods/characters/$curCharacter/miss_down.ogg'), Sound.fromFile('mods/characters/$curCharacter/miss_up.ogg'),Sound.fromFile('mods/characters/$curCharacter/miss_right.ogg')];
			}
		}
		if (FlxG.save.data.playVoices && charProperties.voices == "custom") {
			useVoices = true;
			voiceSounds = [new FlxSound().loadEmbedded(Sound.fromFile('mods/characters/$curCharacter/custom_left.ogg')), new FlxSound().loadEmbedded(Sound.fromFile('mods/characters/$curCharacter/custom_down.ogg')), new FlxSound().loadEmbedded(Sound.fromFile('mods/characters/$curCharacter/custom_up.ogg')),new FlxSound().loadEmbedded(Sound.fromFile('mods/characters/$curCharacter/custom_right.ogg'))];

		}
		if (!amPreview && FileSystem.exists('mods/characters/$curCharacter/script.hscript')){
			parseHScript(File.getContent('mods/characters/$curCharacter/script.hscript'));
			trace("Loaded HScript");
			callInterp("initScript",[],true);
		}
		 // Checks which animation to play, if dance_idle is true, play GF/Spooky dance animation, otherwise play normal idle

		trace('Finished loading character, Lets get funky!');
		}
	

	public static function newChar(x:Float, y:Float, ?character:String = "", ?isPlayer:Bool = false,?charType:Int = 0,?exitex:FlxAtlasFrames = null,?charJson:CharacterJson = null,?useHscript:Bool = true):Character{
		var e = new Character(x,y,character,isPlayer,charType,exitex,charJson);
		e.hscriptGen = true;
		return e;
	}

	public function handleError(error:String){
		interp = null;
		if (!amPreview && PlayState.instance != null){
			PlayState.instance.handleError(error);
		}else{
			MainMenuState.handleError(error);
		}
	}


	public function new(x:Float, y:Float, ?character:String = "", ?isPlayer:Bool = false,?charType:Int = 0,?preview:Bool = false,?exitex:FlxAtlasFrames = null,?charJson:CharacterJson = null,?useHscript:Bool = true) // CharTypes: 0=BF 1=Dad 2=GF
	{try{

		super(x, y);
		trace('Loading ${character}');
		animOffsets = ["all" => [0,0] ];
		// animOffsets['all'] = [0.0, 0.0];
		if (character == ""){
			switch(charType){
				case 0:character = "bf";
				case 1:character = "dad";
				case 2:character = "gf";
			}
		}
		curCharacter = character;
		this.charType = charType;
		this.useHscript = useHscript;
		if (curCharacter == 'dad'){dadVar = 6.1;}
		this.isPlayer = isPlayer;
		amPreview = preview;

		animation = new CharAnimController(this);

		if(charJson != null) charProperties = charJson;
		switch(charType){case 1:definingColor = FlxColor.RED;default:definingColor = FlxColor.GREEN;}
		
		if (exitex != null) tex = exitex;
		antialiasing = true;
		if (Reflect.field(TitleState.defCharJson.aliases,curCharacter) != null) curCharacter = Reflect.field(TitleState.defCharJson.aliases,curCharacter); // Due to some haxe weirdness, need to use reflect
		if (Reflect.field(TitleState.defCharJson.characters,curCharacter) != null){
			loadVanillaChar(Reflect.field(TitleState.defCharJson.characters,curCharacter));
			trace("Loaded vanilla json character");
		}else {
			trace("Not a JSON built-in char");
			switch (curCharacter) // Seperate statement for duplicated character paths
			{
				case 'gf':
					// GIRLFRIEND CODE
					tex = Paths.getSparrowAtlas('characters/GF_assets');
				case 'gf-christmas':
					tex = Paths.getSparrowAtlas('characters/gfChristmas');
				case 'mom':
					tex = Paths.getSparrowAtlas('characters/Mom_Assets');
				case 'mom-car':
					tex = Paths.getSparrowAtlas('characters/momCar');
				case 'monster-christmas':
					tex = Paths.getSparrowAtlas('characters/monsterChristmas');
				case 'monster':
					tex = Paths.getSparrowAtlas('characters/Monster_Assets');
				case 'bf':
					tex = Paths.getSparrowAtlas('characters/BOYFRIEND');
				case 'bf-christmas':
					tex = Paths.getSparrowAtlas('characters/bfChristmas');
				case 'bf-car':
					tex = Paths.getSparrowAtlas('characters/bfCar');
			}
			switch (curCharacter)
			{
				case 'lonely','Lonely':
					tex = Paths.getSparrowAtlas('onlinemod/lonely');
					frames=tex;
					addAnimation('Idle', 'Idle', 24, false);
					visible = false;


				case 'gf','gf-christmas': // Condensed to reduce duplicate code
					// GIRLFRIEND CODE
					frames = tex;
					dance_idle = true;
					addAnimation('cheer', 'GF Cheer', 24, false);
					addAnimation('singLEFT', 'GF left note', 24, false);
					addAnimation('singRIGHT', 'GF Right Note', 24, false);
					addAnimation('singUP', 'GF Up Note', 24, false);
					addAnimation('singDOWN', 'GF Down Note', 24, false);
					addAnimation('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					addAnimation('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					addAnimation('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					addAnimation('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					addAnimation('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					addAnimation('scared', 'GF FEAR', 24);

					addOffsets('gf');

					playAnim('danceRight');
				case 'gf-car':
					tex = Paths.getSparrowAtlas('characters/gfCar');
					frames = tex;
					addAnimation('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
					addAnimation('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					addAnimation('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
						false);
					dance_idle = true;

					addOffsets('gf-car');
					playAnim('danceRight');
				case 'gf-pixel':
					tex = Paths.getSparrowAtlas('characters/gfPixel');
					frames = tex;
					addAnimation('singUP', 'GF IDLE', [2], "", 24, false);
					addAnimation('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					addAnimation('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					dance_idle = true;
					addOffsets('gf-pixel');
					playAnim('danceRight');
					

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
					antialiasing = false;
				case 'dad':
					// DAD ANIMATION LOADING CODE
					tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
					frames = tex;
					addAnimation('idle', 'Dad idle dance', 24);
					addAnimation('singUP', 'Dad Sing Note UP', 24);
					addAnimation('singRIGHT', 'Dad Sing Note RIGHT', 24);
					addAnimation('singDOWN', 'Dad Sing Note DOWN', 24);
					addAnimation('singLEFT', 'Dad Sing Note LEFT', 24);

					addOffsets("dad");

					playAnim('idle');
				case 'spooky':
					tex = Paths.getSparrowAtlas('characters/spooky_kids_assets');
					frames = tex;
					addAnimation('singUP', 'spooky UP NOTE', 24, false);
					addAnimation('singDOWN', 'spooky DOWN note', 24, false);
					addAnimation('singLEFT', 'note sing left', 24, false);
					addAnimation('singRIGHT', 'spooky sing right', 24, false);
					addAnimation('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
					addAnimation('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

					dance_idle = true;
					addOffsets('spooky');

					playAnim('danceRight');
				case 'mom','mom-car': // Condensed to reduce duplicate code
					frames = tex;

					addAnimation('idle', "Mom Idle", 24, false);
					addAnimation('singUP', "Mom Up Pose", 24, false);
					addAnimation('singDOWN', "MOM DOWN POSE", 24, false);
					addAnimation('singLEFT', 'Mom Left Pose', 24, false);
					// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
					// CUZ DAVE IS DUMB!
					addAnimation('singRIGHT', 'Mom Pose Left', 24, false);

					addOffsets('mom');

					playAnim('idle');
				case 'monster','monster-christmas': // Condensed to reduce duplicate code
					frames = tex;
					addAnimation('idle', 'monster idle', 24, false);
					addAnimation('singUP', 'monster up note', 24, false);
					addAnimation('singDOWN', 'monster down', 24, false);
					addAnimation('singLEFT', 'Monster left note', 24, false);
					addAnimation('singRIGHT', 'Monster Right note', 24, false);

					addOffsets('monster');
					playAnim('idle');
				case 'pico':
					tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss');
					frames = tex;
					addAnimation('idle', "Pico Idle Dance", 24);
					addAnimation('singUP', 'pico Up note0', 24, false);
					addAnimation('singDOWN', 'Pico Down Note0', 24, false);

					addAnimation('singLEFT', 'Pico Note Right0', 24, false);
					addAnimation('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					addAnimation('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					addAnimation('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);

					addAnimation('singUPmiss', 'pico Up note miss', 24);
					addAnimation('singDOWNmiss', 'Pico Down Note MISS', 24);

					addOffsets('pico');

					playAnim('idle');

					flipX = true;
				case 'bf','bf-christmas','bf-car':// Condensed to reduce duplicate code
					frames = tex;

					addAnimation('idle', 'BF idle dance', 24, false);
					addAnimation('singUP', 'BF NOTE UP0', 24, false);
					// WHY DO THESE NEED TO BE FLIPPED?
					addAnimation('singLEFT', 'BF NOTE RIGHT0', 24, false); 
					addAnimation('singRIGHT', 'BF NOTE LEFT0', 24, false);
					addAnimation('singDOWN', 'BF NOTE DOWN0', 24, false);
					addAnimation('singUPmiss', 'BF NOTE UP MISS', 24, false);
					addAnimation('singRIGHTmiss', 'BF NOTE LEFT MISS', 24, false);
					addAnimation('singLEFTmiss', 'BF NOTE RIGHT MISS', 24, false);
					addAnimation('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					addAnimation('hey', 'BF HEY', 24, false);

					addAnimation('firstDeath', "BF dies", 24, false);
					addAnimation('deathLoop', "BF Dead Loop", 24, true);
					addAnimation('deathConfirm', "BF Dead confirm", 24, false);

					addAnimation('scared', 'BF idle shaking', 24);

					addOffsets('bf');

					playAnim('idle');

					flipX = true;
				case 'bf-pixel':
					frames = Paths.getSparrowAtlas('characters/bfPixel');
					addAnimation('idle', 'BF IDLE', 24, false);
					addAnimation('singUP', 'BF UP NOTE', 24, false);
					// Flipped for some reason
					addAnimation('singLEFT', 'BF RIGHT NOTE', 24, false);
					addAnimation('singRIGHT', 'BF LEFT NOTE', 24, false);
					addAnimation('singDOWN', 'BF DOWN NOTE', 24, false);
					addAnimation('singUPmiss', 'BF UP MISS', 24, false);
					addAnimation('singRIGHTmiss', 'BF LEFT MISS', 24, false);
					addAnimation('singLEFTmiss', 'BF RIGHT MISS', 24, false);
					addAnimation('singDOWNmiss', 'BF DOWN MISS', 24, false);
					addOffsets('bf-pixel');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					playAnim('idle');

					width -= 100;
					height -= 100;

					antialiasing = false;

					flipX = true;
				case 'bf-pixel-dead':
					frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
					addAnimation('singUP', "BF Dies pixel", 24, false);
					addAnimation('firstDeath', "BF Dies pixel", 24, false);
					addAnimation('deathLoop', "Retry Loop", 24, true);
					addAnimation('deathConfirm', "RETRY CONFIRM", 24, false);
					animation.play('firstDeath');

					addOffset('firstDeath');
					addOffset('deathLoop', -37);
					addOffset('deathConfirm', -37);
					playAnim('firstDeath');
					// pixel bullshit
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					antialiasing = false;
					flipX = true;
				case 'senpai':
					frames = Paths.getSparrowAtlas('characters/senpai');

					addAnimation('idle', 'Senpai Idle', 24, false);
					addAnimation('singUP', 'SENPAI UP NOTE', 24, false);
					addAnimation('singLEFT', 'SENPAI LEFT NOTE', 24, false);
					addAnimation('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
					addAnimation('singDOWN', 'SENPAI DOWN NOTE', 24, false);

					addOffsets("senpai");

					playAnim('idle');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					antialiasing = false;
				case 'senpai-angry':
					frames = Paths.getSparrowAtlas('characters/senpai');
					addAnimation('idle', 'Angry Senpai Idle', 24, false);
					addAnimation('singUP', 'Angry Senpai UP NOTE', 24, false);
					addAnimation('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
					addAnimation('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
					addAnimation('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

					addOffsets('senpai-angry');
					playAnim('idle');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					antialiasing = false;
				case 'spirit':
					frames = Paths.getPackerAtlas('characters/spirit');
					addAnimation('idle', "idle spirit_", 24, false);
					addAnimation('singUP', "up_", 24, false);
					addAnimation('singRIGHT', "right_", 24, false);
					addAnimation('singLEFT', "left_", 24, false);
					addAnimation('singDOWN', "spirit down_", 24, false);
					addOffsets('spirit');
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					spiritTrail = true;
					playAnim('idle');

					antialiasing = false;
				case 'parents-christmas':
					frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets');
					addAnimation('idle', 'Parent Christmas Idle', 24, false);
					addAnimation('singUP', 'Parent Up Note Dad', 24, false);
					addAnimation('singDOWN', 'Parent Down Note Dad', 24, false);
					addAnimation('singLEFT', 'Parent Left Note Dad', 24, false);
					addAnimation('singRIGHT', 'Parent Right Note Dad', 24, false);

					addAnimation('singUP-alt', 'Parent Up Note Mom', 24, false);

					addAnimation('singDOWN-alt', 'Parent Down Note Mom', 24, false);
					addAnimation('singLEFT-alt', 'Parent Left Note Mom', 24, false);
					addAnimation('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

					addOffsets('parents-christmas');
					hasAlts=true;

					playAnim('idle');
				default: // Custom characters pog
					loadCustomChar();
			}
		}

		dance();
		// var alloffset = animOffsets.get("all");
		if (clonedChar == ""){
			clonedChar = curCharacter;
		}
		for (i in ['RIGHT','UP','LEFT','DOWN']) { // Add main animations over miss if miss isn't present
			if (animation.getByName('sing${i}miss') == null){
				cloneAnimation('sing${i}miss', animation.getByName('sing$i'));
				tintedAnims.push('sing${i}miss');
			}
		}

		if (charType == 2 && !curCharacter.startsWith("gf")){ // Checks if GF is not girlfriend
			this.curCharacter = "gf";
			if(animation.getByName('danceRight') == null){ // Convert sing animations into dance animations for when put as GF
				cloneAnimation('danceRight',animation.getByName('singRIGHT'));
				cloneAnimation('danceLeft',animation.getByName('singLEFT'));
				
			}	
			if (!clonedChar.startsWith("gf")){ // Force offset if clone is not GF
				charY+=200;
			}
		}
		this.y += charY;
		this.x += charX;
		if (isPlayer && animation.getByName('singRIGHT') != null && flip && flipNotes)
		{
			flipX = !flipX;

				// var animArray
			var oldRight = animation.getByName('singRIGHT').frames;
			animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
			animation.getByName('singLEFT').frames = oldRight;

			// IF THEY HAVE MISS ANIMATIONS??
			if (animation.getByName('singRIGHTmiss') != null)
			{
				var oldMiss = animation.getByName('singRIGHTmiss').frames;
				animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
				animation.getByName('singLEFTmiss').frames = oldMiss;
			}
		}
		dance();

		callInterp("new",[]);
		if (animation.curAnim != null) setOffsets(animation.curAnim.name); // Ensures that offsets are properly applied
	
		if(animation.curAnim == null && !lonely && !amPreview){MainMenuState.handleError('$curCharacter is missing an idle/dance animation!');}
		}catch(e){
			#if debug
			trace('Error with $curCharacter: ${e.stack} ${e.message}');
			#end
			MainMenuState.handleError('Error with $curCharacter: ${e}');
			return;
		}
	}

	override function update(elapsed:Float)
	{	try{

		if(!amPreview){
			if(animation.curAnim.finished && loopAnimTo[animation.curAnim.name] != null) playAnim(loopAnimTo[animation.curAnim.name]);
			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;
			if (!isPlayer)
			{
				if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
				{
					holdTimer = 0;
					dance();
				}
			}
			if(dance_idle || charType == 2){
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
			}
			callInterp("update",[elapsed]);
		}

		super.update(elapsed);
	}catch(e:Dynamic){MainMenuState.handleError('Caught character "update" crash: ${e}');}}


	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?ignoreDebug:Bool = false)
	{
		if (amPreview){
			if (dance_idle || charType == 2 || curCharacter == "spooky"){
				playAnim('danceRight');
			}else{playAnim('idle');}
		}
		else if ((!debugMode || ignoreDebug) && !amPreview)
		{

			if(dance_idle || charType == 2 || curCharacter == "spooky"){
				if (animation.curAnim == null || (!animation.curAnim.name.startsWith('hair') && animation.curAnim.finished))
				{
					// danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				}
			}else{
				playAnim('idle');
			}
		}
	}
	// Added for Animation debug
	public function idleEnd(?ignoreDebug:Bool = false)
	{
		if (!debugMode || ignoreDebug)
		{
			if (dance_idle || charType == 2){
				playAnim('danceRight', true, false, animation.getByName('danceRight').numFrames - 1);
			}else{
				switch (curCharacter)
				{
					case 'gf' | 'gf-car' | 'gf-christmas' | 'gf-pixel' | "spooky":
						playAnim('danceRight', true, false, animation.getByName('danceRight').numFrames - 1);
					default:
						playAnim('idle', true, false, animation.getByName('idle').numFrames - 1);
				}
			}
		}
	}
	public function setOffsets(?AnimName:String = "",?offsetX:Float = 0,?offsetY:Float = 0){
		if (tintedAnims.contains(animation.curAnim.name)){this.color = 0x330066;}else{this.color = 0xffffff;}
		
		var daOffset = animOffsets.get(AnimName); // Get offsets
		var offsets:Array<Float> = [offsetX,offsetY];
		if (animOffsets.exists(AnimName)) // Set offsets if animation has any
		{
			offsets[0]+=daOffset[0];
			offsets[1]+=daOffset[1];
		}
		offsets[0]+=animOffsets["all"][0]; // Add "all" offsets
		offsets[1]+=animOffsets["all"][1];
		offset.set(offsets[0], offsets[1]); // Set offsets
	}
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0,?offsetX:Float = 0,?offsetY:Float = 0)
	{
		var lastAnim = "";
		
		if (PlayState.instance != null) PlayState.instance.callInterp("playAnim",[AnimName,this]);

		if (PlayState.canUseAlts && animation.getByName(AnimName + '-alt') != null)
			AnimName = AnimName + '-alt'; // Alt animations
		if (animation.curAnim != null){lastAnim = animation.curAnim.name;}
		if (animation.curAnim != null && !animation.curAnim.finished && oneShotAnims.contains(animation.curAnim.name) && !oneShotAnims.contains(AnimName)){return;} // Don't do anything if the current animation is oneShot
		callInterp("playAnim",[AnimName]);
		if (skipNextAnim){
			skipNextAnim = false;
			return;
		}
		if(nextAnimation != ""){
			AnimName = nextAnimation;
			nextAnimation = "";
		}

		if (animation.getByName(AnimName) == null) return;
		if(AnimName == lastAnim && loopAnimFrames[AnimName] != null){Frame = loopAnimFrames[AnimName];}
		animation.play(AnimName, Force, Reversed, Frame);
		if ((debugMode || amPreview) || animation.curAnim != null && AnimName != lastAnim){
		
			setOffsets(AnimName,offsetX,offsetY);
		} // Skip if already playing, no need to calculate offsets and such

		if (dance_idle && lastAnim != AnimName )
		{
			switch(AnimName){
				case 'singLEFT', 'singLEFT-alt', 'danceLeft','danceLeft-alt':
					danced = true;
				case 'singRIGHT', 'singRIGHT-alt', 'danceRight', 'danceRight-alt':
					danced = false;
				case 'singUP', 'singDOWN' ,'singUP-alt', 'singDOWN-alt':
					danced = !danced;
			}
		}
		skipNextAnim = false;
	}
	public function playAnimAvailable(animList:Array<String>){
		for (i in animList) {
			if(animation.getByName(i) != null){
				playAnim(i);
				return;
			}
		}
	}
	public function cloneAnimation(name:String,anim:FlxAnimation){
		try{

		if(!amPreview && anim != null){
			animation.add(name,anim.frames,anim.frameRate,anim.flipX);
			if (animOffsets.exists(anim.name)){
				addOffset(name,animOffsets[anim.name][0],animOffsets[anim.name][1],true);
			}
		}
		}catch(e)MainMenuState.handleError('Caught character "cloneAnimation" crash: ${e.message}');
	}
	public function addOffset(name:String, x:Float = 0, y:Float = 0,?custom:Bool = false,?replace:Bool = false)
	{
		
		if (needsInverted == 2 && !isPlayer || needsInverted == 3 && isPlayer){
			x=-x;
		}	
		if (animOffsets[name] == null || replace){ // If animation is null, just add the offsets out right
			animOffsets[name] = [x, y];
		}else{ // If animation is not null, add the offsets to the existing ones
			animOffsets[name] = [animOffsets[name][0] + x, animOffsets[name][1] + y];
		}
	}
	public function addAnimation(anim:String,prefix:String,?indices:Array<Int>,?postFix:String = "",?fps:Int = 24,?loop:Bool = false){
		if(amPreview){
			animationList.push({
				anim : anim,
				name : prefix,
				indices : (if (indices != null && indices.length > 0)indices else []),
				fps : fps,
				loop : loop
			});
		}
		if (indices != null && indices.length > 0) { // Add using indices if specified
			animation.addByIndices(anim, prefix,indices,postFix, fps, loop);
		}else{
			animation.addByPrefix(anim, prefix, fps, loop);
		}
	}
}
