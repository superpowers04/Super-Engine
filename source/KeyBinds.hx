import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class KeyBinds
{

	public static var gamepad:Bool = false;
	public static var defaultKeys:Array<Array<String>> = [
		["ANY"],
		["A","D"],
		["A","SPACE","D"],
		["A","S","W","D","Z","X","N","M"],
		["A","S","SPACE","W","D"],
		["S","D","F","J","K","L"],
		["S","D","F","SPACE","J","K","L"],
		["A","S","D","F","J","K","L","SEMICOLON"],
		["A","S","D","F","SPACE","J","K","L","SEMICOLON"],
		["Q","W","E","R","V","N","U","I","O","P"],
		["A","S","D","F","C","V","N","M","J","K","L","SEMICOLON"],
		["A","S","D","F","C","V","SPACE","N","M","J","K","L","SEMICOLON"],
		["Q","W","E","R","S","D","F","J","K","L","U","I","O","P"],
		["Q","W","E","R","S","D","F","SPACE","J","K","L","U","I","O","P"],
		["Q","W","E","R","A","S","D","F","H","J","K","L","U","I","O","P"],
		["Q","W","E","R","A","S","D","F","SPACE","H","J","K","L","U","I","O","P"],
		["Q","W","E","R","A","S","D","F","V","B","H","J","K","L","U","I","O","P"],
		["Q","W","E","R","A","S","D","F","C","V","SPACE","N","M","H","J","K","L","U","I","O","P"],
	];

	public static function resetBinds():Void{
		FlxG.save.data.keys = [];
		for(count => keys in defaultKeys){
			FlxG.save.data.keys[count] = keys.copy();
		}
		FlxG.save.data.upBind = "W";
		FlxG.save.data.downBind = "S";
		FlxG.save.data.leftBind = "A";
		FlxG.save.data.rightBind = "D";
		FlxG.save.data.killBind = "R";
		FlxG.save.data.AltupBind = "N";
		FlxG.save.data.AltdownBind = "X";
		FlxG.save.data.AltleftBind = "Z";
		FlxG.save.data.AltrightBind = "M";

		FlxG.save.data.gpupBind = "DPAD_UP";
		FlxG.save.data.gpdownBind = "DPAD_DOWN";
		FlxG.save.data.gpleftBind = "DPAD_LEFT";
		FlxG.save.data.gprightBind = "DPAD_RIGHT";
		PlayerSettings.player1.controls.loadKeyBinds();
	}

}