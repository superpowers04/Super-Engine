
package;

// Code from https://github.com/Tr1NgleBoss/Funkin-0.2.8.0-Port/
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;


using StringTools;

class NoteSplash extends FlxSprite
{  
    override public function new()
    {
        super();
        if (NoteAssets.noteSplashAsset == null){TitleState.loadNoteAssets(true);}
        frames = FlxAtlasFrames.fromSparrow(NoteAssets.splashImage,NoteAssets.splashXml);
        animation.addByPrefix("note1-0", "note splash blue 1", 24, false);
        animation.addByPrefix("note2-0", "note splash green 1", 24, false);
        animation.addByPrefix("note0-0", "note splash purple 1", 24, false);
        animation.addByPrefix("note3-0", "note splash red 1", 24, false);

        animation.addByPrefix("note1-1", "note splash blue 2", 24, false);
        animation.addByPrefix("note2-1", "note splash green 2", 24, false);
        animation.addByPrefix("note0-1", "note splash purple 2", 24, false);
        animation.addByPrefix("note3-1", "note splash red 2", 24, false);

    }

    public function setupNoteSplash(xPos:Float, yPos:Float,?note:Int = 0)
    {
        x = xPos;
        y = yPos;
        alpha = 0.6;
        animation.play("note" + note + "-" + FlxG.random.int(0, 1), true);
        animation.finishCallback = finished;
        animation.curAnim.frameRate = 24;
        updateHitbox();
        // Stolen from psych but whatever
        setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
        offset.set(10, 10);
        // offset.set(0.3 * width, 0.3 * height);
    }
    function finished(name:String){
        kill();
    }
}