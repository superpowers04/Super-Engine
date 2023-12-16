package onlinemod;


@:publicFields @:structInit class Player{
	var id:Int = 0;
	var name:String = "N/A";
	var score:Int = 0;
	var scoreText:String = "N/A";
	var self:Bool = false;
	var currentStateInfo:Array<Dynamic>;
	var disconnected:Bool = false;
	function toString() return name;
	function new(name:String,id:Int){
		this.name = name;
		this.id = id;
	}
}