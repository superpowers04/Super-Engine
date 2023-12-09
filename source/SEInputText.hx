package;

import flash.events.KeyboardEvent;
import flixel.FlxG;

class SEInputText extends flixel.addons.ui.FlxInputText{
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

	
	override public function update(elapsed:Float):Void
	{
		var hadFocus:Bool = hasFocus;
		super.update(elapsed);
		if(hadFocus != hasFocus){
			CoolUtil.toggleVolKeys(!hasFocus);
		}
	}
	/**
	 * Handles keypresses generated on the stage.
	 */
	override private function onKeyDown(e:KeyboardEvent):Void {
		var key:Int = e.keyCode;

		if (!hasFocus) return;
		// Do nothing for Shift, Ctrl, Esc, and flixel console hotkey
		if (key == 16 || key == 17 || key == 220 || key == 27) return;
		// Left arrow
		else if (FlxG.keys.pressed.CONTROL){
			if(key == 25){
				var newText:String = filter(lime.system.Clipboard.text);
				if (newText.length <= 0 && (maxLength == 0 || (text.length + newText.length) > maxLength)) return;
				text = insertSubstring(text, newText, caretIndex);
				caretIndex+=newText.length;
				onChange(INPUT_ACTION);
			}
		}else if (key == 37)
		{
			if (caretIndex < 1) return;
			caretIndex--;
			text = text; // forces scroll update
			
		}
		// Right arrow
		else if (key == 39){
			if (caretIndex > text.length) return;
			caretIndex++;
			text = text; // forces scroll update
			
		}
		// End key
		else if (key == 35){
			caretIndex = text.length;
			text = text; // forces scroll update
		}
		// Home key
		else if (key == 36)
		{
			caretIndex = 0;
			text = text;
		}
		// Backspace
		else if (key == 8) {
			if (caretIndex > 0)
			{
				caretIndex--;
				text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
				onChange(BACKSPACE_ACTION);
			}
		}
		// Delete
		else if (key == 46) {
			if (text.length < 0 || caretIndex > text.length) return;
			text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
			onChange(DELETE_ACTION);
		}
		// Enter
		else if (key == 13) onChange(ENTER_ACTION);
		// Actually add some text
		else {
			if (e.charCode == 0) return; // non-printable characters crash String.fromCharCode
			var newText:String = filter(String.fromCharCode(e.charCode));

			
			if (newText.length <= 0 && (maxLength == 0 || (text.length + newText.length) > maxLength)) return;
				text = insertSubstring(text, newText, caretIndex);
				caretIndex++;
				onChange(INPUT_ACTION);
		}
		
	}
}