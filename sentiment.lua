--[[
NEGATIVE
	NOT_GOOD
		@NOTGOOD [#POSITIVE_WORDS AFTER #NEGATIONS /S 3] (1)
	REAL_BAD
		@REALBAD [#NEGATIVE_WORDS NOT AFTER #NEGATIONS /S 3] (1)
POSITIVE
	NOT_BAD
		@NOTBAD [#NEGATIVE_WORDS AFTER #NEGATIONS /S 3] (1)
	REAL_GOOD
		@REALGOOD [#POSITIVE_WORDS NOT AFTER #NEGATIONS /S 3] (1)
--]]

local negativeWords = dofile("words_negative.lua")
local positiveWords = dofile("words_positive.lua")
local negationWords = dofile("words_negations.lua")

SentimentAnalyser = {}

local function splitString(text) 
	local words = {}
	for word in text:gmatch("[a-zA-Z']+") do 
		table.insert(words, word) 
	end
	return words
end

local function isWordInList(word, wordList)
	for _, w in pairs(wordList) do	
		local found = string.find(string.upper(word), w)	
		if found then return true end
	end
	return false
end

function SentimentAnalyser.process(text) 
	local words = splitString(text)
	local wordTypes = {}
	for index, word in pairs(words) do
		if isWordInList(word, negativeWords) then wordTypes[index] = "negative" end
		if isWordInList(word, positiveWords) then wordTypes[index] = "positive" end
		if isWordInList(word, negationWords) then wordTypes[index] = "negation" end
	end
end
