
setmetatable(_G,{
	__index = function(this,key)
		return rawget(this,key) or getGlobalValue(key)
	end,
})
local OBJECTTBL = {
	__index = function(self,key)
		return rawget(self,key) or getProperty(("%s.%s"):format(self.NAME,key))
	end,
	__newindex = function(self,key,value)
		return setProperty(("%s.%s"):format(self.NAME,key),value)
	end,
	__call = function(self,func,...)
		if(func ~= null) then
			return callObjectFunction(rawget(self,"NAME"),func,{...})
		end
		return rawget(self,"NAME")
	end
}
do
	local dumpCache = function(self) self.CACHE = {} end
	local CACHEOBJECTTBL = {
		__index = function(self,key)
			if(key == "dump")then
				rawset(self,"",{})
				return true;
			end
			local ret = rawget(self,key) or rawget(rawget(self,"CACHE"),key)
			if ret then return ret end
			local ret = getProperty(("%s.%s"):format(self.NAME,key))
			rawset(key,value)
		end,
		__newindex = function(self,key,value)
			
			if(key == "CACHE") then return rawset(self,key,value) end
			rawset(rawget(self,"CACHE"),key,value)
			return setProperty(("%s.%s"):format(self.NAME,key),value)
		end,
		__call = function(self,func,...)
			if(func ~= null) then
				return callObjectFunction(rawget(self,"NAME"),func,{...})
			end
			return rawget(self,"NAME")
		end
	}
	function toLuaObj(name) return setmetatable({NAME=name},OBJECTTBL) end
	function toCachableLuaObj(name) return setmetatable({NAME=name},CACHEOBJECTTBL) end
end
