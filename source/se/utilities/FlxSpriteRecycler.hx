package se.utilities;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

@:publicFields class FlxSpriteRecycler {
	var sprites:Array<FlxSprite> = [];
	function new(defCount:Int = 0){
		while (defCount > 0){
			defCount--;
			final spr = new FlxSprite();
			sprites.push(spr);
			spr.kill();
		}
	}
	function resetSprite(spr:FlxSprite):FlxSprite{
		spr.alpha=1;
		spr.angle = 0;
		spr.x = 0;
		spr.y = 0;
		spr.acceleration.x = 0;
		spr.acceleration.y = 0;
		spr.velocity.y = 0;
		spr.velocity.x = 0;
		spr.angularVelocity = 0;
		spr.revive();
		return spr;
	}
	function get(){
		for(i=>spr in sprites){
			if(!spr.alive) {return resetSprite(spr);}
			if(spr == null) {return sprites[i] = new FlxSprite();}
		}
		final spr = new FlxSprite();
		sprites.push(spr);
		return spr;
	}
	function killSprite(spr:FlxSprite,?state:FlxGroup){
		if(state != null) state.remove(spr,true);
		spr.kill();
	}
}