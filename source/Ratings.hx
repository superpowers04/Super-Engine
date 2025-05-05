package;
import flixel.FlxG;

@:structInit class Rating{
	public var accuracy:Float = 0;
	public var name:String = "";
	public var color:Int = 0xFFFFFFFF;
}

class Ratings
{
	public static var rankings:Array<Rating> = [
		{name:"Perfectly legit",accuracy:100.0001,color:0xFF00d4ff},
		{name:"Perfect!",accuracy:100,color:0xffaaff},
		{name:"SS",accuracy:99,color:0xFFDD88DD},
		{name:"S",accuracy:95,color:0xFFCC77CC},
		{name:"A",accuracy:90,color:0xFF00FF00},
		{name:"A?",accuracy:89,color:0xFF74fc05},
		{name:"B",accuracy:80,color:0xFF8dfc05},
		{name:"B?",accuracy:79,color:0xFFa5fc05},
		{name:"C",accuracy:70,color:0xFFd3fc05},
		{name:"Nice",accuracy:69,color:0xffaaff},
		{name:"D",accuracy:60,color:0xFFd3fc05},
		{name:"D?",accuracy:59,color:0xFFebfc05},
		{name:"E",accuracy:50,color:0xFFfceb05},
		{name:"F",accuracy:40,color:0xFFfcc205},
		{name:"FU",accuracy:30,color:0xFFfc9905},
		{name:"FUC",accuracy:20,color:0xFFfc8405},
		{name:"FUCK",accuracy:10,color:0xFFfc6805},
		{name:"afk",accuracy:1,color:0xFFfc0505},
		{name:"N/A",accuracy:-1,color:0xFFFF0000},
		{name:"actually a bot ong",accuracy:-100,color:0xFFFF0000}
	];
	@:keep public static function getRank(?accuracy:Float = 0) {// Grab ranking from accuracy
		for (ranking in rankings) if(accuracy > ranking.accuracy) return ranking;
		return rankings[rankings.length - 1];
	}
	@:keep public static inline function getLetterRankFromAcc(?accuracy:Float = 0) {// generate a letter ranking
		return getRank(accuracy).name;
	}
	public static function GenerateLetterRank(accuracy:Float) { // generate a letter ranking
		if(SESave.data.botplay) return "BotPlay";
		if (accuracy == 0) return "N/A";
		return getLetterRankFromAcc(accuracy) + (
		  (PlayState.misses > 10) ? " (Clear)"
		: (PlayState.misses > 0)  ? " (SDCB)"
		: (PlayState.shits > 0)   ? " (ShitFC)"
		: (PlayState.bads > 0)    ? " (BadFC)"
		: (PlayState.goods > 0)   ? " (GoodFC)"
		:                           " (SickFC)"
		);
	}
	
	public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
	{
		noteDiff = Math.abs(noteDiff);
		final customTimeScale = customSafeZone == null ? Conductor.timeScale : customSafeZone / 166;

		if (noteDiff > 156 * customTimeScale) // so god damn early its a miss
			return "miss";
		if (noteDiff > 125 * customTimeScale) // way early
			return "shit";
		if (noteDiff > 90 * customTimeScale) // early
			return "bad";
		if (noteDiff > 45 * customTimeScale) // your kinda there
			return "good";
		return "sick";
	}


	public static function CalculateRanking(score:Int,scoreDef:Int,nps:Int,maxNPS:Int,accuracy:Float):String
	{
		return switch(SESave.data.songInfo){
			case 0:(SESave.data.npsDisplay ? 'NPS: $nps (Max $maxNPS) | ' : '')
				+'Score: $score ${Conductor.safeFrames != 10 ? '($scoreDef)' : ''}'
				+' | Combo: ${PlayState.combo}/${PlayState.maxCombo}'
				+' | Breaks: ${PlayState.misses}'
				+'\n| ${CoolUtil.truncateFloat(accuracy, 2)}% ${GenerateLetterRank(accuracy)} |';
			case 1:
				(SESave.data.npsDisplay ? 'NPS: $nps (Max $maxNPS)' : '')
				+'\nScore: $score ${Conductor.safeFrames != 10 ? ' ($scoreDef)' : ''}'
				+'\nCombo: ${PlayState.combo}/${PlayState.maxCombo}'
				+'\nBreaks: ${PlayState.misses}'
				+'\nAccuracy: ${CoolUtil.truncateFloat(accuracy, 2)}%'
				+'\nRank: ${GenerateLetterRank(accuracy)}';
			case 2:(SESave.data.npsDisplay ? 'NPS: ' + nps + ' (Max ' + maxNPS + ')' : '') +                // NPS Toggle
				'\nScore: ' + (Conductor.safeFrames != 10 ? score + ' (' + scoreDef + ')' : '' + score) +                               // Score
				'\nCombo: ' + PlayState.combo + (PlayState.combo < PlayState.maxCombo ? ' (Max ' + PlayState.maxCombo + ')' : '') +
				'\nCombo Breaks/Misses: ' + PlayState.misses + 																				// Misses/Combo Breaks
				'\nSicks: ${PlayState.sicks}\nGoods: ${PlayState.goods}\nBads: ${PlayState.bads}\nShits: ${PlayState.shits}'+
				'\nAccuracy: ' + (SESave.data.botplay ? 'N/A' : CoolUtil.truncateFloat(accuracy, 2) + ' %') +  				// Accuracy
				'\nRank: ' + GenerateLetterRank(accuracy); 
			case 3:'Misses:${PlayState.misses}    Score:$score${Conductor.safeFrames != 10 ? ' ($scoreDef)' : ''}';
			default:'';

		}
	}

	public static function getDistanceFloat(time:Float):Float{
		var _rating = Math.abs(time / (166 * Conductor.timeScale));
	
		return 1 - (Math.floor(_rating * 100) * 0.01);
	}

	
	public static function getDefRating(rating:String):Float{
		switch(rating.toLowerCase()){
			case "sick": return 0.72;
			case "good": return 0.45;
			case "bad":  return 0.27;
			case "shit": return 0.17;
		}
		return 0.0;
	}
	public static var ratings:Map<String,()->Float  > = [
		"sick" => function():Float return SESave.data.judgeSick,
		"good" => function():Float return SESave.data.judgeGood,
		"bad" =>  function():Float return SESave.data.judgeBad,
		"shit" => function():Float return SESave.data.judgeShit
	];
	public static function ratingMS(?rating:String = "",?amount:Float = 0.0):Float{
		if(amount == 0.0){
			amount = ratings[rating.toLowerCase()]();
		}
		return Math.round((1 - amount) * (166 * Conductor.timeScale));
	}
	public static function ratingFromDistance(dist:Float){
		// var dist = getDistanceFloat(distance);
		var rat:Float = 0;
		for (rating in ['sick','good','bad','shit']){
			rat = ratings[rating]();
			if(dist > rat){
				return rating;
			}
		}
		return "miss";
	}
	@:keep inline public static function convertScore(noteDiff:Float):Int {
		return {switch(Ratings.CalculateRating(noteDiff, 166)) {
			case 'shit': -300;
			case 'bad': 0;
			case 'good': 200;
			case 'sick': 350;
			default: 0;
		}}
    }
}
