require "irc"
local sleep = require "socket".sleep
local debug= false
local test = true
local scoreModifier = 0

-- Sentiment analysis
local moods = dofile("moods.lua")
local total = 0
function scoreText(text, channel)
	local lowercaseText = string.lower(text)
	local time = os.date("*t")
	local formattedTime = string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
	local formattedDate = time.day.."/"..time.month
	local dateAndTime = formattedDate .. " " .. formattedTime
	for sentiment, score in pairs(moods) do
		local found = string.find(string.gsub(lowercaseText,"(.*)"," %1 "), "[^%a]"..sentiment.."[^%a]")
		if found ~= nil then
			total = total + score + scoreModifier
			local json = string.format('{"c":[{"v":"%s"}, {"v":%i}]},', dateAndTime, total)
			print(formattedTime.." "..channel..": Found ..'"..sentiment.."' in '"..text.."'")
			os.execute("echo \'"..json.."\' >> /var/www/coin/data.json")
		end
	end
end

if test == true then
	scoreText("wonlost", "channel")
	scoreText("Won. lost. Stegosaurus.", "channel")
	scoreText("Fantasticfantastic Fantastic", "channel")
else
	-- Connect to server and setup callbacks 
	local s = irc.new{nick = "darkFun"}
	s:hook("OnChat", function(user, channel, message)
		scoreText(message, channel)
	end)
	if debug then
		function debugHook(line)
		    print(line)
		end
		s:hook("OnRaw", debugHook)
		s:hook("OnSend", debugHook)
	end
	s:connect("chat.freenode.net")
	
	-- Join channels
	local channels = dofile("channels.lua")
	for _,channel in ipairs(channels) do
		s:join(channel)
		sleep(0.3)
	end
	
	-- Run loop
	while true do
		s:think()
		sleep(0.5)
	end
end
