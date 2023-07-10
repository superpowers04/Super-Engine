#Automatically generated documentation#
#Interpeter calls#


##ScriptableState.hx##
 Has it's own interpet caller
| Method | Description |
|------------------|---------|
| new (ScriptableState) | Called when parent is created |
| update (ScriptableState,e) | Called when parent is updated |
| updateAfter (ScriptableState,e) | Called after every update |

##PlayState.hx##
 Has it's own interpet caller
| Method | Description |
|------------------|---------|
| reload (PlayState,false) | No description provided :< |
| unload (PlayState) | No description provided :< |
| reloadDone (PlayState) | No description provided :< |
| afterStage (PlayState) | No description provided :< |
| addGF (PlayState) | No description provided :< |
| addDad (PlayState) | No description provided :< |
| addChars (PlayState) | No description provided :< |
| addUI (PlayState) | No description provided :< |
| openDialogue (PlayState,doof) | No description provided :< |
| startCountdownFirst (PlayState) | No description provided :< |
| swapChars (PlayState,PlayState.bf,PlayState.dad) | No description provided :< |
| swapCharsAfter (PlayState,PlayState.bf,PlayState.dad) | No description provided :< |
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
| noteSpawn (PlayState,dunceNote) | No description provided :< |
| draw (PlayState) | Called when parent is drawn |
| drawAfter (PlayState) | Called after the parent is drawn |
| endSong (PlayState) | Called when the current song ends |
| spawnNoteSplash (PlayState,a) | No description provided :< |
| popUpScore (PlayState,rating,scoreObjs,currentTimingShown) | No description provided :< |
| holdShit (PlayState,holdArray) | No description provided :< |
| susHit (PlayState,daNote) | Called every frame the player holds a sustain note |
| holdShitAfter (PlayState,holdArray) | No description provided :< |
| registerKeys (PlayState,SEIKeyMap) | No description provided :< |
| registerKeysAfter (PlayState,SEIKeyMap) | No description provided :< |
| keyPress (PlayState,event.keyCode) | No description provided :< |
| keyShit (PlayState,pressArray,holdArray) | No description provided :< |
| susHit (PlayState,daNote) | Called every frame the player holds a sustain note |
| keyShitAfter (PlayState,pressArray,holdArray,hitArray) | No description provided :< |
| keyRelease (PlayState,event.keyCode) | No description provided :< |
| botKeyShit (PlayState) | No description provided :< |
| susHit (PlayState,daNote) | Called every frame the player holds a sustain note |
| keyShit (PlayState,pressArray,holdArray) | No description provided :< |
| susHit (PlayState,daNote) | Called every frame the player holds a sustain note |
| keyShitAfter (PlayState,pressArray,holdArray,hitArray) | No description provided :< |
| beforeNoteHit (PlayState,boyfriend,note) | Called before the player hits a note and it's counted as a hit but after it's rating is calculated |
| noteHit (PlayState,boyfriend,note) | Called when the player hits a note |
| miss (PlayState,boyfriend,direction,calcStats) | Called when the player misses a note |
| miss (PSInstance,direction,calcStats) | Called when the player misses a note |
| noteMiss (PlayState,boyfriend,daNote,direction,calcStats) | Called when the player misses but there's no note |
| noteMiss (PSInstance,daNote,direction,calcStats) | Called when the player misses but there's no note |
| stepHit (PlayState) | Called every step hit |
| stepHitAfter (PlayState) | Called after every step hit |
| beatHit (PlayState) | Called every beat hit |
| beatHitAfter (PlayState) | Called after every beat hit |
| destroy (PlayState) | Called when parent is destroyed |

##OnlinePlayState.hx##
| Method | Description |
|------------------|---------|
| packetRecieve (PSInstance,packetId,data) | No description provided :< |

##OfflineMenuState.hx##
| Method | Description |
|------------------|---------|
| chartOptions (PSInstance) | No description provided :< |
| extraKeys (PSInstance) | No description provided :< |
| select (PSInstance,sel) | No description provided :< |

##ChartingState.hx##
| Method | Description |
|------------------|---------|
| updateNote (PSInstance,note,i) | No description provided :< |
| updateGrid (PSInstance,updateNotes) | No description provided :< |
| updateGridAfter (PSInstance) | No description provided :< |
| addSection (PSInstance,sec) | No description provided :< |
| selectNote (PSInstance,currentNoteObj) | No description provided :< |
| clearSection (PSInstance,sect) | No description provided :< |
| clearSong (PSInstance,currentNoteObj) | No description provided :< |
| addNote (PSInstance,thingy) | No description provided :< |
| loadChart (PSInstance,_song) | No description provided :< |
| saveChart (PSInstance,path) | No description provided :< |

##PauseSubState.hx##
| Method | Description |
|------------------|---------|
| pauseCreate (PSInstance,this) | Called when the pause menu is created |
| pause (PSInstance,this) | Called when the game is paused |
| pauseUpdate (PSInstance) | Called when the game updates while paused |
| pauseSelect (PSInstance,sel) | No description provided :< |
| pauseResume (PSInstance) | Called when the player resumes the game |
| pauseExit (PSInstance) | Called when the player exits from the pause menu |

##MainMenuState.hx##
| Method | Description |
|------------------|---------|
| firstStart (PSInstance) | No description provided :< |
| createAfter (PSInstance) | No description provided :< |
| otherSwitch (PSInstance) | No description provided :< |
| mmSwitch (PSInstance) | No description provided :< |
| select (PSInstance,sel,daChoice) | No description provided :< |
| addToList (PSInstance,i,options[i]) | No description provided :< |
| addToListAfter (PSInstance,controlLabel,i,options[i]) | No description provided :< |

##SickMenuState.hx##
| Method | Description |
|------------------|---------|
| generateList (PSInstance) | No description provided :< |
| generateListAfter (PSInstance,grpControls) | No description provided :< |
| addToList (PSInstance,i,options[i]) | No description provided :< |
| addToListAfter (PSInstance,controlLabel,i,options[i]) | No description provided :< |
| handleInput (PSInstance) | No description provided :< |
| changeSelection (PSInstance,change) | No description provided :< |
| changeSelectionAfter (PSInstance,change) | No description provided :< |

##SearchMenuState.hx##
| Method | Description |
|------------------|---------|
| addToList (PSInstance,char,i) | No description provided :< |
| addToListAfter (PSInstance,controlLabel,char,i) | No description provided :< |
| handleInput (PSInstance) | No description provided :< |
| changeSelection (PSInstance,change) | No description provided :< |
| changeSelectionAfter (PSInstance,change) | No description provided :< |

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

##Note.hx##
| Method | Description |
|------------------|---------|
| noteCheckType (PSInstance,this,rawNote) | No description provided :< |
| noteCreate (PSInstance,this,rawNote) | Called when a note is created |
| noteAdd (PSInstance,this,rawNote) | Called when a note is about to be added to the current state |
| noteDestroy (PSInstance,this) | No description provided :< |
| noteUpdate (PSInstance,this) | Called when a note updates |
| eventNoteHit (PSInstance,this) | No description provided :< |
| noteHitDad (PSInstance,PlayState.dad,this) | Called when the opponent hits a note |
| noteUpdateAfter (PSInstance,this) | Called after a note updates |

##NoteSplash.hx##
| Method | Description |
|------------------|---------|
| newNoteSplash (PSInstance,this) | Called when a note splash is newed |
| newNoteSplashAfter (PSInstance,this) | Called after a note splash is newed |
| setupNoteSplash (PSInstance,this) | Called when a note splash is setup |
| setupNoteSplashAfter (PSInstance,this) | Called after a note splash is setup |

##EventNote.hx##
| Method | Description |
|------------------|---------|
| eventNoteCheckType (PSInstance,note,rawNote) | No description provided :< |
| changeChar (PSInstance,_oldChar) | No description provided :< |
| changeChar (PSInstance,_char,_oldChar,id) | No description provided :< |
| eventNoteAdd (PSInstance,this,rawNote) | No description provided :< |

##ScriptMusicBeatState.hx##
 Has it's own interpet caller
| Method | Description |
|------------------|---------|
| reload (ScriptMusicBeatState,false) | No description provided :< |
| unload (ScriptMusicBeatState) | No description provided :< |
| reloadDone (ScriptMusicBeatState) | No description provided :< |
| reloadDone (ScriptMusicBeatState) | No description provided :< |
| createAfter (ScriptMusicBeatState) | No description provided :< |
| draw (ScriptMusicBeatState) | Called when parent is drawn |
| destroy (ScriptMusicBeatState) | Called when parent is destroyed |
| beatHit (ScriptMusicBeatState) | Called every beat hit |
| stepHit (ScriptMusicBeatState) | Called every step hit |
| unload (ScriptMusicBeatState) | No description provided :< |
| reload (ScriptMusicBeatState,true) | No description provided :< |
| unload (ScriptMusicBeatState) | No description provided :< |
| update (ScriptMusicBeatState,e) | Called when parent is updated |
| openSubState (ScriptMusicBeatState,s) | No description provided :< |
| add (ScriptMusicBeatState,obj) | No description provided :< |
| remove (ScriptMusicBeatState,Object,Splice) | No description provided :< |
| switchTo (ScriptMusicBeatState,s) | No description provided :< |

##HoldNote.hx##
| Method | Description |
|------------------|---------|
| noteCreate (PSInstance,this,rawNote) | Called when a note is created |
| noteAdd (PSInstance,this,rawNote) | Called when a note is about to be added to the current state |
| noteUpdate (PSInstance,this) | Called when a note updates |
| noteUpdateAfter (PSInstance,this) | Called after a note updates |

##ScriptableStates.hx##
| Method | Description |
|------------------|---------|
| openSubState (PSInstance,state) | No description provided :< |
| openSubStateAfter (PSInstance,state) | No description provided :< |
| handleInput (PSInstance) | No description provided :< |
| handleInputAfter (PSInstance) | No description provided :< |
| destroy (PSInstance) | Called when parent is destroyed |
| destroyAfter (PSInstance) | No description provided :< |
| closeSubState (PSInstance) | No description provided :< |
| closeSubStateAfter (PSInstance) | No description provided :< |
| update (PSInstance,e) | Called when parent is updated |
| updateAfter (PSInstance,e) | Called after every update |
| stepHit (PSInstance) | Called every step hit |
| stepHitAfter (PSInstance) | Called after every step hit |
| reloadList (PSInstance,reload,search) | No description provided :< |
| reloadListAfter (PSInstance,reload,search) | No description provided :< |
| findButton (PSInstance) | No description provided :< |
| findButtonAfter (PSInstance) | No description provided :< |
| switchTo (PSInstance,state) | No description provided :< |
| select (PSInstance,sel) | No description provided :< |
| selectAfter (PSInstance,sel) | No description provided :< |
| beatHit (PSInstance) | Called every beat hit |
| beatHitAfter (PSInstance) | Called after every beat hit |
| onFocus (PSInstance) | No description provided :< |
| onFocusAfter (PSInstance) | No description provided :< |
| tryUpdate (PSInstance,e) | No description provided :< |
| tryUpdateAfter (PSInstance,e) | No description provided :< |
| create (PSInstance) | No description provided :< |
| createAfter (PSInstance) | No description provided :< |
| addToList (PSInstance,char,i) | No description provided :< |
| addToListAfter (PSInstance,char,i) | No description provided :< |
| ret (PSInstance) | No description provided :< |
| draw (PSInstance) | Called when parent is drawn |
| drawAfter (PSInstance) | Called after the parent is drawn |
| changeSelection (PSInstance,sel) | No description provided :< |
| changeSelectionAfter (PSInstance,sel) | No description provided :< |
| onFocusLost (PSInstance) | No description provided :< |
| onFocusLostAfter (PSInstance) | No description provided :< |
| new (PSInstance,this,) | Called when parent is created |
| newAfter (PSInstance) | No description provided :< |
| openSubState (PSInstance,state) | No description provided :< |
| openSubStateAfter (PSInstance,state) | No description provided :< |
| draw (PSInstance) | Called when parent is drawn |
| drawAfter (PSInstance) | Called after the parent is drawn |
| destroy (PSInstance) | Called when parent is destroyed |
| destroyAfter (PSInstance) | No description provided :< |
| tryUpdate (PSInstance,e) | No description provided :< |
| tryUpdateAfter (PSInstance,e) | No description provided :< |
| create (PSInstance) | No description provided :< |
| createAfter (PSInstance) | No description provided :< |
| update (PSInstance,e) | Called when parent is updated |
| updateAfter (PSInstance,e) | Called after every update |
| stepHit (PSInstance) | Called every step hit |
| stepHitAfter (PSInstance) | Called after every step hit |
| onFocusLost (PSInstance) | No description provided :< |
| onFocusLostAfter (PSInstance) | No description provided :< |
| onFocus (PSInstance) | No description provided :< |
| onFocusAfter (PSInstance) | No description provided :< |
| beatHit (PSInstance) | Called every beat hit |
| beatHitAfter (PSInstance) | Called after every beat hit |
| closeSubState (PSInstance) | No description provided :< |
| closeSubStateAfter (PSInstance) | No description provided :< |
| switchTo (PSInstance,state) | No description provided :< |
| new (PSInstance,this,) | Called when parent is created |
| newAfter (PSInstance) | No description provided :< |

##MultiMenuState.hx##
| Method | Description |
|------------------|---------|
| addListing (PSInstance,name,i) | No description provided :< |
| addListingAfter (PSInstance,controlLabel,name,i) | No description provided :< |
| addCategory (PSInstance,name,i) | No description provided :< |
| addCategoryAfter (PSInstance,controlLabel,name,i) | No description provided :< |
| reloadList (PSInstance,reload,search,query) | No description provided :< |


#Public Functions and Public Variables

##ErrorSubState.hx##

| 	public function | new(x:Float, y:Float,?error:String = "",force:Bool = false)
	 |
| 	public static var | endingMusic:Sound |
| 	public var | cam:FlxCamera |
| 	public var | contText:FlxText |

##ScriptableState.hx##

| 	public static function | init(_interp:Interp,state:Class<FlxState>):Dynamic |
### SelectScriptableState
 extends SearchMenuState  
| Type | Name |
|------------------|------|
### "$
| Type | Name |
|------------------|------|

##OverlayShader.hx##

| 	public function | new()	 |

##MusicBeatState.hx##

| 	public function | goToLastClass(?avoidType:Class<Any> = null) |
### DebugOverlay
 extends FlxTypedGroup<FlxSprite>  
| Type | Name |
|------------------|------|
|  public function | new(parent:MusicBeatState) |

##PlayState.hx##

| 	public static function | set_shits(vari:Int):Int |
| 	public static var | accuracy(default,set):Float  |
| 	public function | get_healthPercent() return Std.int(health * 50);		public function set_healthPercent(vari:Int) |
| 	public function | set_canSaveScore(val) |
| 	public function | set_botPlay(val) |
| 	public function | set_moveCamera(v):Bool |
| 	public static function | get_songPosBG() |
| 	public static var | songPosBar(get,set):FlxBar |
| 	public static var | underlay:FlxSprite |
|  public static function | get_girlfriend() |
| 	public static var | bf(get,set):Character |
| 	public static var | opponent(get,set):Character |
| 	public static var | player1:String  |
| 	public function | addEvent(id:Int,name:String,check:Int,value:Int,func:Dynamic->Void,?variable:String = "def",?type:String="equals"):IfStatement |
| 	public static var | hasStarted  |
| 	public var | swappedChars  |
| 	public static var | introAudio:Array<flixel.system.FlxAssets.FlxSoundAsset>  |
| 	public function | startCountdown():Void	 |
|  public function | generateNotes() |
| 	public var | useNoteCameras:Bool  |
|  public function | update(elapsed:Float)	 |
| 	public var | cameraPositions:Array<Array<Float>>  |
| 	public function | updateCharacterCamPos() |
| 	public var | acceptInput  |
| 	public function | testanimdebug() |

##LoadingScreen.hx##

| 	public static function | set_loadingText(val:String):String |
| 	public static var | tween:FlxTween |
| 	public static function | show() |
| 	public static function | forceHide() |
| 	public static function | hide() |

##AnimationDebug.hx##

| 	public static function | fileDrop(file:String) |
### AnimHelpScreen
 extends FlxUISubState  
| Type | Name |
|------------------|------|
### AnimSwitchMode
 extends MusicBeatSubstate   
| Type | Name |
|------------------|------|
### AnimDebugOptions
 extends MusicBeatSubstate   
| Type | Name |
|------------------|------|
| 	public function | new()	 |

##Overlay.hx##

| 	public function | new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFFFF)	 |
| 	public function | new(x:Float = 20, y:Float = 20, color:Int = 0xFFFFFFFF)	 |
| 	public var | _parent:Console  |
### ConsoleUtils
| Type | Name |
|------------------|------|
| 	public static function | getValueFromPath(object:Dynamic,path:String = "",returnErrors:Bool = true):Dynamic |
| 	public static function | quickObject(vari:String):Dynamic |
| 	public static function | setValueFromPath(path:String = "",value:Dynamic) |

##SELoader.hx##

| 	public static function | set_PATH(_path:String):String |
### InternalCache
| Type | Name |
|------------------|------|
| 	public function | new() |
| 	public function | clear() |
|  public function | getPath(?str:String = "") |
| 	public function | loadFlxSprite(x:Int,y:Int,pngPath:String):FlxSprite |
| 	public function | loadGraphic(pngPath:String):FlxGraphic |
| 	public function | loadBitmap(pngPath:String):BitmapData |
| 	public function | loadSparrowFrames(pngPath:String):FlxAtlasFrames |
| 	public function | loadSparrowSprite(x:Int,y:Int,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24):FlxSprite |
| 	public function | loadText(textPath:String):String |
|  public function | saveText(textPath:String,text:String):Bool |
| 	public function | loadSound(soundPath:String):Sound |
| 	public function | playSound(soundPath:String,?volume:Float = 0.662121):FlxSound |
| 	public function | unloadSound(soundPath:String) |
| 	public function | unloadText(pngPath:String) |
| 	public function | unloadShader(pngPath:String) |
| 	public function | unloadSprite(pngPath:String) |
| 	public function | cacheText(textPath:String) |
| 	public function | cacheSound(soundPath:String) |
| 	public function | cacheBitmap(pngPath:String) |
| 	public function | cacheGraphic(pngPath:String) |
| 	public function | cacheSprite(pngPath:String) |
|  public static function | absolutePath(path:String):String |
|  public static function | fullPath(path:String):String |
|  public static function | exists(path:String):Bool |
|  public static function | readDirectory(path:String):Array<String> |
|  public static function | isDirectory(path:String):Bool |
|  public static function | createDirectory(path:String) |

##GameplayCustomizeState.hx##

| 	public static var | objs:Map<String,Map<String,ObjectInfo>>  |

##Alphabet.hx##

| 	public function | set_text(repl:String = ""):String |
### CachedSprite
| Type | Name |
|------------------|------|
| 	public static function | cacheAlphaChars() |
| 	public var | row:Int  |
| 	public function | new(x:Float, y:Float,?allowDashes:Bool = false,?forcedFlxText:Bool = false)	 |
|  public function | createBold(letter:String)	 |
|  public function | createLetter(letter:String):Void	 |
|  public function | createNumber(letter:String,bold:Bool = false):Void	 |
|  public function | useFLXTEXT(letter:String,bold:Bool = false) |
|  public function | createSymbol(letter:String)	 |

##KadeEngineData.hx##

|  public static function | initSave()
     |

##OptionsMenu.hx##

| 	public static function | loadScriptOptions(path:String):Null<Map<String,Dynamic>> |
|  public function | parseHScript(?script:String = "",?brTools:HSBrTools = null,?id:String = "song",option:ScriptableOption) |

##StoryMenuState.hx##

| 	public static function | swapSongs(inStoryMenu:Bool = false) |

##LoadingState.hx##

| 	public var | callback:Void->Void |
| 	public function | new (callback:Void->Void, logId:String = null)	 |
| 	public function | add(id = "untitled")	 |
| 	public function | getFired() return fired.copy();	public function getUnfired() return [for (id in unfired.keys()) id]; |

##CoolUtil.hx##

| 	public static function | setFramerate(?fps:Int = 0,?update:Bool = false,?temp:Bool = false) |
| 	public static function | clearFlxGroup(obj:FlxTypedGroup<Dynamic>):FlxTypedGroup<Dynamic> |
| 	public static function | difficultyString():String	 |
| 	public static function | toggleVolKeys(?toggle:Bool = true) |
| 	public static function | coolTextFile(path:String):Array<String>	 |
| 	public static function | splitFilenameFromPath(str:String):Array<String> |
| 	public static function | coolFormat(text:String) |
| 	public static function | formatChartName(str:String):String |
|  public static function | getNativeSongname(?song:String = "",?convLower:Bool = false):String |
| 	public static function | orderList(list:Array<String>):Array<String> |
| 	public static function | coolStringFile(path:String):Array<String>		 |
| 	public static function | numberArray(max:Int, ?min = 0):Array<Int>	 |
| 	public static function | multiInt(?int:Int = 0) |
| 	public static function | cleanJSON(input:String):String |

##OnlinePlayState.hx##
| Method | Description |
|------------------|---------|
| packetRecieve (PSInstance,packetId,data) | No description provided :< |

##OfflineMenuState.hx##
| Method | Description |
|------------------|---------|
| chartOptions (PSInstance) | No description provided :< |
| extraKeys (PSInstance) | No description provided :< |
| select (PSInstance,sel) | No description provided :< |

##ChartingState.hx##

| 	public static var | playClaps:Bool  |
|  public function | new(?time:Float = 0) |
| 	public static var | lastPath:String |

##KeyBindMenu.hx##

|  public var | lastKey:String  |

##PauseSubState.hx##

| 	public function | new(x:Float, y:Float) |
| 	public function | countdown() |

##FlxSprTrail.hx##

| 	public function | applyTo(object:FlxSprite,?changeFrame:Bool = true) |
|  public function | new(parent:FlxSprite,?time:Float = 0,spriteStart:Int = 1,spriteAmount:Int = 2,spriteOffsetX:Float = 0,spriteOffsetY:Float = 0) |
| 	public function | generateSprites() |
|  public function | update(e:Float) |
| 	public function | addToBuffer(?index:Int = -1,?color:FlxColor = 0xFFFFFF) |
|  public function | copyScrollFactor() |
| 	public function | updateFrames(?color:FlxColor = 0xFFFFFFF,?changeFrame:Bool = true) |

##MainMenuState.hx##

|  public static function | handleError(?exception:haxe.Exception = null,?error:String = "An error occurred",?details:String="",?forced:Bool = true):Void |
|  public function | new(important:Bool = false) |
| 	public function | eventColors(date:Date) |

##QuickOptionsSubState.hx##

| 	public static function | getSetting(setting:String):Dynamic |
| 	public static function | setSetting(setting:String,value:Dynamic) |
| 	public function | new(?callback:() -> Void)
	 |

##PsychDropDown.hx##

| 	public function | new(X:Float = 0, Y:Float = 0, DataList:Array<StrNameLabel>, ?Callback:String->Void, ?Header:FlxUIDropDownHeader,			?DropPanel:FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?UIControlCallback:Bool->PsychDropDown->Void)	 |
| 	public var | background:FlxSprite |
| 	public function | new(Width:Int = 120, ?Background:FlxSprite, ?Text:FlxUIText, ?Button:FlxUISpriteButton)	 |
|  public function | destroy():Void	 |

##SickMenuState.hx##

| 	public static function | musicHandle(?isMainMenu:Bool = false,?_bg:FlxSprite = null,?recolor:Bool = false) |
| 	public function | get_supportMouse():Bool |

##TitleState.hx##

| 	public function | get_path() |
### StageInfo
| Type | Name |
|------------------|------|
### TitleState
 extends MusicBeatState
   
| Type | Name |
|------------------|------|
### FuckinNoDestCam
 extends FlxCamera  
| Type | Name |
|------------------|------|

##SearchMenuState.hx##

| 	public function | get_supportMouse():Bool |
| static public function | resetVars() |
| 	public static var | doReset:Bool  |
| 	public var | blackBorder:FlxSprite |
| 	public var | scrollBar:FlxSprite |
| 	public var | infoTextBorder:FlxSprite |

##TextBoxSubstate.hx##

### TextBoxSubstate
 extends MusicBeatSubState  
| Type | Name |
|------------------|------|

##DirectoryListing.hx##

|  public function | onTextInputFocus(object:Dynamic) |
|  public function | onTextInputUnfocus(object:Dynamic) |

##Options.hx##

| 	public function | new(catName:String, options:Array<Option>,?desc:String = "",?mod:Bool = false)
	 |
| 	public var | description(default,null):String  |
### DFJKOption
 extends Option
   
| Type | Name |
|------------------|------|
| 	public static var | playerEdit:Int  |
### GFOption
 extends Option
   
| Type | Name |
|------------------|------|
### OpponentOption
 extends Option
   
| Type | Name |
|------------------|------|
### GUIGapOption
 extends Option
   
| Type | Name |
|------------------|------|
### SelStageOption
 extends Option
   
| Type | Name |
|------------------|------|
### ReloadCharlist
 extends Option
   
| Type | Name |
|------------------|------|
### InputEngineOption
 extends Option
   
| Type | Name |
|------------------|------|
### NoteSelOption
 extends Option
   
| Type | Name |
|------------------|------|
### UnloadSongOption
 extends Option
   
| Type | Name |
|------------------|------|
### SongInfoOption
 extends Option
   
| Type | Name |
|------------------|------|
### FullscreenOption
 extends Option
   
| Type | Name |
|------------------|------|
### SelScriptOption
 extends Option
   
| Type | Name |
|------------------|------|
### IntOption
 extends Option  
| Type | Name |
|------------------|------|
### FloatOption
 extends Option  
| Type | Name |
|------------------|------|
### BoolOption
 extends Option  
| Type | Name |
|------------------|------|
### HCIntOption
 extends Option  
| Type | Name |
|------------------|------|
### HCFloatOption
 extends Option  
| Type | Name |
|------------------|------|
### HCBoolOption
 extends Option  
| Type | Name |
|------------------|------|
### BackTransOption
 extends Option
   
| Type | Name |
|------------------|------|
### BackgroundSizeOption
 extends Option
   
| Type | Name |
|------------------|------|
### VolumeOption
 extends Option
   
| Type | Name |
|------------------|------|
### EraseOption
 extends Option
   
| Type | Name |
|------------------|------|
### QuickOption
 extends Option  
| Type | Name |
|------------------|------|
| 	public function | new(name:String)
	 |

##Preloader.hx##

|  public function | new(MinDisplayTime:Float=3, ?AllowedURLs:Array<String>)      |

##CharSelection.hx##

### CharSelection
 extends SearchMenuState   
| Type | Name |
|------------------|------|

##MusicBeatSubstate.hx##

| 	public var | toggleVolKeys:Bool  |
| 	public function | onTextInputFocus(object:Dynamic) |
| 	public function | onTextInputUnfocus(object:Dynamic) |
| 	public function | stepHit():Void	 |
| 	public function | beatHit():Void	 |

##Highscore.hx##

| 	public static var | NORESULT:Array<Dynamic>  |
|  public static var | songScores:Map<String, Int>  |
| 	public static function | saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void	 |
| 	public static function | saveWeekScore(week:Dynamic = 1, score:Int = 0, ?diff:Int = 0):Void	 |
| 	public static function | setScore(song:String, score:Int,?Arr:Array<Dynamic>,?forced:Bool = false):Bool	 |
| 	public static function | formatSong(song:String, diff:Int):String	 |
| 	public static function | getScoreUnformatted(song:String):Int	 |
| 	public static function | getScore(song:String, diff:Int):Array<Dynamic>	 |
| 	public static function | getWeekScore(week:Dynamic, diff:Int):Int	 |
| 	public static function | save():Void  |
| 	public static function | load():Void  |

##ConvertScore.hx##

|  public static function | convertScore(noteDiff:Float):Int     |

##Character.hx##

| 	public function | getNamespacedName():String |
| 	public function | callInterp(func_name:String, args:Array<Dynamic>,?important:Bool = false):Dynamic  |
| 	public var | currentAnimationPriority:Int  |
| 	public function | playAnimAvailable(animList:Array<String>,forced:Bool = false,reversed:Bool = false,frame:Float = 0):Bool |
| 	public var | animName(get,set):String |
| 	public static var | BFJSON(default,null):String  |
| 	public static var | GFJSON(default,null)  |

##StageEditor.hx##

| 	public var | objects:Array<Dynamic>  |
| 	public function | updateObjectList() |

##SongHScripts.hx##

| 	public static var | scriptList:Map<String,String>  |

##DialogueBox.hx##

| 	public function | new(talkingRight:Bool = true, ?dialogueList:Array<String>) |

##Note.hx##

| 	public function | get_skipXAdjust() |
| 	public var | updateY:Bool  |
| 	public function | toJson() |
| 	public function | addAnimations() |
| 	public static var | noteAnims:Array<String>  |
| 	public function | new(?strumTime:Float = 0, ?_noteData:Int = 0, ?prevNote:Note, ?sustainNote:Bool = false, ?_inCharter:Bool = false,?_type:Dynamic = 0,?_rawNote:Array<Dynamic> = null,?playerNote:Bool = false)
	 |

##StrumArrow.hx##

|  public function | new(nid:Int = 0,?x:Float = 0,?y:Float = 0) |
| 	public function | changeSprite(?name:String = "default",?_frames:FlxAtlasFrames,?anim:String = "",?setFrames:Bool = true,path_:String = "mods/noteassets",?noteJSON:NoteAssetConfig) |
| 	public function | init() |
| 	public function | playAnim(name:String,?forced:Bool = true, ?Reversed:Bool = false, ?Frame:Int = 0) |
| 	public function | playStatic(?forced:Bool = false) |
| 	public function | press(?forced:Bool = false) |
| 	public function | confirm(?forced:Bool = false) |

##NoteSplash.hx##

|  public function | new()	 |
| 	public function | setupNoteSplash(?obj:FlxObject = null,?note:Int = 0)	 |

##GameOverState.hx##

| 	public function | new(x:Float, y:Float)	 |

##Conductor.hx##

| 	public static function | get_crochetSecs():Float |
| 	public static var | stepCrochet:Float  |
| 	public function | new()	 |
| 	public static function | recalculateTimings()	 |
| 	public static function | mapBPMChanges(?song:SwagSong)	 |
| 	public static function | changeBPM(newBpm:Float)	 |

##ChartRepoState.hx##

|  public function | create():Void	 |
|  public function | update(elapsed:Float) |

##RepoState.hx##

|  public static function | unzip(from:String,to:String):Void |
|  public function | create():Void	 |
|  public function | update(elapsed:Float) |

##HscriptUtils.hx##

| 	public static function | init()  |
| 	public static var | X     |
| static public function | areSameType(o:Dynamic,c:Dynamic):Bool |
| 	public var | isNew:Bool  |
| 	public static var | TRANSPARENT:FlxColor  |
### HscriptGlobals
| Type | Name |
|------------------|------|
### SEMath
| Type | Name |
|------------------|------|
### provides advanced methods on Strings. It is ideally used with   `using StringTools` and then acts as an [extension](https://haxe.org/manual/lf-static-extension.html)   to the `String` class.      If the first argument to any of the methods is null, the result is  unspecified. **/  // I hate inlines  class SEStringTools
| Type | Name |
|------------------|------|
### containing a set of functions for random generation.  */ class SERandom
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

##NoteAssets.hx##

| 	public static function | get_frames():FlxFramesCollection |
|  public var | name:String |
|  public function | genSplashes(?name_:String = "noteSplashes",?path_:String = "assets/shared/images/"):Void |

##EventNote.hx##

| ic public function | hit(?charID:Int = 0,note:EventNote) |
| 	public static function | applyEvent(note:Dynamic) |
| 	public function | destroy() |
| 	public function | new(strumTime:Float,?_type:Dynamic = 0,?rawNote:Array<Dynamic> = null) |
| 	public static function | fromNote(note:Note):EventNote |

##FinishSubState.hx##

| 	public function | new(x:Float, y:Float,?won = true,?error:String = "",force:Bool = false)
	 |
| 	public function | saveScore(forced:Bool = false):Bool |
|  public function | getScore(forced:Bool = false):Int |
| 	public function | finishNew(?name:String = "") |

##FreeplayState.hx##

| 	public static var | lastSong:String  |
| 	public var | songName:String  |
| 	public function | new(song:String, week:Int, songCharacter:String)	 |

##ArrowSelection.hx##

| 	public function | updateArrowDisplay() |

##CharacterJson.hx##

| static public function | import(json:String) |
| 	public function | fromJSON(json:Dynamic) |
| 	public function | new() |

##Song.hx##

| 	public function | new(name:String, pos:Float, value:Float, type:String)	 |
| 	public function | new(song, notes, bpm)	 |
|  public static function | getEmptySong():SwagSong |
| 	public static function | getEmptySongJSON():String |
| 	public static function | parseJSONshit(rawJson:String,charting:Bool = false):SwagSong	 |

##OutdatedSubState.hx##

| 	public static var | needVer:String  |
| 	public static var | currChanges:String  |

##ScriptMusicBeatState.hx##

| 	public function | callSingleInterp(func_name:String, args:Array<Dynamic>,id:String,?_interp:Dynamic = null):Dynamic |
| 	public var | scriptPaths  |
| 	public function | loadScript(v:String,?path:String = "mods/scripts/",?nameSpace:String="global",?brtool:HSBrTools = null) |
|  public function | loadScripts(?enableScripts:Bool = false,?enableCallbacks:Bool = false,?force:Bool = false) |
| 	public function | softReloadState(?showWarning:Bool = true) |
|  public function | new() |
|  public function | create() |
|  public function | draw() |
|  public function | destroy() |
|  public function | beatHit() |
|  public function | stepHit() |
|  public function | update(e:Float) |
|  public function | openSubState(s:FlxSubState) |
|  public function | add(obj:FlxBasic) |
|  public function | remove(Object:FlxBasic, Splice:Bool = false) |
|  public function | switchTo(s:FlxState) |

##HelpScreen.hx##

### HelpScreen
 extends FlxSubState  
| Type | Name |
|------------------|------|

##HelperFunctions.hx##

|  public static function | truncateFloat( number : Float, precision : Int): Float  |

##ImportMod.hx##

| 	public function | new (folder:String,name:String,?importExisting:Bool = false)	 |

##Snd.hx##

| 	public function | poolBack() |
| 	public static var | EMPTY_STRING  |
### ChannelLowLevel
 extends Channel  
| Type | Name |
|------------------|------|
### Sound
| Type | Name |
|------------------|------|
### SoundLowLevel
 extends Sound  
| Type | Name |
|------------------|------|
### SoundEvent
 extends Sound  
| Type | Name |
|------------------|------|
### Snd
| Type | Name |
|------------------|------|
| 	public function | new( snd : Sound, ?name:String )  |
| 	public var | muted : Bool  |
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

##MultiMenuState.hx##
| Method | Description |
|------------------|---------|
| addListing (PSInstance,name,i) | No description provided :< |
| addListingAfter (PSInstance,controlLabel,name,i) | No description provided :< |
| addCategory (PSInstance,name,i) | No description provided :< |
| addCategoryAfter (PSInstance,controlLabel,name,i) | No description provided :< |
| reloadList (PSInstance,reload,search,query) | No description provided :< |

##Main.hx##

| 	public static function | main():Void	 |
### FlxGameEnhanced
 extends FlxGame  
| Type | Name |
|------------------|------|
| 	public var | blockUpdate:Bool  |
| 	public var | blockDraw:Bool  |
| 	public var | blockEnterFrame:Bool  |
| 	public var | funniLoad:Bool  |

##HSBrTools.hx##

| 	public function | new(_path:String,?id:String = "") |
| 	public function | getSetting(setting:String,?defValue:Dynamic = false):Dynamic |
| 	public function | getPath(?str:String = "") |
| 	public function | loadFlxSprite(x:Float,y:Float,pngPath:String):FlxSprite |
| 	public function | loadGraphic(pngPath:String):FlxGraphic |
| 	public function | loadSparrowFrames(pngPath:String):FlxAtlasFrames |
| 	public function | loadAtlasSprite(x:Int,y:Int,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24):FlxSprite |
| 	public function | loadSparrowSprite(x:Int,y:Int,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24):FlxSprite |
| 	public function | reset() |
| 	public function | exists(textPath:String):Bool |
| 	public function | loadText(textPath:String):String |
| 	public function | loadXML(textPath:String):String |
| 	public function | loadShader(textPath:String,?glslVersion:Dynamic = 120)#if(FLXRUNTIMESHADER) :Null<FlxRuntimeShader> #end |
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

##SndTV.hx##

| 	public var | fps 				 |
| 	public function | new()  |
| 	public var | pool : hxd.Stack<TweenV>  |
| 	public function | killWithoutCallbacks(parent:Snd)  |
| 	public function | terminate(parent:Snd)  |
| 	public function | forceTerminateTween(t:TweenV)  |
| 	public function | terminateTween(t:TweenV, ?fl_allowLoop=false)  |
| 	public function | terminateAll()  |
| 	public function | update(?tmod = 1.0)  |

##BoneCharacter.hx##

|  public function | new(x:Float, y:Float, ?character:String = "lonely", ?isPlayer:Bool = false,?char_type:Int = 0,?preview:Bool = false) // CharTypes: 0=BF 1=Dad 2=GF// 	 |
### BCAnim
| Type | Name |
|------------------|------|