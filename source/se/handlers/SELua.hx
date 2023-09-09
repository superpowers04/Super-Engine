package se.handlers;
#if linc_luajit
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import cpp.Pointer;
import flixel.FlxG;
import Overlay;

using StringTools;


class SELua{
	public var state:State;
	public var code:String = "";
	public var cache:Map<String,Dynamic> = [];
	public var variables:SELuaVaris;
	public var helpers:SELuaHelperMethods;
	public var peCompat:PsychLuaCompat;
	public var BRTools:HSBrTools;
	public static var currentInstance:SELua;
	public var psychCompatMode:Bool = false; // Disables SE function calls and uses Psych ones instead.


	public function new(?str:String = "",?doExec:Bool = true){
		code = str;
		state = LuaL.newstate();
		LuaL.openlibs(state);
		Lua.init_callbacks(state);
		variables = new SELuaVaris(this);
		helpers = new SELuaHelperMethods(this);
		peCompat = new PsychLuaCompat(this);
		if(!doExec) return;
		exec();
		// if(variables.getBool('psychCompat')){
		psychCompatMode = true;
			// peCompat.adaptCallbacks();
		// }
	}
	var uninit:Bool = false;
	public function exec(?code:String = ""){
		SELua.currentInstance = this;
		
		var status:Dynamic = "Unable to init lua!";

		if(!uninit){
			variables.set('callLatestCode',"");
			// variables.set('latestCode',"");
			variables.set('INTERNALSTATUS',0);
			status = LuaL.dostring(state, '
			callLatestCode = function(latestCode)
				succ,err = pcall(function() load(latestCode)() end)
				if(not succ) then 
					INTERNALSTATUS = tostring(err)
				end
			end');

		}
		if(code == "") code = this.code;
		Lua.getglobal(state, "callLatestCode");
		Lua.pushstring(state, code);
		status = Lua.pcall(state, 1, 0, 0);
		checkStatus(status);
	}

	function checkStatus(status:Dynamic){
		if(status == 0) return;
		if(!(status is Int)){
			trace(status);
			throw status;
		}else{
			status = fromLuaError(status);
			trace(status);
			throw(status);
		}
	}


	/* I didn't steal these from psych, naaaaahhh*/


	function typeToString(type:Int):String {
		switch(type) {
			case Lua.LUA_TBOOLEAN: return "boolean";
			case Lua.LUA_TNUMBER: return "number";
			case Lua.LUA_TSTRING: return "string";
			case Lua.LUA_TTABLE: return "table";
			case Lua.LUA_TFUNCTION: return "function";
		}
		if (type <= Lua.LUA_TNIL) return "nil";
		return "unknown";
	}

	public function set(variable:String, data:Dynamic,?map:Bool = false) {
		return variables.set(variable,data,map);
	}

	public function call(func:String,args:Array<Dynamic>) {
		return variables.call(func,args);
	}
	public function get(variable:String):Dynamic {
		return variables.get(variable);
	}
	public function getBool(variable:String):Bool {
		return variables.getBool(variable);
	}
	public function returnStack(limit:Int = 9){
		var _arr:Array<Dynamic> = [];
		var param:Dynamic = null;
		var i = 0;
		param = Lua.tostring(state,i--);
		while(param != null && i > -limit){
			_arr.push(Lua.tostring(state, i));
			param = Lua.tostring(state,i--);
		}
		i = 0;
		param = Lua.tostring(state,i++);
		while(param != null  && i < limit){
			_arr.push(Lua.tostring(state, i));
			param = Lua.tostring(state,i++);
		}
		return _arr;
	}

	public function fromLuaError(Stat:Dynamic){
		var v:String = 'Status code:$Stat';
		try{

			if(Stat == "" || Stat == null || Stat is Int){
				var _v = "Stack:\n";
				var _arr = returnStack(); 
				_v+='${_arr}\n';
				Lua.pop(state, 1);
					switch(Stat) {
						case Lua.LUA_YIELD: v+= '\nYIELD';
						case Lua.LUA_ERRSYNTAX: v += "\nSyntax Error";
						case Lua.LUA_ERRRUN: v += '\nRUNTIME ERROR:${_arr[0]}';
						case Lua.LUA_ERRMEM: v += "\nMemory Allocation Error";
						case Lua.LUA_ERRERR: v += "\nCritical Error";
					}
					
				if (_v != null && _v != "") {v += "\n" + _v.trim();}
			}else{
				v += '\n' + Std.string(Stat);
			}
			stop();
		}catch(e){
			v += 'Unable to grab error! ${e.message}';
		}
		return v;
	}

	public function stop() {
		if(state == null) return;

		Lua.close(state);
		state = null;
	}

	public function emptyStack(){
		var _max = Lua.gettop(state);
		while(_max > 0) {
			Lua.pop(state, -1);
			_max--;
		}
	}
}

class SELuaVaris{

	var parent:SELua;
	public var strToPointer:haxe.ds.WeakMap<String,Dynamic> = new haxe.ds.WeakMap<String,Dynamic>();
	public var pointerToStr:haxe.ds.WeakMap<Dynamic,String> = new haxe.ds.WeakMap<Dynamic,String>();
	inline public static var pointerID:String = "Pointer to ";
	public function new(selua:SELua){
		parent = selua;
	}
	public static function objectToMap(obj:Dynamic):Map<String,Dynamic> {
		var map = new Map<String,Dynamic>();
		for(field in Reflect.fields(obj)){
			map.set(field,Reflect.getProperty(obj,field));
		}
		try{
			for(field in Type.getInstanceFields(Type.getClass(obj))){
				map.set(field,Reflect.getProperty(obj,field));
			}
		}catch(e){}
		return map;
	}
	inline function setGlobal(vari){
		if(vari != "FUNCTIONVAR") Lua.setglobal(parent.state,vari);
	}
	public function setMultiple(variables:Array<String>, data:Dynamic,?map:Bool = false){
		for(vari in variables){set(vari,data,map);}
	}
	public function set(variable:String, data:Dynamic,?map:Bool = false):Bool {
		if(parent.state == null) return false;
		SELua.currentInstance = parent;
		var _dataTypeOf = Type.typeof(data);
		if(!map && variable != "FUNCTIONVAR" && Reflect.isFunction(data)){
			Lua_helper.add_callback(parent.state,variable,data);
			return true;
		}
		if(Convert.toLua(parent.state, data) && variable != "FUNCTIONVAR"){
			setGlobal(variable);
			return true;
		}
		if(map){
			if(Convert.toLua(parent.state, objectToMap(data)) && variable != "FUNCTIONVAR"){
				setGlobal(variable);
				return true;
			}

			return false;
		}
		return false;
		// var ptr = objectToPtr(data,true);
		// if(ptr != null && Convert.toLua(parent.state, ptr) && variable != "FUNCTIONVAR"){
		// 	setGlobal(variable);
		// 	return true;
		// }

	}

	function typeToString(type:Int):String {
		switch(type) {
			case Lua.LUA_TBOOLEAN: return "boolean";
			case Lua.LUA_TNUMBER: return "number";
			case Lua.LUA_TSTRING: return "string";
			case Lua.LUA_TTABLE: return "table";
			case Lua.LUA_TFUNCTION: return "function";
		}
		if (type <= Lua.LUA_TNIL) return "nil";
		return "unknown";
	}


	public function call(func:String, args:Array<Dynamic>) {
		if(parent.state == null) return;
		var psychFunc:PsychFunction = null;
		SELua.currentInstance = parent;
		if(parent.psychCompatMode && (PsychLuaCompat.funcs[func] != null)){
			psychFunc = PsychLuaCompat.funcs[func];
			func = psychFunc.name;
		}
		Lua.getglobal(parent.state, func);
		var type:Int = Lua.type(parent.state, -1);

		if (type != Lua.LUA_TFUNCTION) {
			parent.emptyStack();
			if (type <= Lua.LUA_TNIL) return;
			throw("" + func + ": attempt to call a " + typeToString(type) + " value");
			return;
		}
		if(psychFunc != null){
			if(Std.isOfType(args[0],flixel.FlxState)) args.shift();
			if(psychFunc.convertArgs != null) args = psychFunc.convertArgs(args);
		}
		var count = 0;
		for (arg in args) if(Convert.toLua(parent.state, arg)) count++; 
		SELua.currentInstance = this.parent;
		var status:Int = Lua.pcall(parent.state, count, 0, 0);


		if (status != Lua.LUA_OK) throw parent.fromLuaError(status);
		parent.emptyStack();
	}
	public function getRaw(variable:String):Dynamic {
		if(parent.state == null) return null;
		SELua.currentInstance = parent;
		var result:String = null;
		Lua.getglobal(parent.state, variable);
		var returned = Convert.fromLua(parent.state, -1);
		if(returned != null){
			Lua.pop(parent.state, 1);
		}

		return returned;
	}
	public function get(variable:String):Dynamic {
		if(parent.state == null) return null;
		SELua.currentInstance = parent;
		var result:String = null;
		Lua.getglobal(parent.state, variable);
		var returned = Convert.fromLua(parent.state, -1);
		if(returned is String){
			var retStr:String = cast (returned,String);
			if(retStr.substring(0,pointerID.length) == pointerID){
				var ptr = strToPointer.get(retStr.substring(pointerID.length));
				if(ptr == null) return returned;
				returned = ptr.ref;
			}
		}
		if(returned != null){
			Lua.pop(parent.state, 1);
		}

		return returned;
	}
	public function getBool(variable:String):Bool {
		if(parent.state == null) return false;
		var result:String = null;
		Lua.getglobal(parent.state, variable);
		result = Std.string(Convert.fromLua(parent.state, -1));
		if(result != null){
			Lua.pop(parent.state, 1);
		}

		return (result == 'true');
	}
}

class SELuaHelperMethods{
	var parent:SELua;
	public function new(par:SELua){
		parent = par;
		parent.set('trace',Reflect.makeVarArgs(function(e:Array<Dynamic>) trace('lua: ${e.join(' ')}')));
	}
	#if false
	public function getField(ID:String,vari:String):Dynamic{
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		return Reflect.getProperty(obj,vari);
	}
	public function runMethod(ID:String,vari:String,args:Array<Dynamic>):Dynamic{
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		if(args == null) args = [];
		var func = Reflect.field(obj,vari);
		if(func == null){
			throw('$vari is not a valid method from $ID');
			return null;
		}
		return Reflect.callMethod(obj,func,args);
	}
	public function printObject(ID:String){
		var obj = parent.variables.ptrToObject(ID);
		trace(obj);
	}
	public function getFields(ID:String,vari:String,list:Array<Dynamic>):Array<Dynamic>{
		if(list == null){
			return [];
		}
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		for(index => name in list){
			list[index] = Reflect.getProperty(obj,cast name);
		}
		trace(list);
		return list;
	}
	public function setField(ID:String,vari:String,value:Dynamic):Void{
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return;
		Reflect.setProperty(obj,vari,value);
	}
	public function toLuaTbl(ID:String):Map<String,Dynamic>{
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		return SELuaVaris.objectToMap(obj);
	}
	public function getClass(Name:String):Dynamic{
		var ass = Type.resolveClass(Name);
		if(ass == null) return null;
		return parent.variables.objectToPtr(ass,true);
	}
	public function getType(Name:String):Dynamic{
		var ass = Type.resolveClass(Name);
		if(ass == null) return null;
		return parent.variables.objectToPtr(ass,true);
	}
	public function getFieldsTbl(ID:String,vari:String,list:Array<String>):Map<String,Dynamic>{
		if(list == null){
			return [];
		}
		var obj = parent.variables.ptrToObject(ID);
		if(obj == null) return null;
		var map = new Map<String,Dynamic>();
		for(index => name in list){
			map[name] = Reflect.getProperty(obj,name);
		}
		return map;
	}
	#end
}

@:structInit @:publicFields class PsychFunction{
	var name:String;
	var convertArgs:Array<Dynamic>->Array<Dynamic> = null;
}

class PsychLuaCompat{
	var parent:SELua;
	public static var funcs:Map<String,PsychFunction> = [
		'initScript' => {name:"onCreate"},
		'startCountdownFirst' => {name:"onCreatePost"},
		'startCountdown' => {name:"onStartCountdown"},
		'miss' => {name:"noteMissPress"},
		'noteMiss' => {name:"noteMiss",convertArgs:function(args){
			var note = args[0];
			return [PlayState.instance.notes.members.indexOf(note),note.noteData,note.type,note.isSustainNote];
		}},
		'noteCreate' => {name:"onNoteCreate",convertArgs:function(args){
			var note = args[0];
			return [PlayState.instance.notes.members.indexOf(note),args[1],note.type,note.isSustainNote];
		}},
		'noteHit' => {name:"goodNoteHit",convertArgs:function(args){
			var note = args[0];
			return [PlayState.instance.notes.members.indexOf(note),args[1],note.type,note.isSustainNote];
		}},
		'noteHitDad' => {name:"opponentNoteHit",convertArgs:function(args){
			var note = args[0];
			return [PlayState.instance.notes.members.indexOf(note),args[1],note.type,note.isSustainNote];
		}},
		'eventNoteHit' => {name:"onEvent",convertArgs:function(args){
			var note = args[0];
			return [note.noteType,note.rawNote[3],note.rawNote[4]];
		}},
		'keyPress' => {name:"onKeyPress"},
		'keyRelease' => {name:"onKeyRelease"},
		'stepHit' => {name:"onStepHit"},
		'beatHit' => {name:"onBeatHit"},
		'startSong' => {name:"onSongStart"},
		'playAnim' => {name:"onPlayAnim"},
	];
	public var objects:Map<String,Dynamic> = [];
	public static function luaCompat(vari:Dynamic):Dynamic{
		if((vari is String) || (vari is Int) || (vari is Float) || (vari is Array)  
			|| (vari is haxe.ds.StringMap) || (vari is haxe.ds.IntMap) || (vari is haxe.ds.EnumValueMap) || (vari is haxe.ds.ObjectMap)){
			return vari;
		}
		return null;
	}
	// public function adaptCallbacks(){
	// 	parent.exec("
	// 	function psychCall(func) return function(_,...) func(...) end
	// 	if(onCreate) then initScript = psychCall(onCreate) end
	// 	if(onCreatePost) then startCountdownFirst = psychCall(onCreatePost) end
	// 	if(onUpdate) then update = psychCall(onUpdate) end
	// 	if(onUpdatePost) then updateAfter = psychCall(onUpdatePost) end
	// 	if(onEvent) then eventNoteHit = function(_,note) 
	// 		local note = getProperty(note .. '.rawNote');
	// 		onEvent(note[2],note[3],note[4])
	// 	end
	// 	");
	// }
	public function new(par:SELua){
		parent = par;
		parent.set('psychCompat',false);
		parent.set('callObjectFunction',function(path:String,func:String,Args:Array<Dynamic>){
			var obj = getValueFromPath(null,path);
			if(obj == null) {throw '$path is not a valid object!';return;}
			Reflect.callMethod(obj,Reflect.field(obj,func),Args);
		});



		parent.set('loadFlxSprite',function(tag:String,path:String,x:Float=0,y:Float=0){
			objects[tag] = parent.BRTools.loadFlxSprite(x,y,path);
		});
		parent.set('addObject',function(tag:String,path:String,x:Float=0,y:Float=0){
			var obj = getValueFromPath(null,tag);
			if(obj == null) return;
			FlxG.state.add(obj);
		});
		parent.set('removeLuaSprite',function(tag:String,path:String,x:Float=0,y:Float=0){
			FlxG.state.remove(getValueFromPath(null,tag));
		});
		parent.set('add',function(tag:String,path:String,x:Float=0,y:Float=0){
			FlxG.state.add(getValueFromPath(null,tag));
		});
		parent.set('remove',function(tag:String,path:String,x:Float=0,y:Float=0){
			FlxG.state.remove(getValueFromPath(null,tag));
		});
		parent.set('playAnim',function(tag:String,name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0){
			var obj = getValueFromPath(null,tag);
			if(obj == null || obj.animation == null || obj.animation.get(name)) return;
			if(obj.playAnim != null){
				obj.playAnim(name,forced,reverse,startFrame);
			}else{
				obj.animation.play(name, forced, reverse, startFrame);
			}
		});
		// parent.set('addAnimation',function(tag:String,name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0){
		// 	var obj = getValueFromPath(tag);
		// 	if(obj == null || obj.animation == null) return;

		// });


		parent.set('runMethod',runMethod);
		parent.set('getProperty',getProperty);
		parent.set('setProperty',setProperty);
		parent.set('getPropertyFromGroup',getPropertyFromGroup);
		parent.set('setPropertyFromGroup',setPropertyFromGroup);
		parent.set('getPropertyFromClass',getPropertyFromClass);
		parent.set('setPropertyFromClass',setPropertyFromClass);
		parent.set('debugPrint',Reflect.makeVarArgs(function(e:Array<Dynamic>) trace('lua: ${e.join(' ')}')));
		parent.set('getGlobalValue',getGlobalValue);
		// parent.set('setGlobalValue',setGlobalValue);
		LuaL.dostring(parent.state,/*lua code lmao*/se.utilities.SEMacros.PsychLuaCompatScript); // I love being able to do this with lua kekw

	}
	public function getValueFromPath(object:Dynamic,path:String):Dynamic{
		if(object == null && getGlobalValue(path) != null){
			return getGlobalValue(path);
		}
		var splitPath:Array<String> = path.split('.');

		if(path == "" || splitPath[0] == null){
			throw 'Path is empty!';
			return null;
		}
		if(object == null){
			var obj:String = splitPath.shift();
			if(obj.indexOf('[') > -1){
				var _obj = obj.split('[');
				obj = _obj[0];
				splitPath.unshift('this'+ _obj[1].substr(0,-1));
			}

			object = ConsoleUtils.quickObject(obj);
			// if(object == null) object = parent.variables.ptrToObject(obj);
			if(object == null) object = objects[obj];
			if(object == null) object = Reflect.field(FlxG.state,obj);
			if(object == null) object = Type.resolveClass(obj);
			if(object == null) object = Reflect.field(PlayState,obj);
			if(object == null){
				throw 'Unable to find top-level object ${obj} from path ${path}';
				return null;
			}
			
		}
		if(splitPath.length > 0){

			var currentPath:String = "";
			while(splitPath.length > 0){
				currentPath = splitPath.shift();
				if(currentPath.endsWith(']')){
					var index = currentPath.substring(currentPath.indexOf('[') + 1,-1);
					trace(index);
					object = Reflect.field(object,currentPath.substring(0,currentPath.indexOf('[')));
					if (object is Array) object = object[Std.parseInt(index)];
					else if(object.get != null) object = object.get(index);
				}else{
					object = Reflect.field(object,currentPath);
				}
				
				if(object == null){
					return null;
				}
			}
		}
		return object;
	}
	public function setValueFromPath(path:String = "",value:Dynamic,obj:Dynamic = null):Void{
		var splitPath:Array<String> = path.split('.');
		if(splitPath[0] == "state"){
			splitPath.shift();
			obj = FlxG.state;
		}
		var lastPath = splitPath.pop();
		if(splitPath.length > 0) obj = getValueFromPath(obj,splitPath.join('.')); else obj = FlxG.state;
		if(obj is String || obj is Int || obj is Float) throw('Object "${path}" is not an object!'); return;
		if(obj == null) throw('Object "${path}" is null!'); return;
		var type = 0;
		/*if(value is String){
			if(!Math.isNaN(Std.parseFloat(value))){
				value = Std.parseFloat(value);
				type = 1;
			}else if(!Math.isNaN(Std.parseInt(value))){
				value = Std.parseInt(value);
				type = 1;
			}
		}*/
		var field = Reflect.field(obj,lastPath);
		if(field != null){
			if((value is String) && value.substring(0,SELuaVaris.pointerID.length) == SELuaVaris.pointerID){
				var ptr = parent.variables.strToPointer.get(value.substring(SELuaVaris.pointerID.length));
				if(ptr != null) value = ptr.ref;
			}
			if((field is Int || field is Float) && type != 1) {
				throw('Field of type ${Type.typeof(field)} is incompatible with ${Type.typeof(value)}');
				return;
			}
			if(field is Int) value = Std.int(value);
			// if(field is String) ;
		}

		Reflect.setField(obj,lastPath,value);
	}
	public function getProperty(path:String):Dynamic{
		return luaCompat(getValueFromPath(null,path));
	}
	public function setProperty(path:String,value:Dynamic):Void{
		setValueFromPath(path,value);
	}
	public function runMethod(ID:String,vari:String,args:Array<Dynamic>):Dynamic{
		var obj = getValueFromPath(null,ID);
		if(obj == null) return null;
		if(args == null) args = [];
		var func = Reflect.field(obj,vari);
		if(func == null){
			throw('$vari is not a valid method from $ID');
			return null;
		}
		return Reflect.callMethod(obj,func,args);
	}
	public function getPropertyFromClass(classPath:String,path:String):Dynamic{
		var classObj:Class<Any> = Type.resolveClass(classPath);
		if(classObj == null) return null;
		return luaCompat(getValueFromPath(classObj,path));
	}
	public function setPropertyFromClass(classPath:String,path:String,value:Dynamic){
		var classObj:Class<Any> = Type.resolveClass(classPath);
		if(classObj == null) return;
		setValueFromPath(path,value,classObj);
	}
	public function getPropertyFromGroup(path:String,index:Int,path:String):Dynamic{
		var obj:Dynamic = getValueFromPath(null,path);
		if(obj == null || obj.members == null) return null;
		obj = obj.members.get(index);
		if(obj == null) return null;
		return luaCompat(getValueFromPath(obj,path));
	}
	public function setPropertyFromGroup(path:String,index:Int,path:String,value:Dynamic){
		var obj:Dynamic = getValueFromPath(null,path);
		if(obj == null || obj.members == null) return;
		obj = obj.members[index];
		if(obj == null) return;
		setValueFromPath(path,value,obj);
	}
	public static function getGlobalValue(vari:String):Dynamic{
		switch(vari){
			/*Music related*/
			case "curStep": return MusicBeatState.instance.curStep;
			case "curBeat": return MusicBeatState.instance.curBeat;
			case "curDecStep": return MusicBeatState.instance.curStepProgress;
			case "curDecBeat": return MusicBeatState.instance.curStepProgress * 0.25;
			case "curBPM" | "curBpm": return Conductor.bpm;
			case "bpm": return PlayState.SONG.bpm;
			case "songPosition": return Conductor.songPosition;
			case "crochet": return Conductor.crochet;
			case "stepCrochet": return Conductor.stepCrochet;
			case "songLength": return FlxG.sound.music.length;
			case "songName": return PlayState.SONG.song;
			case "scrollSpeed": return flixel.math.FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? PlayState.SONG.speed : FlxG.save.data.scrollSpeed, 2);
			case 'songPath': return onlinemod.OfflinePlayState.chartFile.substr(0,onlinemod.OfflinePlayState.chartFile.lastIndexOf('/'));

			/* Environment shit */
			case "curStage": return PlayState.curStage;
			case "cameraX": return FlxG.camera.scroll.x;
			case "cameraY": return FlxG.camera.scroll.y;
			case "screenWidth": return FlxG.width;
			case "screenHeight": return FlxG.height;
			



			/* Score shit */
			case 'score' | 'songScore' : return PlayState.songScore;
			case 'misses' | "comboBreaks" : return PlayState.misses;


			/* note related*/
			case 'unspawnNotesLength': return PlayState.instance.unspawnNotes.length;
			case 'notesLength': return PlayState.instance.notes.length;
		}
		return null;
	}
	public function setGlobalValue(path){
		return false;
	}
}

#else

class SELua{}
#end