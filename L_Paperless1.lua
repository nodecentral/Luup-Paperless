module("L_Paperless1", package.seeall)

--local url = require "socket.url"
local http = require "socket.http"
local https = require "ssl.https"
local json = require "dkjson"
local mime = require "mime"

local ITEM_SID = "urn:nodecentral-net:serviceId:Paperless1"
local PV = "0.1" -- plugin version number

local function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then 
				k = '"'..k..'"' 
			end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

-- Trace Function, with debug level
local function log( lul_device, msg, loglevel)
	local dbg = 0 
	dbg = luup.variable_get("urn:nodecentral-net:serviceId:Paperless1", "Debug", lul_device) or 0
	--if ( tonumber(dbg) >=  tonumber(loglevel) ) then
	--luup.log( "PAPER: [" .. tostring(loglevel) .. ":" .. tostring(dbg) .. "]" .. " - " .. (msg or "nil"))
	luup.log( "PAPER: " .. (msg or "nil"))
   -- end 
end

-- Read Module variables
local function readSettings(lul_device)
	--log(lul_device, "Configuring Plugin with defaults where needed", 1)
  data = {}
  data.status 			= readVariableOrInit(lul_device,ITEM_SID,"Status", "Loading...")
  data.ipport	 		= readVariableOrInit(lul_device,ITEM_SID,"IpPort","xxx.xxx.xxx.xxx:xxxx")
  data.username			= readVariableOrInit(lul_device,ITEM_SID,"Username", "xxxxxxxxxx")
  data.password			= readVariableOrInit(lul_device,ITEM_SID,"Password", "xxxxxxxxxx")
  
  data.doccount 		= readVariableOrInit(lul_device,ITEM_SID,"DocumentCount", 0)
  data.tagcount			= readVariableOrInit(lul_device,ITEM_SID,"TagCount", 0 )
  data.doctypecount 	= readVariableOrInit(lul_device,ITEM_SID,"DocumentTypeCount", 0 )
  data.correscount	 	= readVariableOrInit(lul_device,ITEM_SID,"CorrespondentCount", 0 )
  
  --data.doctypenames		= readVariableOrInit(lul_device,ITEM_SID,"DocumentTypeNames", 0 )
  --data.Paperlesscount 	= readVariableOrInit(lul_device,ITEM_SID,"PaperlessCount", 0 )
  
  data.lastcreated 		= readVariableOrInit(lul_device,ITEM_SID,"LastCreated", os.time())
  data.lastadded  		= readVariableOrInit(lul_device,ITEM_SID,"LastAdded", os.time())
  
  data.lastdocadded 	= readVariableOrInit(lul_device,ITEM_SID,"LastDocumentAdded", "Title")
  
  data.lastdocupdated 	= readVariableOrInit(lul_device,ITEM_SID,"LastDocCountTaken", 0)
  data.lasttagupdated 	= readVariableOrInit(lul_device,ITEM_SID,"LastTagCountTaken", 0)
  data.lastcorupdated 	= readVariableOrInit(lul_device,ITEM_SID,"LastCorresCountTaken", 0)
  data.lasttypeupdated 	= readVariableOrInit(lul_device,ITEM_SID,"LastTypeCountTaken", 0)
  data.debug 			= readVariableOrInit(lul_device,ITEM_SID,"Debug", 0)
  data.icon 			= readVariableOrInit(lul_device,ITEM_SID,"Icon", 0)
  log(lul_device, "Configuration check completed ...", 1)
  return data
end

-- Write variables
local function writeVariable(lul_device,devicetype, name, value)
	luup.variable_set(devicetype,name,value,lul_device)
end

-- Read and/or Init variables
function readVariableOrInit(lul_device, devicetype, name, defaultValue)
	local var = luup.variable_get(devicetype, name, lul_device)
	if (var == nil) then
		var = defaultValue
		luup.variable_set(devicetype,name,var,lul_device)
		log(lul_device, "Setting default for " .. name .. " => " .. var, 1 )
	end
	return var
end

local function paperlessAPI(lul_device, type, variable ) 
	
	local user = data.username
	local pass = data.password
	local ipport = data.ipport
	
	--log(lul_device, "http://"..ipport.."/api/"..type.."/ | Basic " .. (mime.b64(user ..":" .. pass)), 1)
	--log(lul_device, "username = ["..user.."] password = [" ..pass.."]", 1)

	if (user == "xxxxxxxxxx" or pass == "xxxxxxxxxx" or ipport == "xxx.xxx.xxx.xxx:xxxx") then
		log(lul_device, "username, password and/or ip have not been updated...", 1)
		writeVariable(lul_device, ITEM_SID, "Status", "username, password and/or ip need updating...")
		writeVariable(lul_device, ITEM_SID, "Icon", 0)
		return error
	end
		
	local response_body = {}
	local ok, statusCode, headers, statusText = http.request{
		url = 		"http://"..ipport.."/api/"..type.."/",
		--url = 		"http://192.168.102.134:8777/api/documents/",
	    method = 	"GET",
	    headers = 	{
					["Authorization"] = "Basic " .. (mime.b64(user ..":" .. pass)),
					},
		sink = 		ltn12.sink.table(response_body)
	}
	-- 1     200     table: 0x1b4dd08     HTTP/1.1 200 OK
	
	if (tostring(statusCode) == "200") then
		log(lul_device, "paperlessAPI statusCode = ["..statusCode.."]", 1)
		writeVariable(lul_device, ITEM_SID, "Icon", 1)
		writeVariable(lul_device, ITEM_SID, "Status", "Paperless "..type.." Request was successful...")
		return response_body
		--local answer = json.decode(table.concat(response_body))
		--luup.variable_set(ITEM_SID, "DocCount", answer.count, lul_device)
		--writeVariable(lul_device, ITEM_SID, variable, answer.count)
	else
		log(lul_device, "Connection Error: ["..tostring(ok).." | "..tostring(statusCode).." | "..tostring(statusText).." | "..tostring(headers).." | "..table.concat(response_body).."]", 1)
		writeVariable(lul_device, ITEM_SID, "Status", "Connection Error: ["..tostring(ok).." | "..tostring(statusCode).." | "..tostring(statusText).."]" )
		log(lul_device, "Paperless-ngx "..type.." NOT UPDATED", 1)
		writeVariable(lul_device, ITEM_SID, "Icon", 0)
		writeVariable(lul_device, ITEM_SID, "Status", "Paperless "..type.." Request was unsuccessful...")
		return error
	end
end

function NC_CallPaperlessAPI(args) 
	log(lul_device, "NC_CallPaperlessAPI function Called with = " ..tostring(args), 1)
	
	--http://192.168.102.134:8777/api/documents/?ordering=-id
	local function split (inputstr, sep)
		if sep == nil then sep = "%s" end
		local t={}
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, str) end
		return t
	end

	local list = split(args, ",")
    local lul_device = tonumber(list[1])
    local call_type = tostring(list[2])
	
	if call_type == "Documents" then
		log(lul_device, "Documents Called !", 1)
		local answer = json.decode(table.concat(paperlessAPI(lul_device, "documents/?ordering=-id", "DocumentCount")))
		writeVariable(lul_device, ITEM_SID, "DocumentCount", answer.count)
		writeVariable(lul_device, ITEM_SID, "LastDocCountTaken", os.time())
		log(lul_device, "Document Count = ["..answer.count, answer.results[1].id, answer.results[1].title, 1)
		writeVariable(lul_device, ITEM_SID, "LastDocumentAdded", "["..answer.results[1].id.."] = ".. answer.results[1].title)
		log(lul_device, "Paperless-ngx Document Count UPDATED", 1)
		luup.call_delay( "NC_CallPaperlessAPI", 1800, lul_device..",Documents")
		
	elseif call_type == "Tags" then
		log(lul_device, "Tags Called !", 1)
		local answer = json.decode(table.concat(paperlessAPI(lul_device, "tags", "TagCount")))
		writeVariable(lul_device, ITEM_SID, "TagCount", answer.count)
		writeVariable(lul_device, ITEM_SID, "LastTagCountTaken", os.time())
		log(lul_device, "Paperless-ngx Tag Count UPDATED", 1)
		luup.call_delay( "NC_CallPaperlessAPI", 1800, lul_device..",Tags")
		
	elseif call_type == "Correspondent" then
		log(lul_device, "Correspondent Called !", 1)
		local answer = json.decode(table.concat(paperlessAPI(lul_device, "correspondents", "CorrespondentCount")))
		writeVariable(lul_device, ITEM_SID, "CorrespondentCount", answer.count)
		writeVariable(lul_device, ITEM_SID, "LastCorresCountTaken", os.time())
		log(lul_device, "Paperless-ngx Correspondent Count UPDATED", 1)
		luup.call_delay( "NC_CallPaperlessAPI", 1800, lul_device..",Correspondent")
		
	elseif call_type == "DocumentType" then
		log(lul_device, "DocumentType Called !", 1)
		local answer = json.decode(table.concat(paperlessAPI(lul_device, "document_types", "DocumentTypeCount")))
		writeVariable(lul_device, ITEM_SID, "DocumentTypeCount", answer.count)
		writeVariable(lul_device, ITEM_SID, "LastTypeCountTaken", os.time())
		log(lul_device, "Paperless-ngx Document Type Count UPDATED", 1)
		luup.call_delay( "NC_CallPaperlessAPI", 1800, lul_device..",DocumentType")
	
	else 
		log(lul_device, "ERROR Incorrect API Call Made !", 1)
		writeVariable(lul_device, ITEM_SID, "Status", "ERROR Incorrect API Call Made !...")
		return false
	end
	
	writeVariable(lul_device, ITEM_SID, "Status", "Paperless-ngx Counts UPDATED...")
	
end

local function InitiatePaperless(lul_device)
	log(lul_device, "Registering luup.call_delays = ", 1)
	luup.call_delay( "NC_CallPaperlessAPI", 5, lul_device..",Documents")
	luup.call_delay( "NC_CallPaperlessAPI", 65, lul_device..",Tags")
	luup.call_delay( "NC_CallPaperlessAPI", 165, lul_device..",Correspondent")
	luup.call_delay( "NC_CallPaperlessAPI", 265, lul_device..",DocumentType")
end
	
local function globaliseTheseFunctions()
	log(lul_device, "Registering Global(_G) Functions", 1)
	
   -- Stick all the luup.call_delay and time targets into the Global namespace table.
   -- Otherwise they are not visible to luup.call_delay and won't be executed.
   -- We always prefix them with 'NC_' to help avoid Global namespace collisions.

   _G["NC_CallPaperlessAPI"] = NC_CallPaperlessAPI
  -- _G["NC_ECMDupdateDaySoFar"] = NC_ECMDupdateDaySoFar

end

function PaperlessStartup(lul_device)
	log(lul_device, "Creating device..." ..lul_device)
	luup.attr_set( "name", "Paperless-ngx", lul_device)
	luup.variable_set(ITEM_SID, "PluginVersion", PV, lul_device)
	log(lul_device, "Checking configuration...", 1)
	readSettings(lul_device)
	log(lul_device, "Globalizing required functions", 1)
	globaliseTheseFunctions()
	log(lul_device, "DEBUG MODE is set to : " .. tostring(data.debug), 1)
	InitiatePaperless(lul_device)
end