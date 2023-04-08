package;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.system.System;
import openfl.text.TextFormat;
import flixel.FlxG;
import flixel.system.debug.watch.EditableTextField;
import flixel.input.keyboard.FlxKey;


import hscript.Expr;
import hscript.Interp;
import hscript.InterpEx;
import hscript.ParserEx;

using StringTools;


// Recreation of openfl.display.fps, with memory being listed
class Overlay extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;
	static public var instance:Overlay = null;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
	public static var debugVar:String = "";

	public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFFFF)
	{
		super();
		instance = this;

		this.x = x;
		this.y = y;
		width = 1280;
		height = 720;
		// alpha = 0;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			__enterFrame(e);
		});
		#end
	}
	var memPeak:Float = 0;
	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		if(!visible) return;
		currentTime += flixel.FlxG.elapsed;
		times.push(currentTime);

		while (times[0] < currentTime - 1)
		{
			times.shift();
		}


		scaleX = lime.app.Application.current.window.width / 1280;
		scaleY = lime.app.Application.current.window.height / 720;
		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) * 0.5) ;

			var mem:Float = Math.round((
			#if cpp
			cpp.NativeGc.memInfo(0)
			#else
			System.totalMemory
			#end
			/ 1024) / 1000);
			if (mem > memPeak)
				memPeak = mem;
			text = "" + currentFPS + " FPS/" + deltaTime + 
			" MS\nMemory Usage/Peak: " + mem + "MB/" + memPeak + "MB"
			#if cpp
			+"\nMemory Reserved/Current: " + Math.round((cpp.NativeGc.memInfo(3) / 1024) / 1000) + "MB/" + Math.round((cpp.NativeGc.memInfo(2) / 1024) / 1000) + "MB" 
			#end
			+ debugVar;
		// }

		cacheCount = currentCount;
	}
}
// Clone of Overlay but to show a console sort of thing instead
class Console extends TextField
{
	var muteKeys:Array<FlxKey>;
	var volumeUpKeys:Array<FlxKey>;
	var volumeDownKeys:Array<FlxKey>;
	public static var instance:Console = new Console();
	public var commandBox:ConsoleInput; 
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
	public static var debugVar:String = "";
	var requestUpdate = false;
	public static var showConsole = false;
	var isShowingConsole = true;
	var wasMouseDisabled = false;

	public function new(x:Float = 20, y:Float = 20, color:Int = 0xFFFFFFFF)
	{
		super();
		instance = this;
		haxe.Log.trace = function(v, ?infos) {
			var str = haxe.Log.formatOutput(v,infos);
			#if js
			if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
				(untyped console).log(str);
			#elseif lua
			untyped __define_feature__("use._hx_print", _hx_print(str));
			#elseif sys
			Sys.println(str);
			#end
			if(Console.instance != null)Console.instance.log(str);
		}


		this.x = x;
		this.y = y;
		width = 1240;
		height = 640;
		background = true;
		backgroundColor = 0xff100011;
		// alpha = 0;

		selectable = false;
		mouseEnabled = mouseWheelEnabled = false;
		text = "Start of log";
		alpha = 0;
		commandBox = new ConsoleInput();
		commandBox.defFormat = commandBox.defaultTextFormat = defaultTextFormat = new TextFormat("_sans", 18, color);
		commandBox._parent = this;

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			__enterFrame(e);
		});
		#end
	}
	var lineCount:Int = 0;
	var lines:Array<String> = [];

	@:keep inline public static function error(str:String) return Console.print('Error: ${str}');
	@:keep inline public static function print(str:String) return instance.log(str);
	public function log(str:String){
		if(FlxG.save.data != null && !FlxG.save.data.animDebug){return;}
		// text += "\n-" + lineCount + ": " + str;
		lineCount++;
		lines.push('$lineCount ~ $str');
		while(lines.length > 500){
			lines.shift();
		}
		requestUpdate = true;

	}
	var firstOpen:Bool = true;

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		if(FlxG.keys == null || FlxG.save.data == null || !FlxG.save.data.animDebug) return;
		if(showConsole && requestUpdate){
			text = lines.join("\n");
			requestUpdate = false;
			scrollV = 1000;
		}
		if(FlxG.keys.pressed.SHIFT && FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F10){
			lines = [];
			trace("Cleared log");
		}else if(FlxG.keys != null && FlxG.keys.justPressed.F10 && FlxG.save.data != null){
			showConsole = !showConsole;
		}
		if(isShowingConsole != showConsole){
			updateConsoleVisibility();
		}
		

	}
	function updateConsoleVisibility(){
		isShowingConsole = showConsole;
		commandBox.alpha = alpha = (if(showConsole) 1 else 0);
		if(showConsole){
			wasMouseDisabled = FlxG.mouse.visible;
			FlxG.mouse.visible = true;
			// FlxG.mouse.enabled = false;
			requestUpdate = true;
			// commandBox.scaleX = scaleX = lime.app.Application.current.window.width / 1280;
			// commandBox.scaleY = scaleY = lime.app.Application.current.window.height / 720;
			var _SY = (lime.app.Application.current.window.height / 720);
			var _SX = (lime.app.Application.current.window.width / 1280);
			width = 1240 * _SY;
			height = 640 * _SX;
			commandBox.y = y + height + 2;
			commandBox.x = x;
			commandBox.height = 30 * _SY;
			commandBox.width =width;
			if(firstOpen){
				firstOpen = false;
				print('Super Engine ${MainMenuState.ver} - Debug console. Type help for commands.');
			}


		}else{
			FlxG.mouse.visible = wasMouseDisabled;
		}
		SetVolumeControls(showConsole);
		commandBox.mouseEnabled =commandBox.mouseWheelEnabled = commandBox.selectable = mouseEnabled = mouseWheelEnabled = selectable = showConsole;

	}
	function SetVolumeControls(enabled:Bool)
	{
		if(FlxG.sound == null) return;
		if(muteKeys == null){
			muteKeys = FlxG.sound.muteKeys;
			volumeUpKeys = FlxG.sound.volumeUpKeys;
			volumeDownKeys = FlxG.sound.volumeDownKeys;
		}
		if (enabled)
		{
			FlxG.sound.muteKeys = muteKeys;
			FlxG.sound.volumeUpKeys = volumeUpKeys;
			FlxG.sound.volumeDownKeys = volumeDownKeys;
		}
		else
		{
			FlxG.sound.muteKeys = null;
			FlxG.sound.volumeUpKeys = null;
			FlxG.sound.volumeDownKeys = null;
		}
	}
}

class ConsoleInput extends TextField{
	public var _parent:Console = null;
	var interp:Interp;
	var parser:hscript.Parser;
	var hsbrtools:HSBrTools = new HSBrTools('',"CONSOLE");
	public var commandHistory:Array<String> = [];
	public var actualText:String = "";
	public inline static var CARETCHAR:String = "|";
	public var caretFormat:TextFormat = new TextFormat();
	public var defFormat:TextFormat = new TextFormat();


	public function new(x:Float = 20, y:Float = 20, color:Int = 0xFFFFFFFF)
	{
		super();
		type="INPUT";
		selectable = false;
		mouseEnabled = mouseWheelEnabled = false;
		alpha = 0;
		background = true;
		backgroundColor = 0xff110011;
		parser = HscriptUtils.createSimpleParser();
		interp = HscriptUtils.createSimpleInterp();
		interp.variables.set("BRtools", hsbrtools);
		interp.variables.set("t",Console.instance.log);
		interp.variables.set("log",Console.instance.log);

		caretFormat.color = 0xFFFFAAFF;
		updateShownText();
		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			__enterFrame(e);
		});
		#end
	}

	public function runHscript(?songScript:String = ""){

		try{
			@:privateAccess
			parser.line = 0;
			interp.variables.set("state",cast (FlxG.state)); 
			interp.variables.set("game",cast (FlxG.state));
			interp.execute(parser.parseString(songScript,'CONSOLE'));
		}catch(e){
			var _line = '${parser.line}';
			try{
				var _split = songScript.split('\n');
				_line = '${parser.line};"${_split[parser.line - 1]}"';
			}catch(e){_line = '${parser.line}';}
			trace('Error parsing hscript\nLine:${_line}\n ${e.message}');
		}
		return interp;
	}
	var CURRENTCMDHISTORY = -1;
	var keyList:Map<FlxKey,String> = [ // I hate my life
		A => "a",
		B => "b",
		C => "c",
		D => "d",
		E => "e",
		F => "f",
		G => "g",
		H => "h",
		I => "i",
		J => "j",
		K => "k",
		L => "l",
		M => "m",
		N => "n",
		O => "o",
		P => "p",
		Q => "q",
		R => "r",
		S => "s",
		T => "t",
		U => "u",
		V => "v",
		W => "w",
		X => "x",
		Y => "y",
		Z => "z",
		SPACE => " ",
		ZERO => "0",
		ONE => "1",
		TWO => "2",
		THREE => "3",
		FOUR => "4",
		FIVE => "5",
		SIX => "6",
		SEVEN => "7",
		EIGHT => "8",
		NINE => "9",
		NUMPADZERO=> "0",
		NUMPADONE=> "1",
		NUMPADTWO=> "2",
		NUMPADTHREE=> "3",
		NUMPADFOUR=> "4",
		NUMPADFIVE=> "5",
		NUMPADSIX=> "6",
		NUMPADSEVEN=> "7",
		NUMPADEIGHT=> "8",
		NUMPADNINE=> "9",
		NUMPADMINUS => "-",
		NUMPADPLUS => "+",
		NUMPADPERIOD => ".",
		NUMPADMULTIPLY => "*",
		LBRACKET => "[",
		RBRACKET => "]",
		BACKSLASH => "\\",
		SEMICOLON => ";",
		QUOTE => "'",
		COMMA => ",",
		PERIOD => ".",
		SLASH => "/",
		MINUS => "-",
		PLUS => "=", 
	];
	var keyListUpper:Map<FlxKey,String> = [ // I hate my life*@ (get it, because it's shif- I'll see myself out)
		ZERO => ")",
		ONE => "!",
		TWO => "@",
		THREE => "#",
		FOUR => "$",
		FIVE => "%",
		SIX => "^",
		SEVEN => "&",
		EIGHT => "*",
		NINE => "(",
		LBRACKET => "{",
		RBRACKET => "}",
		BACKSLASH => "|",
		SEMICOLON => ":",
		QUOTE => "\"",
		COMMA => "<",
		PERIOD => ">",
		SLASH => "?",
		MINUS => "_",
		PLUS => "+",
	];
	var caretPos:Int = 0;
	inline function updateShownText(){
		if(caretPos > actualText.length) caretPos = actualText.length;
		if(caretPos < 0) caretPos = 0;

		text = actualText.substring(0,caretPos) + CARETCHAR + actualText.substring(caretPos);
		setTextFormat(defFormat,0,text.length);
		setTextFormat(caretFormat,caretPos,caretPos+1);
	}
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		if(FlxG.keys == null || alpha <= 0) return;


		for(key => char in keyList){
			@:privateAccess
			if(Reflect.getProperty(FlxG.keys.justPressed,key)){
				if(FlxG.keys.pressed.SHIFT){
					if(keyListUpper[key] != null){
						char = keyListUpper[key];
					}else{
						char = char.toUpperCase();
					}
				}
				actualText = actualText.substring(0,caretPos) + char + actualText.substring(caretPos);
				caretPos++;
				updateShownText();
			}
		}

		if(FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.BACKSPACE){
			actualText = actualText.substring(0,caretPos - 1) + actualText.substring(caretPos);
			caretPos--;
			updateShownText();
		}
		if(FlxG.keys.pressed.SHIFT){
			if(FlxG.keys.justPressed.UP){
				if(CURRENTCMDHISTORY == 0 && actualText != commandHistory[commandHistory.length -1]){
					commandHistory.unshift(actualText);
					CURRENTCMDHISTORY++;
				}
				if(CURRENTCMDHISTORY < commandHistory.length){
					actualText = commandHistory[CURRENTCMDHISTORY++];
				}
				updateShownText();
			}else if(FlxG.keys.justPressed.DOWN){
				if(CURRENTCMDHISTORY > 0){
					actualText = commandHistory[CURRENTCMDHISTORY--];
				}
				if(CURRENTCMDHISTORY == 0){
					CURRENTCMDHISTORY--;
					actualText = "";
				}
				updateShownText();
			}
			if(FlxG.keys.pressed.LEFT){
				caretPos--;
				updateShownText();
			}
			if(FlxG.keys.pressed.RIGHT){
				caretPos++;
				updateShownText();
			}
		}else{
			

			if(FlxG.keys.justPressed.BACKSPACE){
				actualText = actualText.substring(0,caretPos - 1) + actualText.substring(caretPos);
				caretPos--;
				updateShownText();
			}
			if(FlxG.keys.justPressed.LEFT){
				caretPos--;
				updateShownText();
			}
			if(FlxG.keys.justPressed.RIGHT){
				caretPos++;
				updateShownText();
			}
			
			if(FlxG.keys.justPressed.ENTER){
				if(actualText != ""){
					Console.print('> ${actualText}');
					runCommand(actualText);
					commandHistory.unshift(actualText);
					actualText= "";
					updateShownText();
				}
			}
		}
	}
	var cmdList:Array<Array<String>> = [
		["help",'Prints this message'],

		['-- Utilities --'],
		["mainmenu",'Return to the main menu'],
		["reload",'Reloads current state'],
		["switchstate",'Switch to a state, Case/path sensitive!'],

		['-- Scripting --'],
		["hs (code)",'Run hscript code'],
		["hst (code)",'Run hscript code, encased in a trace'],
		["getvalue (path)",'Returns a value from an object path'],
		["setvalue (path) (value)",'Sets a value from an object path'],
	];
	function runCommand(text:String):Dynamic{
		if(text.indexOf('>>') > 0){
			var redir:Array<String> = text.split(' >> ');
			var ret = runCommand(redir[0]);
			text = redir[1] + ' ${ret}';
		}
		var args:Array<String> = text.split(' ');
		switch(args[0].toLowerCase()){
			case 'hs': 
				if(!QuickOptionsSubState.getSetting("Song hscripts")){Console.print('Error: Scripts are currently disabled!');return null;}
				return runHscript(text.substring(3));
			case 'hst' :
				if(!QuickOptionsSubState.getSetting("Song hscripts")){Console.print('Error: Scripts are currently disabled!');return null;}
				return runHscript("trace(" + text.substring(3) + ");");
			case 'reload':
				Console.showConsole = false;
				FlxG.resetState();
			case 'mainmenu':
				Console.showConsole = false;
				MainMenuState.handleError("");
			case 'getvalue':
				try{
					var ret = '${ConsoleUtils.getValueFromPath(null,args[1])}';
					Console.print(ret);
					return ret;
				}catch(e){
					Console.error('Unable to grab value from ${args[1]}: ${e.message}');
					return null;
				}
			case 'setvalue':
				if(!QuickOptionsSubState.getSetting("Song hscripts")){Console.print('Error: Scripts are currently disabled!');return null;}
				var value:String = text.substring(text.indexOf(' ',10) + 1);
				var path:String = args[1];
				try{
					ConsoleUtils.setValueFromPath(path,value);
					Console.print('Set value ${path} to ${value}');
				}catch(e){
					Console.error('Unable to set value of ${args[1]} to ${value}: ${e.message}');
				}
			case 'switchstate':
				if(args[1] == null) {Console.error('No state specified!');return null;}
				try{
					var state:Class<flixel.FlxState> = cast Type.resolveClass(args[1]);
					if(state == null) {Console.error('Invalid state specified!');return null;}
					// if(!(state is )) return Console.print('${Type.getClassName(state)} is not a valid state!');
					Console.print('Attempting to switch to ${Type.getClassName(state)}');
					FlxG.switchState(Type.createInstance(state,[]));
				}catch(e){Console.error('Unable to switch states: ${e.message}');return null;}
				Console.showConsole = false;
			case 'help':
				var ret = 'Command list:';
				for(_ => v in cmdList){
					if(v[1] == null)
						ret += '\n${v[0]}';
					else
						ret += '\n`${v[0]}` - ${v[1]}';
				}
				Console.print(ret);
				return null;
				              // \n"hs (CODE)" - Run hscript code\n"hst (CODE)" - Run HScript Code encased in a trace\n"reload" - Reset current state\n"mainmenu" - Go to the main menu');
			default:
				Console.error('Command "${args[0]}" not found, run help for a list of commands');
		}
		return null;
	}
}

class ConsoleUtils{
	// function getIndexType(index:String):Dynamic{
	// 	index = index.substring(2,-1);
	// 	if(index )
	// }
	public static function getValueFromPath(object:Dynamic,path:String = "",returnErrors:Bool = true):Dynamic{
		var splitPath:Array<String> = path.split('.');

		if(path == "" || splitPath[0] == null){
			throw 'Path is empty!';
			return null;
		}
		if(object == null){
			var obj:String = splitPath.shift();
			if(obj == "state"){
				object = cast FlxG.state;
			}else{

				object = Reflect.field((cast FlxG.state),obj);
				if(object == null) object = Type.resolveClass(obj);
				if(object == null){
					throw 'Unable to find top-level object ${obj} from path ${path}';
					return null;
				}
			}
		}
		var currentPath:String = "";
		while(splitPath.length > 0){
			currentPath = splitPath.shift();
			object = Reflect.field(object,currentPath);
			if(object == null){
				throw 'Unable to find object from path ${path}(On ${currentPath})';
				return null;
			}
		}
		if(object is String){
			return '[[$object]]';
		}
		return object;
	}
	public static function setValueFromPath(path:String = "",value:Dynamic){
		var splitPath:Array<String> = path.split('.');
		var obj:Dynamic = null;
		if(splitPath[0] == "state"){
			splitPath.shift();
			obj = cast FlxG.state;
		}
		if(splitPath.length > 1) obj = getValueFromPath(obj,path.substring(0,path.lastIndexOf('.')),false);
		if(obj is String) return obj;
		if(obj == null) throw('Object "${path}" is null!');
		var type = 0;
		if(value is String){
			if(value.substring(0,1) == "[[" || value.substring(0,1) == "]]"){
				value = value.substring(3,-2);
			}else if(value.substring(0,1) == "'" || value.substring(0,1) == '"'){
				value = value.substring(2,-1);
			}else if(!Math.isNaN(Std.parseFloat(value))){
				value = Std.parseFloat(value);
				type = 1;
			}else if(!Math.isNaN(Std.parseInt(value))){
				value = Std.parseInt(value);
				type = 1;
			}
		}
		var lastPath = splitPath.pop();
		var field = Reflect.field(obj,lastPath);
		if(field != null){
			if((field is Int || field is Float) && type != 1) {
				throw('Field of type ${Type.typeof(field)} is incompatible with ${Type.typeof(value)}');
				return;
			}
			if(field is Int) value = Std.int(value);
			// if(field is String) ;
		}

		Reflect.setField(obj,lastPath,value);
	}
}
