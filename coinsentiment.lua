require "irc"
require "SentimentAnalyser"
require "BitcoinPrice"

local sleep = require "socket".sleep
local http = require ("socket.http")

function lastSentimentIndex()
	return 0	
end

-- Parameters
local debug = false
local test = false
local scoreModifier = 0
local botNick = "darkFunc"
local channels = dofile("channels.lua")
local sentimentIndex = lastSentimentIndex()
local updateInterval = 15 -- should be > 10 (if using mtgox ticker)

-- Utils
function dateAndTime()
	local time = os.date("*t")
	local t = string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
	local d = time.day.."/"..time.month
	return d, t
end

function currentPrice()
	return BitcoinPrice.getMtGoxPrice()
end

-- Sentiment analysis
function scoreText(text, channel)
	local score = SentimentAnalyser.process(text)
	if score ~= 0 then
		sentimentIndex = sentimentIndex + score
		print(channel..": ("..score..") "..text)
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
		if seconds >= updateInterval then 
			seconds = 0
			updateData()
		end
	end
else -- test
	scoreText("wonlost", "channel")
	scoreText("Won. lost. Stegosaurus.", "channel")
	scoreText("Fantasticfantastic Fantastic", "channel")
end
