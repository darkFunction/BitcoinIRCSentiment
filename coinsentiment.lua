require "irc"
local sleep = require "socket".sleep
local http = require ("socket.http")

function lastSentimentIndex()
	return 0	
end

-- Parameters
local debug = false
local test = false
local scoreModifier = 0
local botNick = "murkmans"
local moods = dofile("moods.lua")
local channels = dofile("channels.lua")
local sentimentIndex = lastSentimentIndex()

-- Utils
function dateAndTime()
	local time = os.date("*t")
	local t = string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
	local d = time.day.."/"..time.month
	return d, t
end

local lastPrice = 0
function currentPrice()
	local priceForOneGBP = http.request("http://blockchain.info/tobtc?currency=GBP&value=1")
	--if type(priceForOneGBP) == "number" then
		lastPrice = 1/priceForOneGBP
	--end
	return lastPrice
end

-- Sentiment analysis
function scoreText(text, channel)
	local lowercaseText = string.lower(text)
	for sentiment, score in pairs(moods) do
		local found = string.find(string.gsub(lowercaseText,"(.*)"," %1 "), "[^%a]"..sentiment.."[^%a]")
		if found ~= nil then
			sentimentIndex = sentimentIndex + score + scoreModifier
			print(channel..": Found ..'"..sentiment.."' in '"..text.."'")
		end
	end
end

function updateData()
	local date, time = dateAndTime()
	local dateTime = date.." "..time
	local json = string.format('{"c":[{"v":"%s"}, {"v":%i}, {"v":%f} ]},', dateTime, sentimentIndex, currentPrice())
	os.execute("echo \'"..json.."\' >> /var/www/coin/data.json")
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
	for _,channel in ipairs(channels) do
		s:join(channel)
		sleep(0.3)
	end
	
	-- Run loop
	local seconds = 0
	while true do
		sleep(1)
		s:think()
		seconds = seconds + 1
		if seconds >= 60 then 
			seconds = 0
			updateData()
		end
	end
else -- test
	scoreText("wonlost", "channel")
	scoreText("Won. lost. Stegosaurus.", "channel")
	scoreText("Fantasticfantastic Fantastic", "channel")
end
