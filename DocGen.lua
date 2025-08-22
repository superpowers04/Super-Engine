local f = string.format
--[[ TODO ADD COMMENTS TO ALL CALL INTERPS]]
local patt = '%s([^%s]-)callInterp%(["\']([^\n]-)["\'],%[(.-)%]%);(.-)\n' 
print("Test patt",string.match(' PlayState.instance.callInterp("setupNoteSplashAfter",[this])',patt))

local functions = {[[
# This file is just a compilation of every `callInterp` function call
# In songs, PlayState will pass itself as the first argument for backwards compatibility reasons
# Proper UP TO DATE documentation IS planned. Just bear with me for now
#LINE | CALL]]}
local findOp,findContents = io.popen('find ./source/ -type "f" | grep "\\.hx"'),nil
findContents = findOp:read('*a')
for i in findContents:gmatch('[^\n]+') do
	functions[#functions+1] = ("# %s"):format(i:sub(10))
	local file = io.open(i,'r')
	local f = 0
	local lineCount = 0
	for line in file:read('*a'):gmatch('[^\n]+') do
		lineCount = lineCount+1
		-- for i in line:gmatch('%s[^%s]-(callInterp%(["\'][^\n]-["\'],%[(.-)%]%);.-)') do
		local s= line:find('callInterp%(%s-[\'"]') 
		if(s and not line:find('function callInterp')) then
			f = f + 1
			functions[#functions+1] = ("%6i: %s"):format(lineCount,line:sub(s))
		end
		-- end

	end
	if(f == 0) then functions[#functions]=nil end
	file:close()

end

local output = table.concat(functions, "\n")
f = io.open("example_mods/autogen_docs.md","w")
f:write(output);
f:close();