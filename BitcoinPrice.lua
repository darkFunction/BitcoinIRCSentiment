local http = require("socket.http")
local json = require("json")

local currency = "GBP"
local mtGoxTicker = "https://data.mtgox.com/api/2/BTC"..currency.."/money/ticker"
local blockChainTicker = "http://blockchain.info/tobtc?currency="..currency.."&value=1"

BitcoinPrice = {}

function BitcoinPrice.getMtGoxPrice()
	local jsonData = http.request(mtGoxTicker)
	local data = json.decode(jsonData)

	if data["result"] == "success" then 
		return data["data"]["buy"]["value"]
	end
	return nil
end

function BitcoinPrice.getBlockChainPrice()
	local price = tonumber(http.request(blockChainTicker))
	return 1/price 
end

