-- Clean Game Listeners  --
-- Game event listeners for DavidSandevistanPlus --
--[[
1. Call :Init()
2. Call :AddCallback() for each call back you want to add; with one or many fancy self/tag/controller function(s).
]]--
-- make sure every call gets a new instance

local gameListeners = {
	 debug = false
	,debug_tag = ''
}
-- Init is the first thing to do
gameListeners.Init = function(self,isdebug,debug_tag)
	self.debug = isdebug
	self.debug_tag = debug_tag
end
-- Call this to create all your call back functions
-- After:false/true/nil=>Observe/ObserveAfter/Override
gameListeners.AddCallback = function(self,component_name,event_name,fn_callback,after)
	-- Register them all with the game engine
	if after == true then
		ObserveAfter(component_name, event_name, fn_callback)
	elseif after == false then
		Observe(component_name, event_name, fn_callback)
	else -- nil
		Override(component_name, event_name, fn_callback)
	end
	if self.debug then print(tostring(self.debug_tag)..'>gameListeners.Callback("'..component_name..'_'..event_name..'")') end
end

return gameListeners
