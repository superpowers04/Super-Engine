package;

// All of the song specific code turned into hscripts
class SongHScripts {
	public static var scriptList:Map<String,String> =[
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