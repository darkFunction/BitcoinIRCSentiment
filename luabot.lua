require "irc"
require "SentimentAnalyser"
require "BitcoinPrice"
local sleep = require "socket".sleep

local serverAddress = "irc.underworld.no"
local name = "murkmans"
local trigger = name
local s = irc.new{nick = name}
local debug = false 

s:hook("OnChat", function(user, channel, message)
	local ignoreJamaal = string.find(message, "jamaal") 
	if ignoreJamaal then return end

	local priceget = string.find(message, "!btc")
	if priceget ~= nil then
		local price = BitcoinPrice.getMtGoxPrice()
		s:sendChat(channel, "btc price: "..price)		
	end

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

s:connect(serverAddress)
s:join("#perthroad")

while true do
	s:think()
	sleep(0.5)
end

