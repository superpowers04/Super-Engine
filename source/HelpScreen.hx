class HelpScreen extends FlxSubState{
	var showImportantText = false;
	var textArray:Array<String> = ["Controls, please replace me", "Some important text here"];
	var helpObjs:Array<FlxObject> = [];
	override function create(){
		// helpShown = true;
		helpObjs = [];
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.8;
		bg.scrollFactor.set();
		helpObjs.push(bg);
		var exitText:FlxText = new FlxText(FlxG.width * 0.7, FlxG.height * 0.9,0,'Press ESC to close.');
		exitText.setFormat(CoolUtil.font, 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		exitText.scrollFactor.set();
		helpObjs.push(exitText);
		var controlsText:FlxText = new FlxText(20,145,0,textArray[0]);
		controlsText.setFormat(CoolUtil.font, 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		controlsText.scrollFactor.set();
		helpObjs.push(controlsText);
		if (showImportantText){
			var importantText:FlxText = new FlxText(10, 48,0,'You cannot save offsets, You have to manually copy them');
			importantText.setFormat(CoolUtil.font, 28, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
			importantText.scrollFactor.set();
			helpObjs.push(importantText);
		}
		for (i => v in helpObjs) {
			add(helpObjs[i]);
		}
	}
	override function update(elapsed:Float){
		if (FlxG.keys.justPressed.ESCAPE)
			closeHelp();
	}
	function closeHelp(){
		for (i => v in helpObjs) {
			helpObjs[i].destroy();
		}
		AnimationDebug.inHelp = false;
		close();
	} 
}