local positiveWords = dofile("words_positive.lua")
local negativeWords = dofile("words_negative.lua")
local positivePhrases = dofile("phrases_positive.lua")
local negativePhrases = dofile("phrases_negative.lua")
local negationWords = dofile("words_negations.lua")

local GOOD = 1
local BAD = -1
local NOT_GOOD = -1
local NOT_BAD = 1

SentimentAnalyser = {}

local function spacesToUnderscores(text) 
	return string.gsub(text, " ", "_")
end

local function underscoresToSpaces(text) 
	return string.gsub(text, "_", " ")
end

local function markPhrases(text, phraseList)
	for _, phrase in pairs(phraseList) do 
		local s, e = string.find(string.upper(text), phrase)
		if s ~= nil then 
			local foundPhrase = string.sub(text, s, e)
			text = string.gsub(text, foundPhrase, spacesToUnderscores(foundPhrase))
		end
	end
	return text
end

local function splitString(text) 
	local words = {}
	for word in text:gmatch("[a-zA-Z'_]+") do 
		table.insert(words, word) 
	end
	return words
end

local function isWordInList(word, wordList)
	for _, w in pairs(wordList) do	
		local s, e = string.find(string.upper(word), w)	
		if s==1 and e==string.len(word) then return true end
	end
	return false
end

function SentimentAnalyser.process(text) 
	text = markPhrases(text, positivePhrases)
	text = markPhrases(text, negativePhrases)

	local words = splitString(text)
	local wordTypes = {}
	for index, word in pairs(words) do
		if isWordInList(word, negativeWords) or isWordInList(underscoresToSpaces(word), negativePhrases) then wordTypes[index] = "negative" end
		if isWordInList(word, positiveWords) or isWordInList(underscoresToSpaces(word), positivePhrases) then wordTypes[index] = "positive" end
		if isWordInList(word, negationWords) then wordTypes[index] = "negation" end
	end

	local totalScore = 0
	for i=1, #words do
		local positive, negative, negated, score = false, false, false, 0
		if wordTypes[i] == "positive" then positive = true 
		elseif wordTypes[i] == "negative" then negative = true end
		if positive or negative then
			if wordTypes[i-1] == "negation" or wordTypes[i-2] == "negation" then
				negated = true
			end
			if positive then
				if negated then score = NOT_GOOD
				else score = GOOD end		   
			else
				if negated then score = NOT_BAD  
				else score = BAD end		   
			end
		end
		totalScore = totalScore + score

		--print(words[i], score, wordTypes[i]) 
	end

	return totalScore, words, wordTypes
end

function SentimentAnalyser.debugText(text)
	local score, words, wordTypes = SentimentAnalyser.process(text)
	local symbols = { negative = "-", positive = "+", negation = "!" }
	local output = score..":"
	for i, word in ipairs(words) do
		if wordTypes[i] == nil then 
			output = string.format(output.." "..word)
		else
			output = string.format(output.." "..word.."["..symbols[wordTypes[i]].."]")
		end
	end
	return output
end

if arg[1] ~= nil then
	print(SentimentAnalyser.debugText(arg[1]))
end

