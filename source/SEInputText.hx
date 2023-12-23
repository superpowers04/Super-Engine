package;
import flixel.addons.ui.FlxInputText;
#if false
import flash.events.KeyboardEvent;
import flixel.FlxG;

class SEInputText extends FlxInputText{
	public static inline var NO_FILTER:Int = 0;
	public static inline var ONLY_ALPHA:Int = 1;
	public static inline var ONLY_NUMERIC:Int = 2;
	public static inline var ONLY_ALPHANUMERIC:Int = 3;
	public static inline var CUSTOM_FILTER:Int = 4;

	public static inline var ALL_CASES:Int = 0;
	public static inline var UPPER_CASE:Int = 1;
	public static inline var LOWER_CASE:Int = 2;

	public static inline var BACKSPACE_ACTION:String = "backspace"; // press backspace
	public static inline var DELETE_ACTION:String = "delete"; // press delete
	public static inline var ENTER_ACTION:String = "enter"; // press enter
	public static inline var INPUT_ACTION:String = "input"; // manually edit

	
	override public function update(elapsed:Float):Void {
		var hadFocus:Bool = hasFocus;
		super.update(elapsed);
		if(hadFocus != hasFocus){
			CoolUtil.toggleVolKeys(!hasFocus);
		}
	}

}
#else
	typedef SEInputText = FlxInputText;
#end