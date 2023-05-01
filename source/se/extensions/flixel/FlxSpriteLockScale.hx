package se.extensions.flixel;
import flixel.FlxSprite;

class FlxSpriteLockScale extends FlxSprite{
	public var graphicWidth:Int = 0;
	public var graphicHeight:Int = 0;
	var _lockedSX:Float = 0;
	var _lockedSY:Float = 0;
	public var lockSize:Bool = false;
	public function lockGraphicSize(w:Int,h:Int){
		graphicWidth = w;
		graphicHeight = h;
		lockSize = true;
		setGraphicSize(graphicWidth,graphicHeight);
		updateHitbox();
		_lockedSX = scale.x;
		_lockedSY = scale.y;
	}
	public override function draw(){
		try{

			if(_lockedSY != scale.y || _lockedSX != scale.x){

				setGraphicSize(graphicWidth,graphicHeight);
				updateHitbox();
				scale.x = _lockedSX;
				scale.y = _lockedSY;
			}
		}catch(e){}
		try{
			super.draw();
		}catch(e){}
	}
}