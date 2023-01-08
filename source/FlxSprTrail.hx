package;

import flixel.group.*;
import flixel.*;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxFrame;


// Reimplementation of FlxTrail for FlxSprites that doesn't do fucky things with it's parent
// Meant for Super Engine, pls leave credit in or else i murder you :>

@:structInit class TrailData {
	public var antialiasing:Bool = false;
	public var frame:FlxFrame;
	public var x:Float = 0;
	public var y:Float = 0;
	public var scaleX:Float = 0;
	public var scaleY:Float = 0;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var originX:Float = 0;
	public var originY:Float = 0;
	public var flipX:Bool = false;
	public var flipY:Bool = false;
	public var color:FlxColor = 0xFFFFFF;
	public var visible:Bool = true;
	public var alpha:Float = 0;
	public var angle:Float = 0;
	public function applyTo(object:FlxSprite,?changeFrame:Bool = true){
		object.x = x;
		object.y = y;
		object.scale.x = scaleX;
		object.scale.y = scaleY;
		if(changeFrame){
			object.offset.x = offsetX;
			object.offset.y = offsetY;
			object.frame = frame;
			object.flipX = flipX;
			object.flipY = flipY;
		}
		object.origin.x = originX;
		object.origin.y = originY;
		object.color = color;
		object.angle = angle;
		object.alpha = alpha;
		object.antialiasing = antialiasing;
	}
}




class FlxSprTrail extends FlxSpriteGroup {
	public var parent:FlxSprite;
	public var buffer:Array<TrailData> = [];
	public var sprites:Array<FlxSprite> = [];
	public var updateTime:Float = 0; // If 0, you have to update the frames manually
	public var elapsed:Float = 0;
	public var start:Int = 1;
	public var end:Int = 2;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var shakingMultiplier:Float = 0;
	public var shakingXMulti:Float = 1;
	public var shakingYMulti:Float = 1;
	public var fallOff:Float = 1;
	public var updateBasedOnFrames:Bool = false;

	override public function new(parent:FlxSprite,?time:Float = 0,spriteStart:Int = 1,spriteAmount:Int = 2,spriteOffsetX:Float = 0,spriteOffsetY:Float = 0){
		super();
		if(parent == null){
			throw "Parent sprite is null!";
		}
		this.parent = parent;
		this.updateTime = time;
		start = spriteStart;
		end = spriteAmount;
		offsetX = spriteOffsetX;
		offsetY = spriteOffsetY;
		generateSprites();
	}
	public function generateSprites(){
		for (sprite in sprites){
			if(sprite != null){
				try{
					remove(sprite);
				}catch(e){}
				try{
					sprite.destroy();
				}catch(e){}
			}
		}
		buffer = [];
		sprites = [];
		var i = end;
		while (i > 0){

			addToBuffer(i);
			if(i >= start){
				var trail = new FlxSprite();
				trail.visible = false;
				sprites[i] = trail; 
				add(trail);

			}
			i--;
		}
		updateFrames();
	}
	override public function update(e:Float){
		if(updateTime != 0){
			elapsed += e;
			if(elapsed > updateTime){
				elapsed = 0;
				updateFrames();
			}
		}
		super.update(e);
	}
	public function addToBuffer(?index:Int = -1,?color:FlxColor = 0xFFFFFF){
		buffer[index] = {
			frame:parent.frame,
			x:parent.x,
			y:parent.y,
			offsetY:parent.offset.y,
			offsetX:parent.offset.x,
			originY:parent.origin.y,
			originX:parent.origin.x,
			scaleY:parent.scale.y,
			scaleX:parent.scale.x,
			flipX:parent.flipX,
			flipY:parent.flipY,
			color:color,
			alpha:parent.alpha,
			visible:parent.visible,
			angle:parent.angle,
			antialiasing:parent.antialiasing,
		}
	}
	public override function draw(){
		if(buffer[-1] != null && updateBasedOnFrames && buffer[-1].frame != parent.frame){
			updateFrames();
		}
		super.draw();
		if(shakingMultiplier != 0 ){
			var i = end;
			while (i > 0){
				if(sprites[i] != null){
					sprites[i].x = buffer[i].x + (offsetX * i) + (FlxG.random.float(0,2) + ((10 * i + 1.25))) * (shakingMultiplier*shakingXMulti);
					sprites[i].y = buffer[i].y + (offsetY * i) + (FlxG.random.float(0,2) + ((10 * i + 1.25))) * (shakingMultiplier*shakingYMulti);
				}
				i--;
			}
		}

	}
	public function updateFrames(?color:FlxColor = 0xFFFFFFF,?changeFrame:Bool = true){
		var i = end;

		if(parent == null){
			throw "Parent sprite is null!";
		}
		addToBuffer(0,color);
		while (i > 0){
			buffer[i] = buffer[i - 1];
			if(sprites[i] != null){
				buffer[i].applyTo(sprites[i],changeFrame);
				sprites[i].color = color;
				sprites[i].x += (offsetX * i);
				sprites[i].y += (offsetY * i);
				if(fallOff > 0){
					sprites[i].alpha *=	1 - (fallOff * (i / end));
				}
			}
			i--;
		}
	}
}