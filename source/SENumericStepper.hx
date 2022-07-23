package;

class SENumericStepper extends flixel.addons.ui.FlxUINumericStepper{
	public var text(get,set):String;
	public function set_text(v){
		value = Std.parseFloat(v);
		return get_text();
	}
	public function get_text(){
		return '${value}';
	}
	public var callback:(Float,String)->Void;
	private override function _doCallback(event_name:String):Void
	{
		super._doCallback(event_name);
		if(callback != null){
			callback(value,event_name);
		}
	}
}