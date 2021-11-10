import flixel.FlxG;

class Ratings
{
	public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
	{
		var ranking:String = "N/A";
		if(FlxG.save.data.botplay)
			ranking = "BotPlay";

		if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0) // Marvelous (SICK) Full Combo
			ranking = "(MFC)";
		else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "(GFC)";
		else if (PlayState.misses == 0) // Regular FC
			ranking = "(FC)";
		else if (PlayState.misses < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99, // SS
			accuracy >= 95, // S
			accuracy >= 90, // A
			accuracy >= 80, // B
			accuracy >= 70, // back to C
			accuracy >= 69, // nice
			accuracy >= 60, // C
			accuracy >= 50, // D
			accuracy < 50, // F
		];

		for(i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch(i)
				{
					case 0:
						ranking += " SS";
					case 1:
						ranking += " S";
					case 2:
						ranking += " A";
					case 3:
						ranking += " B";
					case 4:
						ranking += " C";
					case 5:
						ranking += " Nice";
					case 6:
						ranking += " C";
					case 7:
						ranking += " D";
					case 8:
						ranking += " F";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";
		else if(FlxG.save.data.botplay)
			ranking = "BotPlay";

		return ranking;
	}
	
	public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
	{

		var customTimeScale = Conductor.timeScale;

		if (customSafeZone != null)
			customTimeScale = customSafeZone / 166;
		
		if (noteDiff > 156 * customTimeScale) // so god damn early its a miss
			return "miss";
		if (noteDiff > 125 * customTimeScale) // way early
			return "shit";
		if (noteDiff > 90 * customTimeScale) // early
			return "bad";
		if (noteDiff > 45 * customTimeScale) // your kinda there
			return "good";
		if (noteDiff < -45 * customTimeScale) // little late
			return "good";
		if (noteDiff < -90 * customTimeScale) // late
			return "bad";
		if (noteDiff < -125 * customTimeScale) // late as fuck
			return "shit";
		if (noteDiff < -156 * customTimeScale) // so god damn late its a miss
			return "miss";
		return "sick";
	}

	public static function CalculateRanking(score:Int,scoreDef:Int,nps:Int,maxNPS:Int,accuracy:Float):String
	{
		return switch(FlxG.save.data.songInfo){
			case 0:(FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ")" : "") +                // NPS Toggle
				" | Score:" + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score) +                               // Score
				" | Combo:" + PlayState.combo + (PlayState.combo < PlayState.maxCombo ? " (Max " + PlayState.maxCombo + ")" : "") +
				" | Combo Breaks:" + PlayState.misses + 																				// Misses/Combo Breaks
				" | Accuracy:" + (FlxG.save.data.botplay ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %") +  				// Accuracy
				" | " + GenerateLetterRank(accuracy);
			case 1:(FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ")" : "") +                // NPS Toggle
				"\nScore: " + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score) +                               // Score
				"\nCombo: " + PlayState.combo + (PlayState.combo < PlayState.maxCombo ? " (Max " + PlayState.maxCombo + ")" : "") +
				"\nCombo Breaks: " + PlayState.misses + 																				// Misses/Combo Breaks
				"\nAccuracy: " + (FlxG.save.data.botplay ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %") +  				// Accuracy
				"\nRank: " + GenerateLetterRank(accuracy);
			case 2:(FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ")" : "") +                // NPS Toggle
				"\nScore: " + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score) +                               // Score
				"\nCombo: " + PlayState.combo + (PlayState.combo < PlayState.maxCombo ? " (Max " + PlayState.maxCombo + ")" : "") +
				"\nCombo Breaks: " + PlayState.misses + 																				// Misses/Combo Breaks
				'\nSicks: ${PlayState.sicks}\nGoods: ${PlayState.goods}\nBads: ${PlayState.bads}\nShits: ${PlayState.shits}\nMisses: ${PlayState.misses}' +
				"\nAccuracy: " + (FlxG.save.data.botplay ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %") +  				// Accuracy
				"\nRank: " + GenerateLetterRank(accuracy);
			case 3:'Misses:${PlayState.misses}    Score:' + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score);
			default:"";

		}
	}
}
