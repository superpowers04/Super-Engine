package se.formats;

import se.formats.Song;

typedef CNEMeta = {
	var displayName:String;
	var bpm:Float;
	var stage:String;
}
typedef CNEChartFormat = {
	var strumLines:Array<CNEStrumLineData>;
	var events:Array<CNEEvent>;
	var noteTypes:Array<String>;
	var stage:String;
}
typedef CNEStrumLineData = {
	var type:Int;
	var notes:Array<CNENote>;
	var position:String;
	var characters:Array<String>;
}
typedef CNEEvent ={
	var params:Array<Dynamic>;
	var type:Dynamic;
	var time:Float;
}
typedef CNENote ={
	var time:Float;
	var sLen:Float;
	var id:Int;
	var type:Int;
}

class CNEChart{
	public static function fromCNE(json:String,metaJson:String):SwagSong{
		if(json.lastIndexOf('"song":{') != -1) {
			return Song.parseJSONshit(json);
		}
		var cne:CNEChartFormat = Json.parse(json);
		var cneMeta:CNEMeta = Json.parse(json);

		var c:SwagSong = Song.getEmptySong();
		var noteList = c.notes[0].sectionNotes;
		c.player1 = "lonely";
		c.player2 = "lonely";
		c.gfVersion = "lonely";
		for (strumline in cne.strumLines){
			if(strumline.position == "boyfriend"){
				c.player1 = strumline.characters[0];
				for (note in strumline.notes){
					noteList.push([note.time,note.id,note.sLen,cne.noteTypes[note.type]]);
				}
			}else if (strumline.position == "dad"){
				c.player2 = strumline.characters[0];
				for (note in strumline.notes){
					noteList.push([note.time,note.id+4,note.sLen,cne.noteTypes[note.type]]);
				}

			}else if (strumline.position == "girlfriend"){
				c.gfVersion = strumline.characters[0];
			}
		}
		for (note in cne.events){
			noteList.push(convertEvent(note));
		}
		c.stage = cne.stage ?? cneMeta.stage ?? "stage";


		return c;
	}
	public static function convertEvent(event:CNEEvent):Array<Dynamic>{
		switch(event.type){
			case 1:
				return [event.time,-1,"followchar",event.params[0],true];
			default:
				return [event.time,-1,'vslice-${event.type}',event.params];
		}
	}
}