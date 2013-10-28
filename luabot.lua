require "irc"
require "SentimentAnalyser"

local sleep = require "socket".sleep
local trigger = "murkmans"

local s = irc.new{nick = "murkmans"}

s:hook("OnChat", function(user, channel, message)
	local found = string.find(message, trigger)	
	if found ~= nil then
		message = string.gsub(message, trigger, "")
		s:sendChat(channel, SentimentAnalyser.debugText(message))		
	end
end)

--function debugHook(line)
--    print(line)
--end
--s:hook("OnRaw", debugHook)
--s:hook("OnSend", debugHook)

s:connect("irc.efnet.org")
s:join("#perthroad")

while true do
	s:think()
	sleep(0.5)
end

