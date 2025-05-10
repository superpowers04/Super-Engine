package se.utilities;
import sys.thread.Thread;

@:publicFields class SEThread{
	static function sandbox(a:()->Void){
		try{
			a();
		}catch(e){
			trace(e);
			throw(e);
		}
	}
	static function create(a:()->Void){
		return Thread.create(sandbox.bind(a));
	}
}