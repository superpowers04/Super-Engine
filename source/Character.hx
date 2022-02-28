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
import tjson.Json;

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
	public var animationPriorities:Map<String,Int> = [
		"singLEFT-alt" => 10,
		"singDOWN-alt" => 10,
		"singUP-alt" => 10,
		"singRIGHT-alt" => 10,
		"singLEFT" => 10,
		"singDOWN" => 10,
		"singUP" => 10,
		"singRIGHT" => 10,
		// Copy of the above but lower case because it's funny and I'm dumb
		"singleft-alt" => 10,
		"singdown-alt" => 10,
		"singup-alt" => 10,
		"singright-alt" => 10,
		"singleft" => 10,
		"singdown" => 10,
		"singup" => 10,
		"singright" => 10,

		"idle" => 0,
		"Idle" => 0,// Can never remember if it's idle or Idle
		"danceRight" => 0,
		"danceLeft" => 0,
		"danceright" => 0,
		"danceleft" => 0,
		"hey" => 5,
		"cheer" => 5,
		"scared" => 5,
		"win" => 100,
		"lose" => 100,
		"hurt" => 10,
		"hit" => 10,
		"attack" => 10,
		"shoot" => 10,
		"dodge" => 10,
		"dodgeLeft" => 10,
		"dodgeRight" => 10,
		"dodgeUp" => 10,
		"dodgeDown" => 10,
		"dodgeleft" =>10,
		"dodgeright" => 10,
		"dodgeup" => 10,
		"dodgedown" => 10,
		"songStart" => 7
];
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
	public var charLoc:String = "mods/characters";

	// public var spriteArr:Array<FlxSprite> = [];
	// public var animArr:Array<FlxAnimationController> = [];
	// public var animGraphics:Map<String,Int> = [];
	// public var xmlMap:Map<String,Int> = [];
	// public var curSprite:Int = 0;


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
			
			interp.variables.set("hscriptPath", '${charLoc}/$curCharacter');
			interp.variables.set("charName", curCharacter);
			interp.variables.set("charProperties", charProperties);
			interp.variables.set("PlayState", PlayState );
			interp.variables.set("BRtools",new HSBrTools('${charLoc}/$curCharacter/'));
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
			}
		}else{
			var e:Dynamic = Reflect.field(TitleState.defCharJson.characters,curCharacter);
			loadOffsetsFromJSON(e);
			getDefColor(e);

		}
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
		}/*else if(charType != 3){

			var hi = new HealthIcon(curCharacter, false,clonedChar);
			var colors:Map<Int,Int> = [];
			var max:Int = 0;
			var maxColor:Int = 0;
			for(X in 0 ...hi.pixels.width){
				for(Y in 0...hi.pixels.height){
					var curColor:Int = hi.pixels.getPixel(X,Y);
					if(curColor == 0) continue;
					colors[curColor] = (colors.exists(curColor) ? 0 : colors[curColor] + 1);
					if(colors[curColor] > max){maxColor = curColor;max=colors[curColor];}
				}
			}
			trace(maxColor);
			definingColor = maxColor;
			hi.destroy();
		}*/
	}
	function loadJSONChar(charProperties:CharacterJson){
		
		trace('Loading Json animations!');
		// Check if the XML has BF's animations, if so, add them





		dadVar = charProperties.sing_duration; // As the varname implies
		flipX=charProperties.flip_x; // Flip for BF clones
		spiritTrail=charProperties.spirit_trail; // Spirit TraiL
		antialiasing = !charProperties.no_antialiasing; 
		// dance_idle = charProperties.dance_idle; // Handles if the character uses Spooky/GF's dancing animation

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
				if(anima.priority != null || 0 > anima.priority){
					animationPriorities[anima.name] = anima.priority;
				}else if(animationPriorities[anima.name] == null){
					animationPriorities[anima.name] = 1;

				}
				animCount++;
			}
		}
		trace('Registered ${animCount} animations');
		if(!hasIdle){
			if(amPreview){
				var idleName:String = "";
				{ // Load characters without a idle animation, hopefully
					var regTP:EReg = (~/<SubTexture name="([A-z 0-9]+[iI][dD][lL][eE][A-z 0-9]+)[0-9][0-9][0-9][0-9]"/gm);
					var input:String = charXml;
					while (regTP.match(input)) {
						input=regTP.matchedRight();
						idleName = regTP.matched(1);
						break;
					}
				}
				charProperties.animations = Json.parse('[{
						"anim":"idle",
						"name":"${idleName}",
						"loop":false,
						"fps":24,
						"indices":[],
						"oneshot":false
					}]');
			}else{
				var hasBFAnims:Bool = false;
				{
					var regTP:EReg = (~/<SubTexture name="BF idle dance/g);
					var input:String = charXml;
					while (regTP.match(input)) {
						hasBFAnims = true;
						break;
					}
				}
				if (hasBFAnims){ // Legacy shit I guess
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
		}
		dance_idle = animation.getByName("danceLeft") != null;
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
	public function isSelectedChar():Bool{
		switch ( charType ) {
			default: return FlxG.save.data.playerChar == curCharacter;
			case 1: return FlxG.save.data.opponent == curCharacter;
			case 2: return FlxG.save.data.gfChar == curCharacter;
		}
	}

	function loadCustomChar(){
		if(TitleState.retChar(curCharacter) != "" && !amPreview) curCharacter = TitleState.retChar(curCharacter); // Make sure you're grabbing the right character
		trace('Loading a custom character "$curCharacter"! ');				
		if(charLoc == "mods/characters" && TitleState.weekChars[curCharacter] != null && TitleState.weekChars[curCharacter].contains(onlinemod.OfflinePlayState.nameSpace) && TitleState.characterPaths[onlinemod.OfflinePlayState.nameSpace + "|" + curCharacter] != null){
			charLoc = TitleState.characterPaths[onlinemod.OfflinePlayState.nameSpace + "|" + curCharacter];
			trace('$curCharacter is loading from $charLoc');
		}else if(charLoc == "mods/characters" && TitleState.characterPaths[curCharacter] != null){
			charLoc = TitleState.characterPaths[curCharacter];
			trace('$curCharacter is loading from $charLoc');
		}
		isCustom = true;
		var charPropJson:String = "";
		if(!FileSystem.exists('${charLoc}/$curCharacter/config.json') && charProperties == null){
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
				charProperties = Json.parse('{
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
				// loadChar('bfHC');
			}
		}else{

			try{
				if (charProperties == null) {charPropJson = File.getContent('${charLoc}/$curCharacter/config.json');charProperties = Json.parse(CoolUtil.cleanJSON(charPropJson));}
			}catch(e){
				MainMenuState.handleError('Character ${curCharacter} has a broken config.json! ${e.message}');
				// loadChar('bfHC');

				return;
			}
		}
		if ((charProperties == null || charProperties.animations == null || charProperties.animations[0] == null) && !amPreview){handleError('$curCharacter\'s JSON is invalid!');} // Boot to main menu if character's JSON can't be loaded
		// if ((charProperties == null || charProperties.animations == null || charProperties.animations[0] == null) && amPreview){

		// }
		loadedFrom = '${charLoc}/$curCharacter/config.json';
		if(frames == null){


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
				var charJsonF:String = ('${charLoc}/$curCharacter/${xmlName}').substr(0,-3) + "json";
				if (FileSystem.exists(charJsonF)){
					charXml = File.getContent(charJsonF); 				
					if (charXml == null){handleError('$curCharacter is missing their sprite JSON?');} // Boot to main menu if character's XML can't be loaded

					tex = FlxAtlasFrames.fromTexturePackerJson(FlxGraphic.fromBitmapData(BitmapData.fromFile('${charLoc}/$curCharacter/${pngName}')), charXml);
				} else {
					charXml = File.getContent('${charLoc}/$curCharacter/${xmlName}'); // Loads the XML as a string
					if (charXml == null){handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's XML can't be loaded
					tex = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('${charLoc}/$curCharacter/${pngName}')), charXml);
				}
				if (tex == null){handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's texture can't be loaded
			}
			trace('Loaded "${charLoc}/$curCharacter/${pngName}"');
		}
		frames = tex;


		if (charProperties == null) trace("No charProperites?");
		// spriteArr = [this];
		// animArr = [animation];
		// if(charProperties.sprites != null && charProperties.sprites[0] != null){
		// 	{
		// 	var oldXML = charXml;
		// 	charXml = '<?xml version="1.0" encoding="utf-8"?><TextureAtlas imagePath="yeth.png">';
		// 		var regTP:EReg = (~/<SubTexture name="([A-z0-9\-_ .,\\\|]+)[0-9][0-9][0-9][0-9]" .*\/>/gm);
		// 		var input:String = oldXML;
		// 		while (regTP.match(input)) {
		// 			input=regTP.matchedRight();
		// 			// trace(regTP.matched(1).toLowerCase());
		// 			charXml += regTP.matched(0);
		// 		}
		// 	}
		// 	for (it => i in charProperties.sprites) {
		// 		if(!(FileSystem.exists('${charLoc}/$curCharacter/${i}.xml') && FileSystem.exists('${charLoc}/$curCharacter/${i}.png'))){
		// 			MainMenuState.handleError('Invalid sprite $curCharacter/${i}');
		// 			break;
		// 		}
		// 		var xml = File.getContent('${charLoc}/$curCharacter/${i}.xml');
		// 		var animCount = 0;
		// 		var regTP:EReg = (~/<SubTexture name="([A-z0-9\-_ .,\\\|]+)[0-9][0-9][0-9][0-9]" .*\/>/gm);
		// 		var input:String = xml;
		// 		while (regTP.match(input)) {
		// 			input=regTP.matchedRight();
		// 			// trace(regTP.matched(1).toLowerCase());
		// 			if (xmlMap[regTP.matched(1).toLowerCase()] == null){
		// 				xmlMap[regTP.matched(1).toLowerCase()] = spriteArr.length;
		// 				trace('Registered ${regTP.matched(1).toLowerCase()}');
		// 				animCount++;
		// 			}
		// 			charXml += regTP.matched(0);
		// 		}

		// 		var spr = new FlxSprite(0,0); 
		// 		spr.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('${charLoc}/$curCharacter/${i}.png')),xml);
		// 		// graphicsArr.push(frames);
		// 		// animArr.push(animation);
		// 		spriteArr.push(spr);
		// 		setSprite(spriteArr.length - 1);
		// 		trace('Registered extra sprite "${charLoc}/$curCharacter/${i}.png" with ${animCount}');
		// 		// for (i => v in e.framesHash) {
		// 		// 	frames.framesHash[i] = v;
		// 		// }
		// 	}
		// 	charXml += "\n</TextureAtlas>";
		// // 	// File.saveContent("/tmp/test.xml",charXml);
		// // 	File.saveBytes("/tmp/test.png",newImg.image.encode(PNG,100));
		// 	frames = FlxAtlasFrames.fromSparrow(frames.parent, charXml);
		// }


		loadJSONChar(charProperties);
		// Custom misses
		if (charType == 0 && !amPreview && !debugMode){
			switch(charProperties.custom_misses){
				case 1: // Custom misses using FNF Multi custom sounds
					useMisses = true;
					missSounds = [Sound.fromFile('${charLoc}/$curCharacter/custom_left.ogg'), Sound.fromFile('${charLoc}/$curCharacter/custom_down.ogg'), Sound.fromFile('${charLoc}/$curCharacter/custom_up.ogg'),Sound.fromFile('${charLoc}/$curCharacter/custom_right.ogg')];
				case 2: // Custom misses using Predefined sound names
					useMisses = true;
					missSounds = [Sound.fromFile('${charLoc}/$curCharacter/miss_left.ogg'), Sound.fromFile('${charLoc}/$curCharacter/miss_down.ogg'), Sound.fromFile('${charLoc}/$curCharacter/miss_up.ogg'),Sound.fromFile('${charLoc}/$curCharacter/miss_right.ogg')];
			}
		}
		if (FlxG.save.data.playVoices && charProperties.voices == "custom") {
			useVoices = true;
			voiceSounds = [new FlxSound().loadEmbedded(Sound.fromFile('${charLoc}/$curCharacter/custom_left.ogg')), new FlxSound().loadEmbedded(Sound.fromFile('${charLoc}/$curCharacter/custom_down.ogg')), new FlxSound().loadEmbedded(Sound.fromFile('${charLoc}/$curCharacter/custom_up.ogg')),new FlxSound().loadEmbedded(Sound.fromFile('${charLoc}/$curCharacter/custom_right.ogg'))];

		}
		if (!amPreview && FileSystem.exists('${charLoc}/$curCharacter/script.hscript')){
			parseHScript(File.getContent('${charLoc}/$curCharacter/script.hscript'));
			trace("Loaded HScript");
			callInterp("initScript",[],true);
		}
		 // Checks which animation to play, if dance_idle is true, play GF/Spooky dance animation, otherwise play normal idle

		trace('Finished loading character, Lets get funky!');
		}



	public static function newChar(x:Float, y:Float, ?character:String = "", ?isPlayer:Bool = false,?charType:Int = 0,?exitex:FlxAtlasFrames = null,?charJson:CharacterJson = null,?useHscript:Bool = true):Character{
		var e = new Character(x,y,character,isPlayer,charType,exitex,charJson);
		if(PlayState.instance.songStarted){
			PlayState.instance.showTempmessage("Please load characters before song start to prevent lag during song!",FlxColor.RED);
		}
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

	function loadChar(?char:String = ""){
			if(char != "")curCharacter = char;
			if(TitleState.retChar(curCharacter) == "") char = "bf";
			
			switch (curCharacter) // Seperate statement for duplicated character paths
			{
				case 'gf':
					// GIRLFRIEND CODE
					frames = tex = Paths.getSparrowAtlas('characters/GF_assets');
				case 'bf','bfHC':
					frames = tex = Paths.getSparrowAtlas('characters/BOYFRIEND');
			}

			switch (curCharacter)
			{

				case 'bf':// Hardcoded to atleast have a single character
					charProperties = Json.parse(BFJSON);
				case 'gf':// The game crashes if she doesn't exist, BF and GF must not be seperated
					charProperties = Json.parse(GFJSON);

			}
			loadCustomChar();
	}


	public function new(x:Float, y:Float, ?character:String = "", ?isPlayer:Bool = false,?charType:Int = 0,?preview:Bool = false,?exitex:FlxAtlasFrames = null,?charJson:CharacterJson = null,?useHscript:Bool = true,?charPath:String = "") // CharTypes: 0=BF 1=Dad 2=GF
	{
		#if !debug 
		try{
		#end
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
		if(charPath != "") charLoc = charPath;


		if(TitleState.retChar(curCharacter) == null && charProperties == null && !amPreview && exitex == null){
			curCharacter = "bf";
		}

		animation = new CharAnimController(this);

		if(charJson != null) charProperties = charJson;
		if(!amPreview) switch(charType){case 1:definingColor = FlxColor.RED;default:definingColor = FlxColor.GREEN;} else definingColor = FlxColor.WHITE;
		
		if (exitex != null) tex = exitex;
		antialiasing = true;
		if (Reflect.field(TitleState.defCharJson.aliases,curCharacter) != null) curCharacter = Reflect.field(TitleState.defCharJson.aliases,curCharacter); // Due to some haxe weirdness, need to use reflect
		else {
			// trace("Not a JSON built-in char");

			loadChar();
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
		animation.finishCallback = function(name:String){
			callInterp("animFinish",[animation.curAnim]);
		};
		animation.callback = function(name:String,frameNumber:Int,frameIndex:Int){
			callInterp("animFrame",[animation.curAnim,frameNumber,frameIndex]);
		};
		if(animation.curAnim == null && !lonely && !amPreview){MainMenuState.handleError('$curCharacter is missing an idle/dance animation!');}
		if(animation.getByName('songStart') != null && !lonely && !amPreview){
			playAnim('songStart');
		}
		#if !debug
		}catch(e){

			MainMenuState.handleError('Error with $curCharacter: ${e}');
			return;
		}
		#end
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
	var baseColor = 0xffffff;
	var tintColor = 0x330066;
	public function setOffsets(?AnimName:String = "",?offsetX:Float = 0,?offsetY:Float = 0){
		if (tintedAnims.contains(animation.curAnim.name) && this.color != tintColor){baseColor = color;color = tintColor;}else if(this.color == tintColor){this.color = baseColor;}
		
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
	// function setSprite(?id:Int = 0){
	// 	if(curSprite != id){
	// 		if(spriteArr[id] == null){
	// 			MainMenuState.handleError('$curCharacter: sprite with id $id doesn\'t exist! This should NOT happen!');
	// 		}
	// 		curSprite = id;
	// 		pixels = spriteArr[curSprite].pixels;
	// 		// animation.stop();
	// 		// animation = animArr[id];
	// 		// frames = graphicsArr[id];
	// 		trace('Changing sprite to $id');
	// 	}
	// }
	override function draw(){
		callInterp("draw",[]);
		super.draw();
	} 

	public dynamic function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0,?offsetX:Float = 0,?offsetY:Float = 0)
	{
		var lastAnim = "";
		if (PlayState.instance != null) PlayState.instance.callInterp("playAnim",[AnimName,this]);

		if (PlayState.canUseAlts && animation.getByName(AnimName + '-alt') != null)
			AnimName = AnimName + '-alt'; // Alt animations
		if (animation.curAnim != null){
			lastAnim = animation.curAnim.name;
			if(animation.curAnim.name != AnimName && !animation.curAnim.finished){
				if (animationPriorities[animation.curAnim.name] != null && animationPriorities[animation.curAnim.name] > animationPriorities[AnimName] ){return;} // Skip if current animation has a higher priority
				if (animationPriorities[animation.curAnim.name] == null && !animation.curAnim.finished && oneShotAnims.contains(animation.curAnim.name) && !oneShotAnims.contains(AnimName)){return;} // Don't do anything if the current animation is oneShot
			}
		}
		callInterp("playAnim",[AnimName]);
		if (skipNextAnim){
			skipNextAnim = false;
			return;
		}
		if(nextAnimation != ""){
			AnimName = nextAnimation;
			nextAnimation = "";
		}
		// setSprite(animGraphics[AnimName.toLowerCase()]);

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

	// Handles adding animations
	public function addAnimation(anim:String,prefix:String,?indices:Array<Int>,?postFix:String = "",?fps:Int = 24,?loop:Bool = false){
		// animGraphics[anim.toLowerCase()] = ((xmlMap[prefix.toLowerCase()] != null) ? xmlMap[prefix.toLowerCase()] : 0);
		// setSprite(animGraphics[anim.toLowerCase()]);
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


	static var BFJSON = '{
			"no_antialiasing": false, 
			"sing_duration": 4, 
			"dance_idle": false, 
			"embedded":true,
			"path":"characters/BOYFRIEND",
			"scale": 1, 

			"flip_x": true, 
			"spirit_trail": false, 
			"color":[49,176,209],

			"animations":
			[
				{
					"anim": "idle",
					"name": "BF idle dance",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "singUP",
					"name": "BF NOTE UP0",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "singDOWN",
					"name": "BF NOTE DOWN0",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "singRIGHT",
					"name": "BF NOTE LEFT0",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "singLEFT",
					"name": "BF NOTE RIGHT0",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "singUPmiss",
					"name": "BF NOTE UP0",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "singDOWNmiss",
					"name": "BF NOTE DOWN0",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "singLEFTmiss",
					"name": "BF NOTE LEFT0",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "singRIGHTmiss",
					"name": "BF NOTE RIGHT0",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "hey",
					"name": "BF HEY",
					"fps": 24,
					"loop": false,
					"indices": []
				},
				{
					"anim": "scared",
					"name": "BF idle shaking",
					"fps": 24,
					"loop": true,
					"indices": []
				},
				{"anim":"dodge","name": "boyfriend dodge","oneshot":true,"fps": 24,"loop": false,"indices":[]},
				{"anim":"attack","name": "boyfriend attack","oneshot":true,"fps": 24,"loop": false,"indices":[]},
				{"anim":"hit","name": "boyfriend hit","oneshot":true,"fps": 24,"loop": false,"indices":[]},
				{"anim":"preattack","name": "bf pre attack","oneshot":true,"fps": 24,"loop": false,"indices":[]},
				{"anim":"dies","name": "bf dies","oneshot":true,"fps": 24,"loop": false,"indices":[]}

				
			], 

			"animations_offsets":
			[			
				{
					"anim": "idle",
					"player1": [0, 0],
					"player2": [0, 0]
				},
				{
					"anim": "singUP",
					"player1": [-45, 25],
					"player2": [5, 30]
				},
				{
					"anim": "singRIGHT",
					"player1": [-40, -7],
					"player2": [-35, -5.5]
				},
				{
					"anim": "singLEFT",
					"player1": [8, -6],
					"player2": [40, -5]
				},
				{
					"anim": "singDOWN",
					"player1": [-20, -50],
					"player2": [-20, -50]
				},
				{
					"anim": "singUPmiss",
					"player1": [-41, 25],
					"player2": [1, 30]
				},
				{
					"anim": "singRIGHTmiss",
					"player1": [-34, 21],
					"player2": [-35.8, 20.5]
				},
				{
					"anim": "singLEFTmiss",
					"player1": [8, 20],
					"player2": [40, 23]
				},
				{
					"anim": "singDOWNmiss",
					"player1": [-20, -20],
					"player2": [-20, -20]
				}
			],

			"hey_anim": "hey", 
			"scared_anim": "scared", 

			"common_stage_offset": [0, 0, 0, 0], 
			"char_pos": [0, -300], 
			"cam_pos": [0, 300],
		}';

	static var GFJSON = '{
	"animations_offsets": [
		{
			"player1": [0, 0],
			"player2": [-2, -8],
			"player3": [-2, -17],
			"anim": "scared"
		},
		{
			"player1": [0, 0],
			"player2": [0, 0],
			"player3": [0, -9],
			"anim": "danceRight"
		},
		{
			"player1": [0, 0],
			"player2": [0, -11],
			"player3": [0, -20],
			"anim": "singDOWN"
		},
		{
			"player1": [0, 0],
			"player2": [0, 0],
			"player3": [0, -9],
			"anim": "danceLeft"
		},
		{
			"player1": [0, 0],
			"player2": [0, 13],
			"player3": [0, 4],
			"anim": "singUP"
		},
		{
			"player1": [0, 0],
			"player2": [45, 0],
			"player3": [45, -8],
			"anim": "hairBlow"
		},
		{
			"player1": [0, 0],
			"player2": [0, -11],
			"player3": [0, -20],
			"anim": "singRIGHT"
		},
		{
			"player1": [0, 0],
			"player2": [0, 9],
			"player3": [0, 0],
			"anim": "cheer"
		},
		{
			"player1": [0, 0],
			"player2": [0, 0],
			"player3": [0, -9],
			"anim": "hairFall"
		},
		{
			"player1": [0, 0],
			"player2": [0, -10],
			"player3": [0, -19],
			"anim": "singLEFT"
		},
		{
			"player1": [0, 0],
			"player2": [-2, -12],
			"player3": [0, -18],
			"anim": "sad"
		}
	],
	"dance_idle": true,
	"no_antialiasing": false,
	"cam_pos": [0, 0],
	"sing_duration": 4,
	"flip_x": false,
	"genBy": "FNFBR; Animation Editor",
	"like": null,
	"spirit_trail": false,
	"common_stage_offset": [],
	"char_pos3": [0, 30],
	"offset_flip": 1,
	"scale": 1,
	"char_pos": [],
	"clone": "",
	"animations": [
		{
			"loop": false,
			"anim": "cheer",
			"fps": 24,
			"name": "GF Cheer",
			"indices": []
		},
		{
			"loop": false,
			"anim": "singLEFT",
			"fps": 24,
			"name": "GF left note",
			"indices": []
		},
		{
			"loop": false,
			"anim": "singRIGHT",
			"fps": 24,
			"name": "GF Right Note",
			"indices": []
		},
		{
			"loop": false,
			"anim": "singUP",
			"fps": 24,
			"name": "GF Up Note",
			"indices": []
		},
		{
			"loop": false,
			"anim": "singDOWN",
			"fps": 24,
			"name": "GF Down Note",
			"indices": []
		},
		{
			"loop": false,
			"anim": "sad",
			"fps": 24,
			"name": "gf sad",
			"indices": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
		},
		{
			"loop": false,
			"anim": "danceLeft",
			"fps": 24,
			"name": "GF Dancing Beat",
			"indices": [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
		},
		{
			"loop": false,
			"anim": "danceRight",
			"fps": 24,
			"name": "GF Dancing Beat",
			"indices": [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]
		},
		{
			"loop": false,
			"anim": "hairBlow",
			"fps": 24,
			"name": "GF Dancing Beat Hair blowing",
			"indices": [0, 1, 2, 3]
		},
		{
			"loop": false,
			"anim": "hairFall",
			"fps": 24,
			"name": "GF Dancing Beat Hair Landing",
			"indices": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
		},
		{
			"loop": false,
			"anim": "scared",
			"fps": 24,
			"name": "GF FEAR",
			"indices": []
		}
	],
	"embedded": true,
	"path": "characters/GF_assets",
	"color": "#A5004D",
	"cam_pos3": [0, 0]
}';


}
