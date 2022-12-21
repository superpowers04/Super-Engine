#Automatically generated documentation#
#Interpeter calls#


##OnlinePlayState.hx##
| Method | Description |
|------------------|---------|
| packetRecieve (PSInstance,packetId,data) | No description provided :< |

##PauseSubState.hx##
| Method | Description |
|------------------|---------|
| pauseCreate (PSInstance,this) | Called when the pause menu is created |
| pause (PSInstance,this) | Called when the game is paused |
| pauseUpdate (PSInstance) | Called when the game updates while paused |
| pauseSelect (PSInstance) | No description provided :< |
| pauseResume (PSInstance) | Called when the player resumes the game |
| pauseExit (PSInstance) | Called when the player exits from the pause menu |

##EventNote.hx##
| Method | Description |
|------------------|---------|
| noteCreate (PSInstance,this,rawNote) | Called when a note is created |
| noteAdd (PSInstance,this,rawNote) | Called when a note is about to be added to the current state |
| noteUpdate (PSInstance,this) | Called when a note updates |
| noteUpdateAfter (PSInstance,this) | Called after a note updates |

##PlayState.hx##
 Has it's own interpet caller
| Method | Description |
|------------------|---------|
| afterStage (PlayState) | No description provided :< |
| addGF (PlayState) | No description provided :< |
| addDad (PlayState) | No description provided :< |
| addChars (PlayState) | No description provided :< |
| addUI (PlayState) | No description provided :< |
| startCountdownFirst (PlayState) | No description provided :< |
| startCountdown (PlayState) | No description provided :< |
| startTimerStep (PlayState,swagCounter) | No description provided :< |
| startTimerStepAfter (PlayState,swagCounter) | No description provided :< |
| startSong (PlayState) | No description provided :< |
| generateNotes (PlayState) | No description provided :< |
| generateNotesAfter (PlayState,unspawnNotes) | No description provided :< |
| generateSongBefore (PlayState) | No description provided :< |
| generateSong (PlayState,unspawnNotes) | No description provided :< |
| strumNoteLoad (PlayState,babyArrow,player == 1) | No description provided :< |
| strumNoteAdd (PlayState,babyArrow,player == 1) | No description provided :< |
| update (PlayState,elapsed) | Called when parent is updated |
| updateAfter (PlayState,elapsed) | Called after every update |
| draw (PlayState) | Called when parent is drawn |
| drawAfter (PlayState) | Called after the parent is drawn |
| endSong (PlayState) | Called when the current song ends |
| keyShit (PlayState,pressArray,holdArray) | No description provided :< |
| susHit (PlayState,daNote) | Called every frame the player holds a sustain note |
| keyShitAfter (PlayState,pressArray,holdArray,hitArray) | No description provided :< |
| beforeNoteHit (PlayState,boyfriend,note) | Called before the player hits a note and it's counted as a hit but after it's rating is calculated |
| noteHit (PlayState,boyfriend,note) | Called when the player hits a note |
| miss (PlayState,boyfriend,direction,calcStats) | Called when the player misses a note |
| noteMiss (PlayState,boyfriend,daNote,direction,calcStats) | Called when the player misses but there's no note |
| stepHit (PlayState) | Called every step hit |
| stepHitAfter (PlayState) | Called after every step hit |
| beatHit (PlayState) | Called every beat hit |
| beatHitAfter (PlayState) | Called after every beat hit |
| keyShit (PlayState,pressArray,holdArray) | No description provided :< |
| keyShitAfter (PlayState,pressArray,holdArray,hitArray) | No description provided :< |
| noteHit (PlayState,boyfriend,note) | Called when the player hits a note |
| destroy (PlayState) | Called when parent is destroyed |

##HoldNote.hx##
| Method | Description |
|------------------|---------|
| noteCreate (PSInstance,this,rawNote) | Called when a note is created |
| noteAdd (PSInstance,this,rawNote) | Called when a note is about to be added to the current state |
| noteUpdate (PSInstance,this) | Called when a note updates |
| noteUpdateAfter (PSInstance,this) | Called after a note updates |

##Character.hx##
 Has it's own interpet caller
| Method | Description |
|------------------|---------|
| initCharacter (Character) | Called before anything on the parent is loaded |
| initScript (Character) | Called when script is initialised |
| new (Character) | Called when parent is created |
| animFinish (Character,animation.curAnim) | No description provided :< |
| animFrame (Character,animation.curAnim,frameNumber,frameIndex) | No description provided :< |
| update (Character,elapsed) | Called when parent is updated |
| draw (Character) | Called when parent is drawn |
| playAnim (PSInstance,AnimName,this) | Called when the parent is about to play an animation |
| playAnim (Character,AnimName) | Called when the parent is about to play an animation |
| playAnimBefore (Character,AnimName) | No description provided :< |
| playAnimAfter (Character,AnimName,animation.curAnim) | No description provided :< |

##ScriptableState.hx##
 Has it's own interpet caller
| Method | Description |
|------------------|---------|
| new (ScriptableState) | Called when parent is created |
| update (ScriptableState,e) | Called when parent is updated |
| updateAfter (ScriptableState,e) | Called after every update |

##Note.hx##
| Method | Description |
|------------------|---------|
| noteCreate (PSInstance,this,rawNote) | Called when a note is created |
| noteAdd (PSInstance,this,rawNote) | Called when a note is about to be added to the current state |
| noteUpdate (PSInstance,this) | Called when a note updates |
| noteHitDad (PSInstance,PlayState.dad,this) | Called when the opponent hits a note |
| noteUpdateAfter (PSInstance,this) | Called after a note updates |

##NoteSplash.hx##
| Method | Description |
|------------------|---------|
| newNoteSplash (PSInstance,this) | Called when a note splash is newed |
| newNoteSplashAfter (PSInstance,this) | Called after a note splash is newed |
| setupNoteSplash (PSInstance,this) | Called when a note splash is setup |
| setupNoteSplashAfter (PSInstance,this) | Called after a note splash is setup |


#Public Functions and Public Variables

##NoteAssets.hx##

| 	public static function | get_frames():FlxFramesCollection |
### SplashNoteAsset ### 
| Type | Name |
|------------------|------|
|  public function | genSplashes(?name_:String = "noteSplashes",?path_:String = "assets/shared/images/"):Void |

##StrumArrow.hx##

|  public function | new(nid:Int = 0,?x:Float = 0,?y:Float = 0) |
| 	public function | changeSprite(?name:String = "default",?_frames:FlxAtlasFrames,?anim:String = "",?setFrames:Bool = true,path_:String = "mods/noteassets",?noteJSON:NoteAssetConfig) |
| 	public function | init() |
| 	public function | playAnim(name:String,?forced:Bool = true, ?Reversed:Bool = false, ?Frame:Int = 0) |
| 	public function | playStatic(?forced:Bool = false) |
| 	public function | press(?forced:Bool = false) |
| 	public function | confirm(?forced:Bool = false) |

##OnlinePlayState.hx##
| Method | Description |
|------------------|---------|
| packetRecieve (PSInstance,packetId,data) | No description provided :< |

##SearchMenuState.hx##

| 	public static var | background:FlxGraphic |
| static public function | resetVars() |
| 	public static var | doReset:Bool  |

##GameplayCustomizeState.hx##

| 	public static var | objs:Map<String,Map<String,ObjectInfo>>  |

##StageEditor.hx##

| 	public static function | loadStage(state:FlxState,json:String):StageOutput |
| 	public function | updateObjectList() |

##PauseSubState.hx##

| 	public function | new(x:Float, y:Float) |

##MusicBeatSubstate.hx##

| 	public function | new()	 |
| 	public function | onTextInputFocus(object:Dynamic) |
| 	public function | onTextInputUnfocus(object:Dynamic) |
| 	public function | stepHit():Void	 |
| 	public function | beatHit():Void	 |

##ChartingState.hx##

|  public function | new(?time:Float = 0) |
| 	public static var | lastPath:String |

##CoolUtil.hx##

| 	public static function | setFramerate(?fps:Int = 0,?update:Bool = false,?temp:Bool = false) |
| 	public static function | clearFlxGroup(obj:FlxTypedGroup<Dynamic>):FlxTypedGroup<Dynamic> |
| 	public static function | difficultyString():String	 |
| 	public static function | toggleVolKeys(?toggle:Bool = true) |
| 	public static function | coolTextFile(path:String):Array<String>	 |
| 	public static function | splitFilenameFromPath(str:String):Array<String> |
| 	public static function | coolFormat(text:String) |
|  public static function | getNativeSongname(?song:String = "",?convLower:Bool = false):String |
| 	public static function | orderList(list:Array<String>):Array<String> |
| 	public static function | coolStringFile(path:String):Array<String>		 |
| 	public static function | numberArray(max:Int, ?min = 0):Array<Int>	 |
| 	public static function | multiInt(?int:Int = 0) |
| 	public static function | cleanJSON(input:String):String |

##SELoader.hx##

| 	public static function | loadFlxSprite(x:Int,y:Int,pngPath:String,?useCache:Bool = false):FlxSprite |
### InternalCache ### 
| Type | Name |
|------------------|------|
| 	public function | new() |
| 	public function | clear() |
| 	public function | getPath(?str:String = "") |
| 	public function | loadFlxSprite(x:Int,y:Int,pngPath:String):FlxSprite |
| 	public function | loadGraphic(pngPath:String):FlxGraphic |
| 	public function | loadSparrowFrames(pngPath:String):FlxAtlasFrames |
| 	public function | loadSparrowSprite(x:Int,y:Int,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24):FlxSprite |
| 	public function | loadText(textPath:String):String |
|  public function | saveText(textPath:String,text:String):Bool |
| 	public function | loadSound(soundPath:String):Sound |
| 	public function | playSound(soundPath:String,?volume:Float = 0.662121):FlxSound |
| 	public function | unloadSound(soundPath:String) |
| 	public function | unloadText(pngPath:String) |
| 	public function | unloadShader(pngPath:String) |
| 	public function | unloadXml(pngPath:String) |
| 	public function | unloadSprite(pngPath:String) |
| 	public function | cacheSound(soundPath:String) |
| 	public function | cacheGraphic(pngPath:String,?dumpGraphic:Bool = false) |
| 	public function | cacheSprite(pngPath:String,?dump:Bool = false) |

##Conductor.hx##

| 	public static function | get_crochetSecs():Float |
| 	public static var | stepCrochet:Float  |
| 	public function | new()	 |
| 	public static function | recalculateTimings()	 |
| 	public static function | mapBPMChanges(song:SwagSong)	 |
| 	public static function | changeBPM(newBpm:Float)	 |

##KeyBindMenu.hx##

|  public static function | getKeyBindsString():String |

##RepoState.hx##

| 	public static function | unzip(from:String,to:String):Void |
|  public function | create():Void	 |
|  public function | update(elapsed:Float) |

##Overlay.hx##

| 	public function | new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFFFF)	 |
| 	public function | new(x:Float = 20, y:Float = 20, color:Int = 0xFFFFFFFF)	 |
| 	public function | log(str:String) |

##SongHScripts.hx##

| 	public static var | scriptList:Map<String,String>  |

##QuickOptionsSubState.hx##

| 	public static function | getSetting(setting:String):Dynamic |
| 	public static function | setSetting(setting:String,value:Dynamic) |
| 	public function | new()	 |

##SickMenuState.hx##

| 	public static function | musicHandle(?isMainMenu:Bool = false,?_bg:FlxSprite = null,?recolor:Bool = false) |
| 	public function | get_supportMouse():Bool |

##KeyBinds.hx##

|  public static function | resetBinds():Void |
|  public static function | keyCheck():Void     |

##Replay.hx##

|  public function | new(path:String)     |
|  public static function | LoadReplay(path:String):Replay     |
|  public function | SaveReplay(notearray:Array<Float>)     |
|  public function | LoadFromJSON()     |

##EventNote.hx##

| 	public function | loadFrames() |
| 	public static var | noteAnims:Array<String>  |
| 	public function | new(strumTime:Float, _noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false,?_type:Dynamic = 0,?rawNote:Array<Dynamic> = null,?playerNote:Bool = false)	 |

##TextBoxSubstate.hx##

### TextBoxSubstate ###
 extends MusicBeatSubState  
| Type | Name |
|------------------|------|

##ChartRepoState.hx##

|  public function | create():Void	 |
|  public function | update(elapsed:Float) |

##KadeEngineData.hx##

|  public static function | initSave()     |

##DirectoryListing.hx##

|  public function | onTextInputFocus(object:Dynamic) |
|  public function | onTextInputUnfocus(object:Dynamic) |

##ArrowCustomizationState.hx##

### ArrowCustomizationState ###
 extends MusicBeatSubstate  
| Type | Name |
|------------------|------|

##Song.hx##

| 	public static var | defNoteMetadata:NoteMetadata  |
| 	public function | new(song, notes, bpm)	 |
| 	public static function | getEmptySong():SwagSong |
| 	public static function | getEmptySongJSON():String |
| 	public static function | loadFromJson(jsonInput:String, ?folder:String):SwagSong	 |
| 	public static function | parseJSONshit(rawJson:String,charting:Bool = false):SwagSong	 |

##DialogueBox.hx##

| 	public function | new(talkingRight:Bool = true, ?dialogueList:Array<String>)	 |

##FlxSprTrail.hx##

|  public function | new(parent:FlxSprite,?time:Float = 0.5) |
|  public function | update(e:Float) |

##HelperFunctions.hx##

|  public static function | truncateFloat( number : Float, precision : Int): Float  |

##HelpScreen.hx##

### HelpScreen ###
 extends FlxSubState  
| Type | Name |
|------------------|------|

##AnimationDebug.hx##

| 	public static function | fileDrop(file:String) |
### AnimHelpScreen ###
 extends FlxUISubState  
| Type | Name |
|------------------|------|
### AnimSwitchMode ###
 extends MusicBeatSubstate   
| Type | Name |
|------------------|------|
### AnimDebugOptions ###
 extends MusicBeatSubstate   
| Type | Name |
|------------------|------|
| 	public function | new()	 |

##TitleState.hx##

| 	public static var | initialized:Bool  |
### FuckinNoDestCam ###
 extends FlxCamera  
| Type | Name |
|------------------|------|

##MusicBeatState.hx##

| 	public function | onFileDrop(file:String):Null<Bool> |
### DebugOverlay ###
 extends FlxTypedGroup<FlxSprite>  
| Type | Name |
|------------------|------|
|  public function | new() |

##PlayState.hx##

| 	public function | get_healthPercent() return Std.int(health * 50);		public function set_healthPercent(vari:Int) |
| 	public function | set_canSaveScore(val) |
| 	public function | set_moveCamera(v):Bool |
| 	public static function | get_songPosBG() |
| 	public static var | songPosBar(get,set):FlxBar |
| 	public static var | underlay:FlxSprite |
| 	public static function | get_girlfriend() |
| 	public static var | bf(get,set):Character |
| 	public static var | opponent(get,set):Character |
| 	public static var | player1:String  |
| 	public static function | addEvent(id:Int,name:String,check:Int,value:Int,func:Dynamic->Void,?variable:String = "def",?type:String="equals"):IfStatement |
| 	public static var | hasStarted  |
| 	public function | requireScript(v:String,?important:Bool = false,?nameSpace:String = "requirement",?script:String = ""):Bool |
| 	public static var | introAudio:Array<flixel.system.FlxAssets.FlxSoundAsset>  |
| 	public function | startCountdown():Void	 |
| 	public function | generateNotes() |
| 	public function | generateSong(?dataPath:String = ""):Void	 |
|  public function | update(elapsed:Float)	 |
| 	public function | followChar(?char:Int = 0,?locked:Bool = true) |
| 	public function | getDefaultCamPos():Array<Float> |
| 	public function | updateCharacterCamPos() |
| 	public function | NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool		 |
| 	public function | DadStrumPlayAnim(id:Int,?anim:String = "confirm")  |
| 	public function | BFStrumPlayAnim(id:Int,anim:String = 'confirm')  |
| 	public function | noteMiss(direction:Int = 1, daNote:Note,?forced:Bool = false,?calcStats:Bool = true):Void	 |
| 	public function | testanimdebug() |

##PlayListState.hx##

| static public function | play(name:String,path:String) |
### OsuQuickOptionsSubState ###
 extends QuickOptionsSubState  
| Type | Name |
|------------------|------|

##MainMenuState.hx##

| 	public static function | handleError(?exception:haxe.Exception = null,?error:String = "An error occurred",?details:String="",?forced:Bool = true):Void |

##Main.hx##

| 	public static function | main():Void	 |
### FlxGameEnhanced ###
 extends FlxGame  
| Type | Name |
|------------------|------|
| 	public function | forceStateSwitch(state:FlxState) |

##ArrowSelection.hx##

| 	public function | updateArrowDisplay() |

##ConvertScore.hx##

|  public static function | convertScore(noteDiff:Float):Int     |

##GameOverState.hx##

| 	public function | new(x:Float, y:Float)	 |

##FinishSubState.hx##

| 	public function | new(x:Float, y:Float,?won = true,?error:String = "",force:Bool = false)	 |
| 	public function | finishNew(?name:String = "") |

##OptionsMenu.hx##

| 	public static function | loadScriptOptions(path:String):Null<Map<String,Dynamic>> |
|  public function | parseHScript(?script:String = "",?brTools:HSBrTools = null,?id:String = "song",option:ScriptableOption) |

##CharSelection.hx##

### CharSelection ###
 extends SearchMenuState   
| Type | Name |
|------------------|------|

##BoneCharacter.hx##

|  public function | new(x:Float, y:Float, ?character:String = "lonely", ?isPlayer:Bool = false,?char_type:Int = 0,?preview:Bool = false) // CharTypes: 0=BF 1=Dad 2=GF// 	 |
### BCAnim  ### 
| Type | Name |
|------------------|------|

##HSBrTools.hx##

| 	public function | new(_path:String,?id:String = "") |
| 	public function | getSetting(setting:String,?defValue:Dynamic = false):Dynamic |
| 	public function | getPath(?str:String = "") |
| 	public function | loadFlxSprite(x:Int,y:Int,pngPath:String):FlxSprite |
| 	public function | loadGraphic(pngPath:String):FlxGraphic |
| 	public function | loadSparrowFrames(pngPath:String):FlxAtlasFrames |
| 	public function | loadSparrowSprite(x:Int,y:Int,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24):FlxSprite |
| 	public function | reset() |
| 	public function | loadText(textPath:String):String |
| 	public function | loadShader(textPath:String,?glslVersion:Int = 120):Null<FlxRuntimeShader> |
|  public function | saveText(textPath:String,text:String):Bool |
| 	public function | loadSound(soundPath:String):Sound |
| 	public function | playSound(soundPath:String,?volume:Float = 0.662121):FlxSound |
| 	public function | unloadSound(soundPath:String) |
| 	public function | unloadText(pngPath:String) |
| 	public function | unloadShader(pngPath:String) |
| 	public function | unloadXml(pngPath:String) |
| 	public function | unloadSprite(pngPath:String) |
| 	public function | cacheSound(soundPath:String) |
| 	public function | cacheGraphic(pngPath:String,?dumpGraphic:Bool = false) |
| 	public function | cacheSprite(pngPath:String,?dump:Bool = false) |

##Options.hx##

| 	public static var | playerEdit:Int  |
### GFOption ###
 extends Option   
| Type | Name |
|------------------|------|
### OpponentOption ###
 extends Option   
| Type | Name |
|------------------|------|
### CharAutoOption ###
 extends Option   
| Type | Name |
|------------------|------|
### CharAutoBFOption ###
 extends Option   
| Type | Name |
|------------------|------|
### AnimDebugOption ###
 extends Option   
| Type | Name |
|------------------|------|
### NoteSplashOption ###
 extends Option   
| Type | Name |
|------------------|------|
### ShitQualityOption ###
 extends Option   
| Type | Name |
|------------------|------|
### NoteRatingOption ###
 extends Option   
| Type | Name |
|------------------|------|
### GUIGapOption ###
 extends Option   
| Type | Name |
|------------------|------|
### SelStageOption ###
 extends Option   
| Type | Name |
|------------------|------|
### ReloadCharlist ###
 extends Option   
| Type | Name |
|------------------|------|
### InputHandlerOption ###
 extends Option   
| Type | Name |
|------------------|------|
### NoteSelOption ###
 extends Option   
| Type | Name |
|------------------|------|
### MMCharOption ###
 extends Option   
| Type | Name |
|------------------|------|
### HitSoundOption ###
 extends Option   
| Type | Name |
|------------------|------|
### CamMovementOption ###
 extends Option   
| Type | Name |
|------------------|------|
### PracticeModeOption ###
 extends Option   
| Type | Name |
|------------------|------|
### ShowP2Option ###
 extends Option   
| Type | Name |
|------------------|------|
### ShowP1Option ###
 extends Option   
| Type | Name |
|------------------|------|
### ShowGFOption ###
 extends Option   
| Type | Name |
|------------------|------|
### PlayVoicesOption ###
 extends Option   
| Type | Name |
|------------------|------|
### CheckForUpdatesOption ###
 extends Option   
| Type | Name |
|------------------|------|
### UnloadSongOption ###
 extends Option   
| Type | Name |
|------------------|------|
### UseBadArrowsOption ###
 extends Option   
| Type | Name |
|------------------|------|
### MiddlescrollOption ###
 extends Option   
| Type | Name |
|------------------|------|
### OpponentStrumlineOption ###
 extends Option   
| Type | Name |
|------------------|------|
### SongInfoOption ###
 extends Option   
| Type | Name |
|------------------|------|
### MissSoundsOption ###
 extends Option   
| Type | Name |
|------------------|------|
### SelScriptOption ###
 extends Option   
| Type | Name |
|------------------|------|
### IntOption ###
 extends Option  
| Type | Name |
|------------------|------|
### FloatOption ###
 extends Option  
| Type | Name |
|------------------|------|
### BoolOption ###
 extends Option  
| Type | Name |
|------------------|------|
### HCBoolOption ###
 extends Option  
| Type | Name |
|------------------|------|
### FontOption ###
 extends Option   
| Type | Name |
|------------------|------|
### BeatBouncingOption ###
 extends Option   
| Type | Name |
|------------------|------|
### AccurateNoteHoldOption ###
 extends Option   
| Type | Name |
|------------------|------|
### AllowServerScriptsOption ###
 extends Option   
| Type | Name |
|------------------|------|
### LogGameplayOption ###
 extends Option   
| Type | Name |
|------------------|------|
### BackTransOption ###
 extends Option   
| Type | Name |
|------------------|------|
### BackgroundSizeOption ###
 extends Option   
| Type | Name |
|------------------|------|
### VolumeOption ###
 extends Option   
| Type | Name |
|------------------|------|
### ScriptableOption ###
 extends Option //   
| Type | Name |
|------------------|------|
### ImportOption ###
 extends Option   
| Type | Name |
|------------------|------|
### EraseOption ###
 extends Option   
| Type | Name |
|------------------|------|
### ExportOption ###
 extends Option   
| Type | Name |
|------------------|------|
### QuickOption ###
 extends Option  
| Type | Name |
|------------------|------|
| 	public function | new(name:String)	 |

##LoadingState.hx##

| 	public function | checkLibrary(library:String)	 |
### MultiCallback  ### 
| Type | Name |
|------------------|------|
| 	public function | new (callback:Void->Void, logId:String = null)	 |
| 	public function | add(id = "untitled")	 |
| 	public function | getFired() return fired.copy();	public function getUnfired() return [for (id in unfired.keys()) id]; |

##Character.hx##

| 	public static var | BFJSON(default,null):String  |
| 	public static var | GFJSON(default,null)  |

##Highscore.hx##

| 	public static var | NORESULT:Array<Dynamic>  |
|  public static var | songScores:Map<String, Int>  |
| 	public static function | saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void	 |
| 	public static function | saveWeekScore(week:Dynamic = 1, score:Int = 0, ?diff:Int = 0):Void	 |
| 	public static function | setScore(song:String, score:Int,?Arr:Array<Dynamic>):Bool	 |
| 	public static function | formatSong(song:String, diff:Int):String	 |
| 	public static function | getScoreUnformatted(song:String):Int	 |
| 	public static function | getScore(song:String, diff:Int):Array<Dynamic>	 |
| 	public static function | getWeekScore(week:Dynamic, diff:Int):Int	 |
| 	public static function | save():Void  |
| 	public static function | load():Void  |

##InputHandlers.hx##

|  public function | create()	 |
| 	public function | swapCharacterByLuaName(spriteName:String,newCharacter:String) |
|  public function | onFocus():Void	 |
|  public function | onFocusLost():Void	 |
| 	public static function | getSVFromTime(strumTime:Float):Float |
|  public function | update(elapsed:Float)	 |

##ScriptableState.hx##

| 	public static function | init(_interp:Interp,state:Class<FlxState>):Dynamic |
### SelectScriptableState ###
 extends SearchMenuState  
| Type | Name |
|------------------|------|
### "$ ### 
| Type | Name |
|------------------|------|
|  public function | openSubState(s:FlxSubState) |
|  public function | switchTo(s:FlxSubState) |

##Note.hx##

| 	public function | get_skipXAdjust() |
| 	public static var | swagWidth:Float  |
| 	public function | toJson() |
| 	public static var | noteAnims:Array<String>  |
| 	public function | new(?strumTime:Float = 0, ?_noteData:Int = 0, ?prevNote:Note, ?sustainNote:Bool = false, ?_inCharter:Bool = false,?_type:Dynamic = 0,?_rawNote:Array<Dynamic> = null,?playerNote:Bool = false)	 |

##OutdatedSubState.hx##

| 	public static var | needVer:String  |
| 	public static var | currChanges:String  |

##LoadingScreen.hx##

| 	public static function | set_loadingText(val:String):String |
| 	public static var | tween:FlxTween |
| 	public static function | show() |
| 	public static function | forceHide() |
| 	public static function | hide() |

##SndTV.hx##

| 	public function | clear() |
| 	public function | new()  |
| 	public function | count()  |
| 	public function | exists(p:Snd)  |
| 	public function | killWithoutCallbacks(parent:Snd)  |
| 	public function | terminate(parent:Snd)  |
| 	public function | forceTerminateTween(t:TweenV)  |
| 	public function | terminateTween(t:TweenV, ?fl_allowLoop=false)  |
| 	public function | terminateAll()  |
| 	public function | update(?tmod = 1.0)  |

##Preloader.hx##

|  public function | new(MinDisplayTime:Float=3, ?AllowedURLs:Array<String>)      |

##StoryMenuState.hx##

| 	public static function | swapSongs(inStoryMenu:Bool = false) |

##ImportMod.hx##

| 	public function | new (folder:String,name:String,?importExisting:Bool = false)	 |

##StageSelection.hx##

### StageSelection ###
 extends SearchMenuState   
| Type | Name |
|------------------|------|

##NoteSplash.hx##

|  public function | new()	 |
| 	public function | setupNoteSplash(?obj:FlxObject = null,?note:Int = 0)	 |

##Alphabet.hx##

| 	public static var | sprite:FlxSprite |
### AlphaCharacter ###
 extends FlxSprite   
| Type | Name |
|------------------|------|
| 	public function | new(x:Float, y:Float,?allowDashes:Bool = false)	 |
| 	public function | createBold(letter:String)	 |
| 	public function | createLetter(letter:String):Void	 |
| 	public function | createNumber(letter:String,bold:Bool = false):Void	 |
| 	public function | createSymbol(letter:String)	 |

##Snd.hx##

| 	public static var | EMPTY_STRING  |
### ChannelLowLevel ###
 extends Channel  
| Type | Name |
|------------------|------|
### Sound  ### 
| Type | Name |
|------------------|------|
| 	public static var | EMPTY_STRING  |
| 	public function | new( snd : Sound, ?name:String )  |
| 	public static var | released  |
| 	public static var | DEBUG_TRACK  |
| 	public static function | loadSound( path:String, streaming : Bool, blocking : Bool  ) : Sound  |
| 	public static function | loadEvent( path:String ) : Sound  |
| 	public static function | fromFaxe( path:String ) : Snd  |
| 	public static function | loadSfx( path:String ) : Snd  |
| 	public static function | loadSong( path:String ) : Snd  |
| 	public static function | load( path:String, streaming=false,blocking=true ) : Snd  |
| 	public static function | terminateTweens()  |
| 	public static function | update()  |
| 	public static function | loadSingleBank( filename : String ) : Null<faxe.Faxe.FmodStudioBankRef> |

##ScriptableStateMacro.hx##

|  public static function | build():Array<Field>  |

##PsychDropDown.hx##

| 	public function | new(X:Float = 0, Y:Float = 0, DataList:Array<StrNameLabel>, ?Callback:String->Void, ?Header:FlxUIDropDownHeader,			?DropPanel:FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?UIControlCallback:Bool->PsychDropDown->Void)	 |
### FlxUIDropDownHeader ###
 extends FlxUIGroup   
| Type | Name |
|------------------|------|
| 	public function | new(Width:Int = 120, ?Background:FlxSprite, ?Text:FlxUIText, ?Button:FlxUISpriteButton)	 |
|  public function | destroy():Void	 |

##FreeplayState.hx##

| 	public static var | lastSong:String  |
### SongMetadata  ### 
| Type | Name |
|------------------|------|
| 	public function | new(song:String, week:Int, songCharacter:String)	 |

##OverlayShader.hx##

| 	public function | new()	 |

##HscriptUtils.hx##

| 	public static function | init()  |
| 	public static var | X     |
| static public function | areSameType(o:Dynamic,c:Dynamic):Bool |
| 	public static var | TRANSPARENT:FlxColor  |
### HscriptGlobals  ### 
| Type | Name |
|------------------|------|
### SEMath  ### 
| Type | Name |
|------------------|------|
### provides advanced methods on Strings. It is ideally used with 	`using StringTools` and then acts as an [extension](https://haxe.org/manual/lf-static-extension.html) 	to the `String` class.  	If the first argument to any of the methods is null, the result is 	unspecified. **/  // I hate inlines  class SEStringTools  ### 
| Type | Name |
|------------------|------|
### containing a set of functions for random generation.  */ class SERandom  ### 
| Type | Name |
|------------------|------|
| 	public function | new(?InitialSeed:Int)	 |
| 	public function | resetInitialSeed():Int	 |
| 	public function | int(Min:Int = 0, Max:Int = FlxMath.MAX_VALUE_INT, ?Excludes:Array<Int>):Int	 |
| 	public function | float(Min:Float = 0, Max:Float = 1, ?Excludes:Array<Float>):Float	 |
| 	public function | floatNormal(Mean:Float = 0, StdDev:Float = 1):Float	 |
| 	public function | bool(Chance:Float = 50):Bool	 |
| 	public function | sign(Chance:Float = 50):Int	 |
| 	public function | weightedPick(WeightsArray:Array<Float>):Int	 |
| 	public function | getObject<T>(Objects:Array<T>, ?WeightsArray:Array<Float>, StartIndex:Int = 0, ?EndIndex:Null<Int>):T	 |
| 	public function | shuffleArray<T>(Objects:Array<T>, HowManyTimes:Int):Array<T>	 |
| 	public function | shuffle<T>(array:Array<T>):Void	 |
| 	public function | color(?Min:FlxColor, ?Max:FlxColor, ?Alpha:Int, GreyScale:Bool = false):FlxColor	 |

##CharacterJson.hx##

| static public function | import(json:String) |