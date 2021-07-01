package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.DynamicAccess;
import lime.utils.Assets;
import lime.graphics.Image;
import CharacterJson;

import flash.media.Sound;

import sys.io.File;
import flash.display.BitmapData;
import Xml;
// import lime.graphics.Image as LimeImage;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var spiritTrail = false;
	public var camPos:Array<Int> = [0,0];
	public var charX:Int = 0;
	public var charY:Int = 0;
	public var camX = 0;
	public var camY = 0;
	var dadVar:Float = 4; // Singduration?
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var hasAlts:Bool = false;
	public var clonedChar:String = "";
	public var charType:Int = 0;
	public var dance_idle:Bool = false;
	public var amPreview:Bool = false;
	public var needsInverted:Bool= false;
	public var useMisses:Bool = false;
	public var missSounds:Array<Sound> = [];
	public var oneShotAnims:Array<String> = [];
	public var tintedAnims:Array<String> = [];

	public var holdTimer:Float = 0;
	public var stunned:Bool = false; // Why was this specific to BF?
	function addOffsets(?character:String = "bf") // Handles offsets for characters with support for clones
	{
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
			case 'gf-car':
				addOffset('all',0,30);
				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);
			case 'gf-pixel':
				addOffset('all',0,30);
				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);
			case "dad":
				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);
				camX+=400;
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
				charY-=200;
			case "pico":
				if(isPlayer){
					needsInverted = true;
					addOffset("singUP", 0, 29);
					addOffset("singRIGHT", 0, -11);
					addOffset("singLEFT", 0, 2);
					addOffset("singDOWN", 0, -76);
					addOffset("singUPmiss", 0, 67);
					addOffset("singRIGHTmiss", 0, 28);
					addOffset("singLEFTmiss", 0, 50);
					addOffset("singDOWNmiss", 0, -34);
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
				if(!isPlayer){camX+=600;}
			case 'bf','bf-christmas','bf-car':
				charY+=330;
				needsInverted = true;
				if (isPlayer){			
					addOffset('idle', -5);
					addOffset("singUP", 0, 27);
					// This game is handled terribly....					
					addOffset("singLEFT", -38, -7);
					addOffset("singRIGHT", 12, -6);
					addOffset("singDOWN", 0, -50);
					addOffset("singUPmiss", 0, 27);
					addOffset("singRIGHTmiss", 0, 21);
					addOffset("singLEFTmiss", 0, 24);
					addOffset("singDOWNmiss", 0, -19);
					addOffset("hey",0, 4);
					addOffset('firstDeath', 0, 11);
					addOffset('deathLoop', 0, 5);
					addOffset('deathConfirm', 0, 69);
				}else{ // Why the hell is this needed on the left but not the right?
					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singLEFT", -38, -7);
					addOffset("singRIGHT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);
				}
			case "bf-pixel":
				charY+=330;
			case 'spirit':
				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -240);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -200, -280);
				addOffset("singDOWN", 170, 110);
				charX-=150;
				charY-=100;
				camX+=300;

			case 'senpai':
				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);
				charX-=150;
				charY+=360;
				camX+=300;

			case 'senpai-angry':
				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);
				charX-=150;
				charY+=360;
				camX+=300;
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
	}

	public function new(x:Float, y:Float, ?character:String = "", ?isPlayer:Bool = false,?char_type:Int = 0,?preview:Bool = false) // CharTypes: 0=BF 1=Dad 2=GF
	{
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();
		animOffsets['all'] = [0, 0];
		if (character == ""){
			switch(char_type){
				case 0:character = "bf";
				case 1:character = "dad";
				case 2:character = "gf";
			}
		}
		curCharacter = character;
		charType = char_type;
		if (curCharacter == 'dad'){dadVar = 6.1;}
		this.isPlayer = isPlayer;
		amPreview = preview;

		var tex:FlxAtlasFrames = null; // Dunno why this fixed crash with BF but it did
		antialiasing = true;
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
				animation.addByPrefix('Idle', 'Idle', 24, false);
				visible = false;


			case 'gf','gf-christmas': // Condensed to reduce duplicate code
				// GIRLFRIEND CODE
				frames = tex;
				dance_idle = true;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffsets('gf');

				playAnim('danceRight');
			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);
				dance_idle = true;

				addOffsets('gf-car');
				playAnim('danceRight');
			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
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
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffsets("dad");

				playAnim('idle');
			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				dance_idle = true;
				addOffsets('spooky');

				playAnim('danceRight');
			case 'mom','mom-car': // Condensed to reduce duplicate code
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffsets('mom');

				playAnim('idle');
			case 'monster','monster-christmas': // Condensed to reduce duplicate code
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffsets('monster');
				playAnim('idle');
			case 'pico':
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);

				animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				addOffsets('pico');

				playAnim('idle');

				flipX = true;
			case 'bf','bf-christmas','bf-car':// Condensed to reduce duplicate code
				frames = tex;

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				// WHY DO THESE NEED TO BE FLIPPED?
				animation.addByPrefix('singLEFT', 'BF NOTE RIGHT0', 24, false); 
				animation.addByPrefix('singRIGHT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffsets('bf');

				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				// Flipped for some reason
				animation.addByPrefix('singLEFT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);
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
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
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

				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				addOffsets("senpai");

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffsets('senpai-angry');
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);
				addOffsets('spirit');
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				spiritTrail = true;
				playAnim('idle');

				antialiasing = false;
			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				addOffsets('parents-christmas');
				hasAlts=true;

				playAnim('idle');
			default: // Custom characters pog
				try{
					trace('Loading a custom character "$curCharacter"! ');				
					var charXml:String = File.getContent('mods/characters/$curCharacter/character.xml'); // Loads the XML as a string
					if (charXml == null){MainMenuState.handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's XML can't be loaded
					tex = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$curCharacter/character.png')), charXml);
					if (tex == null){MainMenuState.handleError('$curCharacter is missing their XML!');} // Boot to main menu if character's texture can't be loaded
					trace('Loaded character sheet');
					frames = tex;
					var charPropJson:String = File.getContent('mods/characters/$curCharacter/config.json');
					var charProperties:CharacterJson = haxe.Json.parse(charPropJson);
					if (charProperties.animations == null){MainMenuState.handleError('$curCharacter\'s JSON is invalid');} // Boot to main menu if character's JSON can't be loaded
					// BF's animations, Adding because they're used by default to provide support with FNF Multi
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					// WHY DO THESE NEED TO BE FLIPPED?
					animation.addByPrefix('singLEFT', 'BF NOTE RIGHT0', 24, false); 
					animation.addByPrefix('singRIGHT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);

					dadVar = charProperties.sing_duration; // As the varname implies
					flipX=charProperties.flip_x; // Flip for BF clones
					spiritTrail=charProperties.spirit_trail; // Spirit TraiL
					antialiasing = !charProperties.no_antialiasing; // Why was this inverted?
					dance_idle = charProperties.dance_idle; // Handles if the character uses Spooky/GF's dancing animation
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

					// if (charProperties.char_pos != null){charX+=charProperties.char_pos[0];charY+=charProperties.char_pos[1];}
					if (charProperties.char_pos != null){addOffset('all',charProperties.char_pos[0],charProperties.char_pos[1]);}
					if (charProperties.cam_pos != null){camX+=charProperties.cam_pos[0];camY+=charProperties.cam_pos[1];}
					
					trace('Loading Animations!');
					for (anima in charProperties.animations){
						try{if (anima.anim.substr(-4) == "-alt"){hasAlts=true;} // Alt Checking
						if (anima.stage != "" && anima.stage != null){if(PlayState.curStage != anima.stage){continue;}} // Check if animation specifies stage, skip if it doesn't match PlayState's stage
						if (anima.song != "" && anima.song != null){if(PlayState.SONG.song.toLowerCase() != anima.song.toLowerCase()){continue;}} // Check if animation specifies song, skip if it doesn't match PlayState's song
						if (animation.getByName(anima.anim) != null){continue;} // Skip if animation has already been defined
						if (anima.char_side != null && anima.char_side != 3 && anima.char_side != charType){continue;} // Probably better as a animation property instead of a if statement
						if (anima.ifstate != null){
							trace("Loading a animation with ifstatement...");
							if (anima.ifstate.check == 1 ){ // Do on step or beat
								if (PlayState.stepAnimEvents[charType] == null) PlayState.stepAnimEvents[charType] = [anima.anim => anima.ifstate]; else PlayState.stepAnimEvents[charType][anima.anim] = anima.ifstate;
							} else {
								if (PlayState.beatAnimEvents[charType] == null) PlayState.beatAnimEvents[charType] = [anima.anim => anima.ifstate]; else PlayState.beatAnimEvents[charType][anima.anim] = anima.ifstate;
							}
							
							// PlayState.regAnimEvent(charType,anima.ifstate,anima.anim);
						}
						if (anima.oneshot == true){ // "On static platforms, null can't be used as basic type Bool" bruh
							oneShotAnims.push(anima.anim);
							anima.loop = false; // Looping when oneshot is a terrible idea
						}

						if (anima.indices.length > 0) { // Add using indices if specified
							animation.addByIndices(anima.anim, anima.name,anima.indices,"", anima.fps, anima.loop);
						}else{animation.addByPrefix(anima.anim, anima.name, anima.fps, anima.loop);}
						}catch(e){MainMenuState.handleError('${curCharacter} had an animation error ${e.message}');break;}
					}
					
					setGraphicSize(Std.int(width * charProperties.scale)); // Setting size
					updateHitbox();// I honestly don't know what this does, other resized characters use it so ¯\_(ツ)_/¯

					clonedChar = '${charProperties.clone}';
					if (clonedChar != "") {
						trace('Character clones $clonedChar copying their offsets!');
						addOffsets(clonedChar);
					}
					trace('Adding custom offsets');
					var offsetCount = 0;
					for (offset in charProperties.animations_offsets){ // Custom offsets
						offsetCount++;
						addOffset(offset.anim,offset.player1[0],offset.player1[1],true);
					}	
					if (charType == 0 && charProperties.char_pos2 != null){addOffset('all',charProperties.char_pos2[0],charProperties.char_pos2[1]);}
					if (charType == 1 && charProperties.char_pos1 != null){addOffset('all',charProperties.char_pos1[0],charProperties.char_pos1[1]);}
					if (charType == 2 && charProperties.char_pos3 != null){addOffset('all',charProperties.char_pos3[0],charProperties.char_pos3[1]);}
					addOffset('all',charProperties.common_stage_offset[0],charProperties.common_stage_offset[1]); // Load common stage offset
					camX+=charProperties.common_stage_offset[0];
					camY-=charProperties.common_stage_offset[1]; // Load common stage offset for camera too
					trace('Loaded ${offsetCount} offsets!');
					 // Checks which animation to play, if dance_idle is true, play GF/Spooky dance animation, otherwise play normal idle

					trace('Finished loading character, Lets get funky!');
				}catch(e){
					trace('Error with $curCharacter: ' + e.message + "");
					MainMenuState.handleError('Error with $curCharacter: ' + e.message + "");
					return;
				}			
		}

		dance();
		var alloffset = animOffsets.get("all");
		// if (animOffsets.exists('all'))
		// {
		// 	this.setPosition(x+alloffset[0],y+alloffset[1]);
		// }
		if (clonedChar == ""){
			clonedChar = curCharacter;
		}
		for (i in ['RIGHT','UP','LEFT','DOWN']) { // Add main animations over alts if alt isn't present
			if (animation.getByName('sing$i-alt') == null){
				cloneAnimation('sing$i-alt', animation.getByName('sing$i'));
			}
		}
		for (i in ['RIGHT','UP','LEFT','DOWN']) { // Add main animations over alts if alt isn't present
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
		if (isPlayer && !amPreview && animation.getByName('singRIGHT') != null)
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
		if (dance_idle || charType == 2 || curCharacter == "spooky"){
			playAnim('danceRight');
		}else{
			playAnim('idle');
		}
	}

	override function update(elapsed:Float)
	{	
		if(!amPreview && animation.curAnim != null){			// WHY IS CURANIM NEVER SET?
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
					dance();
					holdTimer = 0;
				}
			}

			// switch (curCharacter)
			// {
			// 	case 'gf':
			// 		if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			// 			playAnim('danceRight');
			// }
			if(dance_idle || charType == 2){
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
			}
		}
		super.update(elapsed);
	}

	private var danced:Bool = false;

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

			if(dance_idle || charType == 2 || curCharacter == "spooky"){ // And I condensed it even more by providing a dance_idle option...
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
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		var lastAnim = "";
		if (animation.curAnim != null){lastAnim = animation.curAnim.name;}
		if (animation.curAnim != null && !animation.curAnim.finished && oneShotAnims.contains(animation.curAnim.name)){return;} // Don't do anything if the current animation is oneShot
		animation.play(AnimName, Force, Reversed, Frame);
		
		if (tintedAnims.contains(animation.curAnim.name)){this.color = 0x330066;}else{this.color = 0xffffff;}
		// if (animation.curAnim != null && animation.curAnim.name == AnimName){return;} // Skip if already playing, no need to calculate offsets and such

		var daOffset = animOffsets.get(AnimName); // Get offsets
		var offsets:Array<Float> = [0,0];
		if (animOffsets.exists(AnimName)) // Set offsets if animation has any
		{
			offsets[0]+=daOffset[0];
			offsets[1]+=daOffset[1];
		}
		offsets[0]+=animOffsets["all"][0]; // Add "all" offsets
		offsets[1]+=animOffsets["all"][1];
		offset.set(offsets[0], offsets[1]); // Set offsets

		if (dance_idle && lastAnim != AnimName )
		{
			switch(AnimName){
				case 'singLEFT', 'danceLeft':
					danced = true;
				case 'singRIGHT', 'danceRight':
					danced = false;
				case 'singUP', 'singDOWN':
					danced = !danced;
			}
		}
	}
	public function cloneAnimation(name:String,anim:FlxAnimation):Void{
		if(!amPreview && anim != null){
			animation.add(name,anim.frames,anim.frameRate,anim.flipX);
		}
	}
	public function addOffset(name:String, x:Float = 0, y:Float = 0,?custom = false):Void
	{
		if (needsInverted && !custom){
			x=-x;
		}	
		if (animOffsets[name] == null){ // If animation is null, just add the offsets out right
			animOffsets[name] = [x, y];
		}else{ // If animation is not null, add the offsets to the existing ones
			animOffsets[name] = [animOffsets[name][0] + x, animOffsets[name][1] + y];
		}
	}
}
