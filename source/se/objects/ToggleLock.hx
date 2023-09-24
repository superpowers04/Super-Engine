package se.objects;

#if(target.threaded) 
import sys.thread.*;

class ToggleLock extends Lock{
	public function lock(){
		locked = true;
	}
	public var locked:Bool = false;
	override public function wait(?timeout:Float){
		if(!locked) return true;
		return super.wait(timeout);
	}

	override public function release(){
		locked = false;
		return super.release();
	}


}
#else
class ToggleLock{
	public function lock() return;
	public var locked:Bool = false;
	@:keep inline public function wait(?timeout:Float) return true;

	@:keep inline public function release() return;
}
#end