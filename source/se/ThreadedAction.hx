package se;

import sys.thread.Thread;
import se.objects.ToggleLock;

class ThreadedAction{
	#if(sys.thread)
	var lock:ToggleLock = new ToggleLock();
	public function new(func:()->Void){
		lock.lock();
		Thread.create(function(){
			func();
			lock.release();	
		});
	}

	public function wait(?timeout:Float):Bool{
		return lock.wait(timeout);
	}
	#else
	public function new(func:()->Void){
		Thread.create(func);
	}

	public function wait(?timeout:Float):Bool {return true;}
	#end
}