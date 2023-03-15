package;


import hscript.Expr;
import hscript.Interp;
import hscript.InterpEx;
import hscript.ParserEx;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import selua.*;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

using StringTools;

class ScriptMusicBeatState extends MusicBeatState{
	public static var instance:ScriptMusicBeatState;
	/*Interpeter stuff*/

	
		var created = false;
		var lastErr = "";
		public override function errorHandle(?error:String = "No error passed!",?forced:Bool = false){
			try{

				resetInterps();
				parseMoreInterps = false;
				if(!created && !forced){
				// 	if(errorMsg == "") errorMsg = error; 
				// 	// else trace(error);
				// 	startedCountdown = true;
				// 	// updateTime = true;
				// 	// new FlxTimer().start(0.5,function(_){
				// 	// 	errorHandle(error,true);
				// 	// });
					lastErr = error;
					LoadingScreen.loadingText = 'ERROR!';
					return;
				}
				trace('Error!\n ${error}');
				// errorMsg = "";
				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();
				// updateTime = false;

				// var _forced = (!songStarted && !forced && playCountdown);
				// generatedMusic = false;
				persistentUpdate = false;
				persistentDraw = true;

				Main.game.blockUpdate = Main.game.blockDraw = false;
				if(forced){
					MainMenuState.handleError(error,true);
					return;
				}
				openSubState(new ErrorSubState(0,0,error));
			}catch(e){trace('${e.message}\n${e.stack}');MainMenuState.handleError(error);
			}
		}
		// Interp or SELua
		public var interps:Map<String,Dynamic> = new Map(); 
		public var interpCount:Int = 0;
		public var parseMoreInterps:Bool = false;
		public var brtools:Map<String,HSBrTools> = new Map();
		public var cancelCurrentFunction:Bool = false;
		public var useNormalCallbacks:Bool = false;
		public var ignoreScripts:Array<String> = [
			"state",
			"options"
		];

		public function callSingleInterp(func_name:String, args:Array<Dynamic>,id:String){
			cancelCurrentFunction = false;
			var _interp = interps[id];
			try{
				if (_interp == null) {throw('Interpter ${id} doesn\'t exist!');return;}
				if(_interp is Interp){

					var method = _interp.variables.get(func_name);
					if (method == null) {return;}
					// trace('$func_name:$id $args');
					
					Reflect.callMethod(_interp,method,args);
					return;
				}
				#if linc_luajit
				if(_interp is SELua){
					_interp.call(func_name,args);
					return;
				}
				#end
			}catch(e:Dynamic){
				if(e is hscript.Expr.Error){
					var line = '';
					try{
						line = ':"${_interp.variables.get('scriptContents').split('\n')[Std.int(e.line) - 1]}"';
					}catch(e){line="";trace(e.message);}
					errorHandle(HscriptUtils.genErrorMessage(e,func_name,id));
				}else{
					errorHandle(e.message);
				}
			}
		}
		public function closeInterp(id){
			instance.unloadInterp(id);
		}

		public function callInterp(func_name:String, args:Array<Dynamic>,?id:String = "") { // Modified from Modding Plus, I am too dumb to figure this out myself
				cancelCurrentFunction = false;
				if(!parseMoreInterps) return;
				try{
					if (id == "") {
						for (name in interps.keys()) {
							callSingleInterp(func_name,args,name);
							if(cancelCurrentFunction) return;
						}
					}else callSingleInterp(func_name,args,id);
				}catch(e:hscript.Expr.Error){errorHandle('${func_name} for "${id}":\n ${e.toString()}');}

			}
		@:keep inline public function resetInterps() {interps = new Map();interpCount=0;HSBrTools.shared.clear();}
		@:keep inline public function unloadInterp(?id:String){
			interpCount--;interps.remove(id);
		}
		public function revealToInterp(value:Dynamic,name:String,id:String){
			if ((interps[id] == null )) {return;}
			interps[id].variables.set(name,value); 

		}
		public function getFromInterp(name:String,id:String,?remove:Bool = false,?defVal:Dynamic = null):Dynamic{
			if ((interps[id] == null )) {return defVal;}
			var e = interps[id].variables.get(name); 
			if(remove) interps[id].variables.set(name,null);
			return e;
		}
		
		public function parseRun(?script:String = "",?id:String = "song"){
			if(script == ""){return;}
			if(interps[id] == null){
				parseHScript(script,null,id,"eval");
			}else{
				var parser = new hscript.Parser();
				try{
					parser.allowTypes = parser.allowJSON = parser.allowMetadata = true;
					interps[id].execute(parser.parseString(script));
				}catch(e){
					errorHandle('Error parsing ${id} runtime hscript, Line:${parser.line};\n Error:${e.message}');
				}
			}
		}
		#if linc_luajit
		public function parseLua(?songScript:String = "",?brTools:HSBrTools = null,?id:String = "song",?file:String = "hscript"):SELua{
			// Scripts are forced with weeks, otherwise, don't load any scripts if scripts are disabled
			if(!parseMoreInterps) return null;

			if(songScript == "" || !songScript.contains('isSE = true') && !songScript.contains('function initScript')) return null;
			// if (brTools == null) brTools = hsBrTools;
			try{

				// parser.parseModule(songScript);
				var interp:SELua = new SELua(songScript);
				if (brTools != null) {
					// interp.variables.set("BRtools",brTools,true); 
					interp.variables.set("BRtoolsRef",brTools); 
					// brTools.reset();
				}else {
					// interp.variables.set("BRtools", getBRTools("assets/"),true);
					interp.variables.set("BRtoolsRef",getBRTools("assets/")); 
				}
				// if(interp.get('isSE') == null && interp.get('initScript') == null){
				// 	interp.stop();
				// 	showTempmessage('${id}/${file} isn\'t a valid SE Script!',FlxColor.RED);
				// 	return null;
				// }
				// Access current state without needing to be inside of a function with ps as an argument
				interp.variables.set("scriptContents",songScript);
				addVariablesToLua(interp);
				interp.variables.set("scriptName",id);
				// interp.variables.set("require",require);
				interp.variables.set("close",closeInterp); // Closes a script
				interps[id] = interp;
				if(brTools != null) brTools.reset();
				callInterp("initScript",[],id);
				interpCount++;
				trace('Loaded lua script ${id} from "$file"!');
				return interp;
			}catch(e){
				errorHandle('Error parsing ${id} lua script\n ${e.message}');
				return null;
				// interp = null;
			}
		}
		public function addVariablesToLua(interp:SELua){
			interp.variables.set("state",cast (this)); 
			interp.variables.set("game",cast (this));
		}
		#end
		public function parseHScript(?songScript:String = "",?brTools:HSBrTools = null,?id:String = "song",?file:String = "hscript"):Interp{
			// Scripts are forced with weeks, otherwise, don't load any scripts if scripts are disabled
			if(!parseMoreInterps) return null;

			if(songScript == "") return null;
			// if (brTools == null && hsBrTools != null) brTools = hsBrTools;
			var parser:hscript.Parser = HscriptUtils.createSimpleParser();
			var interp:Interp = HscriptUtils.createSimpleInterp();
			try{

				var program = parser.parseString(songScript,file);

				if (brTools != null) {
					interp.variables.set("BRtools",brTools); 
				}else {
					interp.variables.set("BRtools", getBRTools("assets/"));
				}
				// Access current state without needing to be inside of a function with ps as an argument
				interp.variables.set("scriptContents",songScript);
				interp.variables.set("scriptName",id);
				addVariablesToHScript(interp);
				interp.variables.set("close",closeInterp); // Closes a script

				interp.execute(program);
				interps[id] = interp;
				if(brTools != null)brTools.reset();
				callInterp("initScript",[],id);
				interpCount++;
			}catch(e){
				var _line = '${parser.line}';
				try{
					var _split = songScript.split('\n');
					_line = '${parser.line};"${_split[parser.line - 1]}"';
				}catch(e){_line = '${parser.line}';}
				errorHandle('Error parsing ${id} hscript\nLine:${_line}\n ${e.message}');
				return null;
			}
			trace('Loaded hscript ${id} from "$file"!');
			return interp;
		}

		public function addVariablesToHScript(interp:Interp){
			interp.variables.set("state",cast (this)); 
			interp.variables.set("game",cast (this));
		}

		@:keep inline public function getBRTools(path:String = "./assets/",?id:String = ""):HSBrTools{
			if(brtools[path] == null) brtools[path] = new HSBrTools(path,id);
			return brtools[path];
		}
		public function requireScript(v:String,?important:Bool = false,?nameSpace:String = "requirement",?script:String = ""):Bool{
			// if(QuickOptionsSubState.getSetting("Song hscripts") && onlinemod.OnlinePlayMenuState.socket == null){return false;}
			if(interps['${nameSpace}-${v}'] != null || interps['global-${v}'] != null) return true; // Don't load the same script twice
			trace('Checking for ${v}');
			if (SELoader.exists('mods/scripts/${v}/script.hscript')){
				parseHScript(SELoader.loadText('mods/scripts/${v}/script.hscript'),getBRTools('mods/scripts/${v}',v),'${nameSpace}-${v}','mods/scripts/${v}/script.hscript');
			// }else if (FileSystem.exists('mods/dependancies/${v}/script.hscript')){
			// 	parseHScript(File.getContent('mods/dependancies/${v}/script.hscript'),new HSBrTools('mods/dependancies/${v}',v),'${nameSpace}-${v}');
			}else{showTempmessage('Script \'${v}\'' + (if(script == "") "" else ' required by \'${script}\'') + ' doesn\'t exist!');}
			if(important && interps['${nameSpace}-${v}'] == null){errorHandle('$script is missing a script: $v!');}
			return ((interps['${nameSpace}-${v}'] == null));
		}
		public function require(v:String,nameSpace:String):Bool{
			// if(QuickOptionsSubState.getSetting("Song hscripts") && onlinemod.OnlinePlayMenuState.socket == null){return false;}
			trace('Checking for ${v}');
			if(interps[nameSpace] == null) {
				trace('Unable to load $v: $nameSpace doesn\'t exist!');
				return false;
			}
			if (SELoader.exists('mods/${v}') || SELoader.exists('mods/scripts/${v}/script.hscript')){
				var parser = new hscript.Parser();
				try{
					parser.allowTypes = parser.allowJSON = parser.allowMetadata = true;

					var program;
					// parser.parseModule(songScript);
					program = parser.parseString(SELoader.loadText('mods/scripts/${v}/script.hscript'));
					interps[nameSpace].execute(program);
				}catch(e){
					errorHandle('Unable to load $v for $nameSpace:${e.message}');
					return false;
				}
				// parseHScript(,new HSBrTools('mods/scripts/${v}',v),'${nameSpace}-${v}');
			}else{showTempmessage('Unable to load $v for $nameSpace: Script doesn\'t exist');}
			return ((interps['${nameSpace}-${v}'] == null));
		}
		public function loadSingleScript(scriptPath:String){
			if(!parseMoreInterps) return;

			for (i in ignoreScripts) {
				if(scriptPath.contains(i)) return;
			}
			var path = scriptPath.substr(0,scriptPath.lastIndexOf("/"));
			var scriptName = scriptPath.substr(scriptPath.lastIndexOf("/"));
			var parentDir = path.substr(0,path.lastIndexOf("/"));
			parentDir = parentDir.substr(parentDir.lastIndexOf("/"));

			#if linc_luajit
			if(scriptPath.endsWith('.lua')) parseLua(SELoader.loadText(scriptPath),getBRTools(path),'${parentDir}:${scriptName}',scriptPath);
			else
			#end
				parseHScript(SELoader.loadText(scriptPath),getBRTools(path),'${parentDir}:${scriptName}',scriptPath);
			
		}
		var scriptSubDirectory:String = ""; 
		public function loadScript(v:String,?path:String = "mods/scripts/",?nameSpace:String="global",?brtool:HSBrTools = null){
			if(!parseMoreInterps) return;
			var _path = '${path}${v}${scriptSubDirectory}';
			trace(_path);
			if (SELoader.exists(_path)){
				
				if(brtool == null) brtool = getBRTools(_path,v);
				for (i in CoolUtil.orderList(SELoader.readDirectory(_path))) {
					if(i.endsWith(".hscript") ||
					#if linc_luajit
					i.endsWith(".lua") ||
					#end i.endsWith(".hx")){
						var cont = false;
						for (i in ignoreScripts) {
							if(v.contains(i)) cont = true;
						}
						if(cont) continue;
						#if linc_luajit
						if(i.endsWith(".lua")) parseLua(SELoader.loadText('$_path/$i'),brtool,'$nameSpace-${i}','$_path/$i');
						else 
						#end
							parseHScript(SELoader.loadText('$_path/$i'),brtool,'$nameSpace-${i}','$_path/$i');
						
					}
				}
				// parseHScript(File.getContent('mods/scripts/${v}/script.hscript'),new HSBrTools('mods/scripts/${v}',v),'global-${v}');
			}
		}
		@:keep public function loadScripts(?enableScripts:Bool = false,?enableCallbacks:Bool = false,?force:Bool = false){
			if((!enableScripts && !parseMoreInterps) || (!FlxG.save.data.menuScripts && !force)) return;
			parseMoreInterps = true;
			try{

				for (i in 0 ... FlxG.save.data.scripts.length) {
					if(!parseMoreInterps) break;
					var v = FlxG.save.data.scripts[i];
					LoadingScreen.loadingText = 'Loading scripts: $v';
					var _v = v.substr(v.lastIndexOf('/'));
					if(v.lastIndexOf('/') > v.length - 2){
						_v = v.substring(0,v.lastIndexOf('/') - 1).substring(_v.lastIndexOf('/'));
					}
					loadScript(v,null,'USER/' + _v);
				}
			}catch(e){errorHandle('Error while trying to parse scripts: ${e.message}');}
		}

		/*Soft reloads a state, i.e reloading scripts. This will not reload hsbrtools as to prevent crashes. Use a normal reset for that
		*/
		public function softReloadState(?showWarning:Bool = true){
			if(!parseMoreInterps){
				showTempmessage('You are currently unable to reload interpeters!',FlxColor.RED);
				return;
			}
			callInterp('reload',[false]);
			callInterp('unload',[]);
			FlxTimer.globalManager.clear();
			FlxTween.globalManager.clear();
			resetInterps();
			loadScripts();
			callInterp('reloadDone',[]);
			if(showWarning) showTempmessage('Soft reloaded state. This is unconventional, Hold shift and press F5 for a proper state reload');
		}

	/* Base Functions */
		/* Zero Args */
			override public function new(){
				super();
				instance = this;
			}
			override public function create(){
				super.create();
				instance = this;

				created = true;
				if(lastErr != ""){
					errorHandle(lastErr);
					lastErr = "";
					return;
				}
				callInterp('reloadDone',[]);
				callInterp('createAfter',[]);
			}
			override public function draw(){
				if(useNormalCallbacks){
					callInterp('draw',[]);
					if(cancelCurrentFunction) return;
				}
				super.draw();
			}
			override public function destroy(){
				if(useNormalCallbacks){

					callInterp('destroy',[]);
					instance = null;
				}
				super.destroy();
			}
			override public function beatHit(){
				if(useNormalCallbacks){
					callInterp('beatHit',[]);
					
					if(cancelCurrentFunction) return;
				}
				super.beatHit();
			}
			override public function stepHit(){
				callInterp('stepHit',[]);
				
				if(cancelCurrentFunction) return;
				super.stepHit();
			}

		/* One Arg*/

			override public function update(e:Float){
				if(FlxG.save.data.animDebug && FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F5){
					if(FlxG.keys.pressed.SHIFT){
						callInterp('unload',[]);
						callInterp('reload',[true]);
						FlxG.resetState();
					}else{
						softReloadState();
					}
				}
				if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F6){
					callInterp('unload',[]);
					resetInterps();
					showTempmessage('Unloaded interpeters!');
				}
				if(useNormalCallbacks){
					callInterp('update',[e]);
					if(cancelCurrentFunction) return;
				}
				super.update(e);
			}
			override public function openSubState(s:FlxSubState){
				if(useNormalCallbacks){
					callInterp('openSubState',[s]);
					if(cancelCurrentFunction) return null;
				}
				return super.openSubState(s);
			}
			// override public function add(obj:FlxBasic){
			// 	if(useNormalCallbacks){
			// 		callInterp('add',[obj]);
			// 		if(cancelCurrentFunction) return obj;
			// 	}
			// 	return add(obj);
			// }
			// override public function remove(Object:FlxBasic, Splice:Bool = false){
			// 	if(useNormalCallbacks){
			// 		callInterp('remove',[Object,Splice]);
			// 		if(cancelCurrentFunction) return Object;
			// 	}
			// 	return remove(Object,Splice);
			// }
			override public function switchTo(s:FlxState){
				if(useNormalCallbacks){
					callInterp('switchTo',[s]);
					if(cancelCurrentFunction) return false;
				}
				return super.switchTo(s);
			}

// 	/* End of base functions */
}