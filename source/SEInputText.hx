package;

class SEInputText extends flixel.addons.ui.FlxInputText{
	
	override public function update(elapsed:Float):Void
	{
		var hadFocus:Bool = hasFocus;
		super.update(elapsed);
		if(hadFocus != hasFocus){
			CoolUtil.toggleVolKeys(!hasFocus);
		}
	}
}