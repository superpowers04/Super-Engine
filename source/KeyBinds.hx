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
		["A","S","W","D",'J','K','I','L'],
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

	public static function keyCheck():Void{
		for(count => keys in defaultKeys){
			var _keys = FlxG.save.data.keys[count];
			if(_keys == null){
				FlxG.save.data.keys[count] = keys.copy();
				continue;
			}
			for(index => key in keys){
				if(_keys[index] == null){
					_keys[index] = key;
				}
			}
		}
	}
	public static function resetBinds():Void{
		FlxG.save.data.keys = [];
		for(count => keys in defaultKeys){
			FlxG.save.data.keys[count] = keys.copy();
		}
		FlxG.save.data.leftBind = FlxG.save.data.keys[0][0];
		FlxG.save.data.downBind = FlxG.save.data.keys[0][1];
		FlxG.save.data.upBind = FlxG.save.data.keys[0][2];
		FlxG.save.data.rightBind = FlxG.save.data.keys[0][3];
		FlxG.save.data.killBind = "R";
		FlxG.save.data.AltupBind = FlxG.save.data.keys[0][4];
		FlxG.save.data.AltdownBind = FlxG.save.data.keys[0][5];
		FlxG.save.data.AltleftBind = FlxG.save.data.keys[0][6];
		FlxG.save.data.AltrightBind = FlxG.save.data.keys[0][7];
		if (FlxG.save.data.AltupBind == null) FlxG.save.data.AltupBind = "F12";
		if (FlxG.save.data.AltdownBind == null) FlxG.save.data.AltdownBind = "F12";
		if (FlxG.save.data.AltleftBind == null) FlxG.save.data.AltleftBind = "F12";
		if (FlxG.save.data.AltrightBind == null) FlxG.save.data.AltrightBind = "F12";
		PlayerSettings.player1.controls.loadKeyBinds();
	}

}