package;

import SEInputText as FlxInputText;
import flixel.text.FlxText;

// Why do I need this?

class FlxInputTextUpdatable extends FlxInputText{
	public var headerText:FlxText; // Just for easier access
	public function updateText(?fnText:String = ""){

		caretIndex = fnText.length;
		text = fnText;

	}
}