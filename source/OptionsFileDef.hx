package;


typedef OptionsFileDef = {
	var options:Array<OptionType>;
}
// Map<String,OptionType>
typedef OptionType = {
	var name:String;
	var type:Int;
	var min:Float;
	var max:Float;
	var def:Dynamic;
	var description:String;

	var valueNames:Map<Dynamic,String>;
}
typedef OptionF = {
	var name:String;
	var value:Dynamic;
}