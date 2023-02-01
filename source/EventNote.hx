package;
#if false
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;

import PlayState;

using StringTools; 

class EventNote extends FlxObject
{
	public var strumTime:Float = 0;
	public var type:Dynamic = 0; // Used for scriptable arrows 
	public static var noteNames:Array<String> = ["purple","blue","green",'red'];
	public var info:Array<Dynamic> = [];
	public var rawNote:Array<Dynamic> = [];


	dynamic public function hit(?charID:Int = 0,note:Note){
		switch (charID) {
			case 0:PlayState.instance.BFStrumPlayAnim(noteData);
			case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
		}; // Strums
		if(noteAnimation != null){
			PlayState.charAnim(charID,(if(noteAnimation == "")noteAnims[noteData] else noteAnimation),true); // Play animation
		}
	}
	public var killNote = false;

	static var psychChars:Array<Int> = [1,0,2]; // Psych uses different character ID's than SE


	public function new(strumTime:Float,?_type:Dynamic = 0,?rawNote:Array<Dynamic> = null)
	{try{
		super();
		

		if(rawNote == null){
			this.rawNote = [strumTime,_noteData,0];
		}else{
			this.rawNote = rawNote;

		}


		if(Std.isOfType(_type,String)) _type = _type.toLowerCase();


		switch (Std.string(rawNote[2]).toLowerCase()) {
			case "play animation" | "playanimation"| "playanim" | "animation" | "anim": {
				try{
					// Info can be set to anything, it's being used for storing the Animation and character
					info = [rawNote[3],
						// Psych uses different character ID's than SE, more charts will be coming from Psych than SE
						switch(Std.string(rawNote[4]).toLowerCase()){
							case "dad","opponent","0":1;
							case "gf","girlfriend","2":2;
							default:0;
						}
					]; 
				}catch(e){info = [rawNote[3],0];}
				// Replaces hit func
				hit = function(?charID:Int = 0,note){trace('Playing ${info[0]} for ${info[1]}');PlayState.charAnim(info[1],info[0],true);}; 
			}
			case "hey","hey!": {
				try{
					// Info can be set to anything, it's being used for storing the Animation and character
					info = [
						// Psych uses different character ID's than SE, more charts will be coming from Psych than SE
						switch(Std.string(rawNote[4]).toLowerCase()){
							case "dad","opponent","1":1;
							case "gf","girlfriend","2":2;
							default:0;
						}
					]; 
				}catch(e){info = [rawNote[3]];}
				// Replaces hit func
				hit = function(?charID:Int = 0,note){PlayState.charAnim(info[0],(if(info[0] == 2) "cheer" else "hey"),true);}; 
			}
			case "changebpm" | "bgm change": {
				try{
					info = [(if(rawNote[4] != "" && !Math.isNaN(Std.parseFloat(rawNote[4])))Std.parseFloat(rawNote[4]) else Std.parseFloat(rawNote[3]))]; 
				}catch(e){info = [120,0];}
				hit = function(?charID:Int = 0,note){Conductor.changeBPM(info[0]);}; 
				trace('BPM note processed');
			}
			case "changecharacter" | "change character" | "changechar" | "change char": {
				try{
					info = [Std.string(rawNote[3]),rawNote[4]];
					var _char = PlayState.getCharFromID(info[0]);
					if(_char == null || _char.curCharacter == "lonely" || _char.lonely){ // If this character isn't enabled, no reason to allow switching for it
						killNote = true;
					}else{
						var id = PlayState.getCharID(info[0]);
						info[0]=id;
						var name = info[1];
						if(PlayState.instance.cachedChars[id][name] == null){ // Absolutely no reason to cache the character again if it's already cached
							trace('Caching ${rawNote[3]}/${id}:${name} for changeChar note');

							var psChar = PlayState.getCharFromID(id);
							var cachingChar:Character = {x:psChar.x, y:psChar.y,character:name,isPlayer:psChar.isPlayer,charType:psChar.charType};
							PlayState.instance.cachedChars[id][name] = cachingChar;
							trace('Finished caching $name');
						}
						hit = function(?charID:Int = 0,note){
							var _char = PlayState.instance.cachedChars[info[0]][info[1]];
							if(_char == null){return;}
							// PlayState.charSet(charID,"visible",false);
							PlayState.instance.members[PlayState.instance.members.indexOf(PlayState.getCharFromID(info[0]))] = _char;
							Reflect.setProperty(PlayState,PlayState.getCharVariName(info[0]),_char);
							// PlayState.instance.add(_char);
						};

					}
					
				}catch(e){}
				// Replaces hit func
			}
			case "camflash" | "cameraflash" | "camera flash": {
				try{
					info = [Std.parseFloat(rawNote[3]),(if( Math.isNaN(Std.parseInt(rawNote[4]))) 0xFFFFFF else Std.parseInt(rawNote[4]))]; 
				}catch(e){info = [1];}
				// Replaces hit func
				hit = function(?charID:Int = 0,note){if(FlxG.save.data.distractions && FlxG.save.data.flashingLights) FlxG.camera.flash(info[2],info[1]);}; 

			}
			case "set camzoom" | "setcamzoom" | "camzoom": {
				try{
					info = [Std.parseFloat(rawNote[3])];
					if(Math.isNaN(info[0])) info[0] = 0.7;
				}catch(e){info = [0.7];}
				// Replaces hit func
				hit = function(?charID:Int = 0,note){PlayState.instance.defaultCamZoom = info[0];}; 

			}
			case "addcamerazoom" | "add camera zoom" | "add cam zoom" | "addcamzoom": {
				try{
					info = [Std.parseFloat(rawNote[3])]; 
					if(Math.isNaN(info[0])) info[0] = 0.05;
				}catch(e){info = [0.05];}
				// Replaces hit func
				hit = function(?charID:Int = 0,note){PlayState.instance.defaultCamZoom += info[0];}; 

			}
			case "screenshake" | "screen shake" | "shake screen": {
				try{
					info = [Std.parseFloat(rawNote[3]),Std.parseFloat(rawNote[4])];
					if(Math.isNaN(info[0])) info[0] = 0; 
					if(Math.isNaN(info[1])) info[1] = 0; 
				}catch(e){info = [0.7];}
				// Replaces hit func
				hit = function(?charID:Int = 0,note){if(FlxG.save.data.distractions) FlxG.camera.shake(info[0],info[1]);}; 
				trace('BPM note processed');
			}
			case "camera follow pos" | "camfollowpos" | "cam follow": {
				try{
					info = [Std.parseFloat(rawNote[3]),Std.parseFloat(rawNote[4])]; 
				}catch(e){info = [0.7];}
				// Replaces hit func
				hit = function(?charID:Int = 0,note){PlayState.instance.moveCamera = false; PlayState.instance.camFollow.x = info[0];PlayState.instance.camFollow.y = info[1];}; 

			}
			case "changescrollspeed": {
				try{
					info = [Std.parseFloat(rawNote[4])]; 
				}catch(e){info = [2,0];}
				// Replaces hit func
				hit = function(?charID:Int = 0,note){PlayState.SONG.speed = info[0];}; 
				trace('BPM note processed');
			}
			// case "hscript" | "script" | "runcode" | "haxe": {
			// 	try{
			// 		// Info can be set to anything, it's being used for storing the script
			// 		info = [rawNote[3],rawNote[4]]; 
			// 	}catch(e){info = [""];}
			// 	// Replaces hit func
			// 	hit = function(?charID:Int = 0,note){PlayState.instance.parseRun(rawNote[4],rawNote[3]);}; 
			// }
			case 'script','hscript':{
				info = [rawNote[4]]; 
				hit = function(?charID:Int = 0,note){PlayState.instance.parseRun(rawNote[4]);}; 
			}
			default:{ // Don't trigger hit animation
				hit = function(?charID:Int = 0,note){trace('Hit an empty event note ${note.type}.');return;};
			}
		}
		if(rawNote != null && PlayState.instance != null) PlayState.instance.callInterp("noteAdd",[this,rawNote]);
	}catch(e){MainMenuState.handleError(e,e,'Caught "Note create" crash: ${e.message}');}}

	var missedNote:Bool = false;
	override function draw(){
		if(!eventNote && showNote){
			super.draw();
		}
		// if(ntText != null){ntText.x = this.x;ntText.y = this.y;ntText.draw();}
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if ((!skipNote || isOnScreen())){ // doesn't calculate anything until they're on screen
			skipNote = false;
			visible = (!eventNote && showNote);
			PlayState.instance.callInterp("noteUpdate",[this]);

			if (strumTime <= Conductor.songPosition){

				this.hit(1,this);
				this.destroy();
			}
			PlayState.instance.callInterp("noteUpdateAfter",[this]);

		}
	}
}
#end