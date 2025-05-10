package se.utilities;
@:publicFields class SEDebugPrinter{
	var iterations:Int = 0;
	var name:String = "";
	function new(?name:String = "Unnamed"){
		this.name = name;
		trace('$name:0');
	}
	@:keep inline function it(){
		iterations++;
		trace('$name:$iterations');
	}
}