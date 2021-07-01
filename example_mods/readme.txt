Characters work like FNF Multi, Check BF-faceanim for an example. You can also make custom animations using IfStates
Heres an example that adds Garcellos "tight bars, little man" animation into Release:
{
	"anim": "garTightBars",
	"name": "garcello coolguy",
	"fps": 15,
	"loop": false,
	"indices": [],
	"oneshot":true,"":"Allows your animation to override all other animations, loop will be forced of if this is true",
	"ifstate":{
		"variable":"curStep","":"The variable to check in PlayState.hx, curStep and curBeat might be all you need though",
		"type":"equals","":"valid types are 'equal', 'more','less' and 'contains', if you use contains then the value should be a list of values, like [480,838,521], etc. otherwise the value should always be the same type as the variable",
		"value":838,"":"The value to check variable against, if type is contains, then this should be a list. Otherwise use the same type as the variable in the game",
		"check":1,"":"1 = curStep, 0 = curBeat. this has to be the same as variable if you use curStep or curBeat, otherwise you should use the one that plays your animation at the most accurate time"
	},
	"":"If the below requirements aren't met, the animation won't be processed. Useful for animations that are locked to a specific stage or song, These are not required",
	"song":"release","":"The song to play the animation on",
	"char_side":1,"":"Only play on a specific side, 0 = BF, 1 = Dad, 2 = GF"
}
You can find this example on the mod repo under GARCELLO DEAD