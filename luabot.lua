require "irc"
require "SentimentAnalyser"
local sleep = require "socket".sleep

local name = "murkmans"
local trigger = name
local s = irc.new{nick = name}
local debug = true

s:hook("OnChat", function(user, channel, message)
	local found = string.find(message, trigger)	
	if found ~= nil then
		message = string.gsub(message, trigger, "")
		s:sendChat(channel, SentimentAnalyser.debugText(message))		
	end
end)

if debug == true then
	function debugHook(line)
   	 print(line)
	end
	s:hook("OnRaw", debugHook)
	s:hook("OnSend", debugHook)
end

s:connect("irc.mzima.net")
s:join("#perthroad")

while true do
	s:think()
	sleep(0.5)
end

