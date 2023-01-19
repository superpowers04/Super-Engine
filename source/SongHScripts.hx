package;

// All of the song specific code turned into hscripts
class SongHScripts {
	public static var scriptList:Map<String,String> =[
	"bopeebo"=> "
		var triggeredAlready = false;
		function canAnimGF(){
			return (PlayState.gf.animation.curAnim.name == 'danceLeft' || PlayState.gf.animation.curAnim.name == 'danceRight' || PlayState.gf.animation.curAnim.name == 'idle');
		}
		function beatHit(ps){
			if(ps.generatedMusic && PlayState.SONG.notes[Std.int(ps.curStep / 16)] != null){
				var curBeat = ps.curBeat;

				if (curBeat % 8 == 7 ) {
					charAnim(0,'hey');
				}
				if(curBeat > 5 && curBeat < 130 && canAnimGF())
				{
					if(curBeat % 8 == 7)
					{
						if(!triggeredAlready)
						{
							charAnim(2,'cheer');
							triggeredAlready = true;
						}
					}else {triggeredAlready = false;}
				}
			}
		}
	",
	"tutorial"=>"
		function beatHit(ps){
			var curBeat = ps.curBeat;
			if (curBeat % 16 == 15 && PlayState.dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
				{
					charAnim(0, 'hey');
					charAnim(2,'cheer');
				}
		}
	"
	];
}