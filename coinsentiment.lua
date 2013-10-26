require "irc"
local sleep = require "socket".sleep
local http = require ("socket.http")

-- Parameters
local debug = false
local test = false
local scoreModifier = 0
local botNick = "murkmans"

-- Utils
function dateAndTime()
	local time = os.date("*t")
	local t = string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
	local d = time.day.."/"..time.month
	return d, t
end

function currentPrice()
	local priceForOneGBP = http.request("http://blockchain.info/tobtc?currency=GBP&value=1")
	return 1/priceForOneGBP
end

-- Sentiment analysis
local moods = dofile("moods.lua")
local total = 0
function scoreText(text, channel)
	local lowercaseText = string.lower(text)
	local date, time = dateAndTime()
	local dateTime = date.." "..time

	for sentiment, score in pairs(moods) do
		local found = string.find(string.gsub(lowercaseText,"(.*)"," %1 "), "[^%a]"..sentiment.."[^%a]")
		if found ~= nil then
			total = total + score + scoreModifier
			local json = string.format('{"c":[{"v":"%s"}, {"v":%i}, {"v":%f} ]},', dateTime, total, currentPrice())
			print(time.." "..channel..": Found ..'"..sentiment.."' in '"..text.."'")
			os.execute("echo \'"..json.."\' >> /var/www/coin/data.json")
		end
	end
end

if test ~= true then
	-- Connect to server and setup callbacks 
	local s = irc.new{nick = botNick}
	s:hook("OnChat", function(user, channel, message)
		scoreText(message, channel)
	end)
	s:hook("OnKick", function(channel, nick, kicker, reason)
		if nick == botNick then
			print ("*** KICKED from channel: "..channel.." Reason: "..reason)
		end
	end)
	s:hook("OnJoin", function(user, channel)
		if user.nick == botNick then 
			print ("JOINED channel: "..channel)
		end
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
else -- test
	scoreText("wonlost", "channel")
	scoreText("Won. lost. Stegosaurus.", "channel")
	scoreText("Fantasticfantastic Fantastic", "channel")
end
