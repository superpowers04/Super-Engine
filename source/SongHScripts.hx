package;

// All of the song specific code turned into hscripts
class SongHScripts {
	public static var scriptList:Map<String,String> =[
	"bopeebo"=> "
		var triggeredAlready = false;
		function canAnimGF(){
			return (gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle');
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
			if (curBeat % 16 == 15 && PlayState.dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
				{
					charAnim(0, 'hey');
					charAnim(2,'cheer');
				}
		}
	",
	"philly"=>"
		var triggeredAlready = false;
		function canAnimGF(){
			return (gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle');
		}

		function beatHit(ps){
			if(ps.generatedMusic && PlayState.SONG.notes[Std.int(ps.curStep / 16)] != null){
				curBeat = ps.curBeat;

				if(curBeat < 250 && curBeat != 184 && curBeat != 216 && canAnimGF())
				{
					if(curBeat % 16 == 8)
					{
						// Just a garantee that it'll trigger just once
						if(!triggeredAlready)
						{
							charAnim(2,'cheer');
							triggeredAlready = true;
						}
					}else triggeredAlready = false;
				}
			}
		}
	",
	"blammed"=>"
		var triggeredAlready = false;
		function canAnimGF(){
			return (gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle');
		}

		function beatHit(ps){
			if(ps.generatedMusic && PlayState.SONG.notes[Std.int(ps.curStep / 16)] != null){
				curBeat = ps.curBeat;

				if(curBeat > 30 && curBeat < 190 && (curBeat < 90 || curBeat > 128) && canAnimGF())
					{
						if(curBeat % 4 == 2)
						{
							if(!triggeredAlready)
							{
								charAnim(2,'cheer');
								triggeredAlready = true;
							}
						}else triggeredAlready = false;
					}
			}
		}
	",
	"cocoa"=>"
		var triggeredAlready = false;
		function canAnimGF(){
			return (gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle');
		}

		function beatHit(ps){
			if(ps.generatedMusic && PlayState.SONG.notes[Std.int(ps.curStep / 16)] != null){
				curBeat = ps.curBeat;


				if(curBeat < 170 && (curBeat < 65 || curBeat > 130 && curBeat < 145) && canAnimGF())
				{
						if(curBeat % 16 == 15)
						{
							if(!triggeredAlready)
							{
								charAnim(2,'cheer');
								triggeredAlready = true;
							}
						}else triggeredAlready = false;
				}
			}
		}
	",
	'eggnog'=>"
		var triggeredAlready = false;
		function canAnimGF(){
			return (gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle');
		}

		function beatHit(ps){
			if(ps.generatedMusic && PlayState.SONG.notes[Std.int(ps.curStep / 16)] != null){
				curBeat = ps.curBeat;


				if(curBeat > 10 && curBeat != 111 && curBeat < 220 && canAnimGF())
				{
					if(curBeat % 8 == 7)
					{
						if(!triggeredAlready)
						{
							charAnim(2,'cheer');
							triggeredAlready = true;
						}
					}else triggeredAlready = false;
				}
			}
		}
	"











	];
}