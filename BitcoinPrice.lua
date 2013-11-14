local http = require("socket.http")
local json = require("json")

local currency = "GBP"
local mtGoxTicker = "https://data.mtgox.com/api/2/BTC"..currency.."/money/ticker"
local blockChainTicker = "http://blockchain.info/tobtc?currency="..currency.."&value=1"
local bitcoinAverageTicker = "http://api.bitcoinaverage.com/ticker/"..currency
local lastPrice = 0

BitcoinPrice = {}

function BitcoinPrice.getMtGoxPrice()
	local jsonData = http.request(mtGoxTicker)
	if jsonData ~= nil then
		local data = json.decode(jsonData)
		if data["result"] == "success" then 
			lastPrice = data["data"]["last"]["value"]
		end
	end
	return lastPrice 
end

function BitcoinPrice.getBlockChainPrice()
	local response = http.request(blockChainTicker)
	if response ~= nil then
		local price = tonumber(response)
		lastPrice = 1/price 
	end
	return lastPrice
end

function BitcoinPrice.getBitcoinAveragePrice() 
	local jsonData = http.request(bitcoinAverageTicker)
	if jsonData ~= nil then
		local data = json.decode(jsonData)
		lastPrice = data["last"]
	end
	return lastPrice
end

