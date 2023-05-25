package se.objects;

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