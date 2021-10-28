package;

import flixel.addons.ui.FlxInputText;

// Why do I need this?

class FlxInputTextUpdatable extends FlxInputText{
	public function updateText(?fnText:String = ""){

		caretIndex = fnText.length;
		text = fnText;

	}
}