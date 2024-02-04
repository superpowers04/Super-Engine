package se;

import sys.thread.Thread;
import se.objects.ToggleLock;

#if(target.threaded)
class ThreadedAction extends ToggleLock{
	public function new(func:()->Void){
		super();
		lock();

		Thread.create(function(){
			func();
			release();	
		});
	}
}
#else
class ThreadedAction{
	public function new(func:()->Void){
		func();
	}
	public function wait():Bool {return true;}
}
#end