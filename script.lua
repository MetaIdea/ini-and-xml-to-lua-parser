-- print(string.match("Object TempleOfHeavenSideHouse", [[^Object%s+([%w_]+)]]))
-- if true then return end

KeyWordTable = { "Object ", "GameObject", "KindOf", "Side", "MaxHealth", "BuildCost", "BuildTime" }
NumberKeywordIndexStart = 5

function LoadFileData(file)
  local filehandle = assert(io.open(file, "r"),"io.open: Cannot open file to load: "..file)
  local data = assert(filehandle:read("a"),"read: cannot read file: "..file)
  filehandle:close()
  return data
end

function WriteToFile(output, file)
  local filehandle = assert(io.open(file, "w"),"io.open: Cannot open file to write: "..file)
  if filehandle ~= nil then
    filehandle:write(output)
    filehandle:flush()
    filehandle:close()
  end
end

function WriteToFileAppend(output, file)
  local filehandle = assert(io.open(file, "a+"),"io.open: Cannot open file to write: "..file)
  if filehandle ~= nil then
    filehandle:write(output)
    filehandle:flush()
    filehandle:close()
  end
end

function ParseTextFileIntoTable(file)
	local filehandle = assert(io.open(file, "r"),"io.open: Cannot open file to load: "..file)
	local LineTable = {}
	local LineCount = 0
	local FileSize = filehandle:seek("end")
	filehandle:seek("set")
	if FileSize ~= nil and FileSize ~= 0 then
		line = assert(filehandle:read("l"),"read: cannot read line from file: "..file)
		while line ~= nil do 
			LineCount=LineCount+1
			table.insert(LineTable, line) 
			line = filehandle:read("l")
		end
		filehandle:close()
		return LineTable, LineCount
	else
		return {}
	end
end

function ConvertLineTableToText(LineTable)
	return table.concat(LineTable, "\n")
end

function findnth(str, nth)
	local array = {}
	for word in string.gmatch(str, '%a+') do
		table.insert(array, word)
	end
	return array[nth]
end

function GetFilename(path)   
    local start, finish = path:find('[%w%s!-={-|]+[_%.].+')   
    return path:sub(start,#path) 
end

function GetKindOfString(line) --example: [[		KindOf="PRELOAD SELECTABLE CAN_CAST_REFLECTIONS SCORE VEHICLE FS_FACTORY EXPANSION_UNIT CAN_BE_FAVORITE_UNIT MCV IGNORES_SELECT_ALL"]]
	local str = string.sub(line, string.find(line,"=")+1, string.len(line))
	--local str3 = string.match(string.sub(str, string.find(str,"=")), [[%s+(%a+)]])
	local table_string = "{"
	for word in string.gmatch(str, [[%s*([%a%_]+)%s*]]) do
		table_string = table_string .. '"' .. word .. '",'
	end
	table_string = table_string .. "}"
	return table_string
end

file = arg[1]

print(file)

FILETYPE = 0

filename = GetFilename(file)
if string.find(string.lower(filename), [[.ini]]) then
	FILETYPE = 1
elseif string.find(string.lower(filename), [[.xml]]) then
	FILETYPE = 2
end

OBJ_DB = {}
OBJ_DB_STRING = ""

TextFileTable = ParseTextFileIntoTable(file)

		

if FILETYPE == 1 then --ini
	ObjectsToParse = 0
	ObjectsCount = 0
	for i=1,#TextFileTable,1 do
		if string.match(TextFileTable[i], [[^Object%s+([%w_]+)]]) then
			--print(TextFileTable[i] .. "   " .. string.match(TextFileTable[i], [[^Object%s+([%w_]+)]]))
			ObjectsToParse = ObjectsToParse + 1
		end
	end
	print(ObjectsToParse)
	LineCount = 1
	--for o=1,#ObjectsToParse,1 do
	--while ObjectsCount <= ObjectsToParse do
		for i=1,#TextFileTable,1 do
			for k=1,#KeyWordTable,1 do
				if k ~= 2 then
					if (string.find(TextFileTable[i], KeyWordTable[k])) and ((k ~= 1 and k ~= 2) or ((k == 1 or k== 2) and string.match(TextFileTable[i], [[^Object%s+([%w_]+)]]))) then
						if KeyWordTable[k] == "KindOf" then
							if string.match(TextFileTable[i], [[%s+(KindOf)%s+]]) then
								OBJ_DB_STRING = OBJ_DB_STRING .. '\n\t["' .. KeyWordTable[k] .. '"]=' .. GetKindOfString(TextFileTable[i]) .. ','
							end
						elseif k == 1 or k == 2 then
							if string.match(TextFileTable[i], [[^Object%s+([%w_]+)]]) then
								OBJ_DB_STRING = OBJ_DB_STRING .. "\n},\n{\n"
								OBJ_DB_STRING = OBJ_DB_STRING .. '\t["' .. "Object" .. '"]=' .. '"' .. string.match(TextFileTable[i], [[^Object%s+([%w_]+)]]) .. '",' --findnth(TextFileTable[i], 2) .. '",'
							else
								print(KeyWordTable[k] .. "   " .. TextFileTable[i])
							end
						elseif k >= NumberKeywordIndexStart then
							if string.match(TextFileTable[i], [[%d[%d.,]*]]) and not string.find(TextFileTable[i], "Behavior") then 
								OBJ_DB_STRING = OBJ_DB_STRING .. '\n\t["' .. KeyWordTable[k] .. '"]=' .. string.match(TextFileTable[i], [[%d[%d.,]*]]) .. ','
							else
								print(KeyWordTable[k] .. "   " .. TextFileTable[i])
							end
						elseif KeyWordTable[k] == "Side" then
							if string.match(TextFileTable[i], [[Side%s*=%s*(%w+)]]) then
								OBJ_DB_STRING = OBJ_DB_STRING .. '\n\t["' .. KeyWordTable[k] .. '"]=' .. '"' .. string.match(TextFileTable[i], [[=%s*(%w+)]]) .. '",'
							else
								print(KeyWordTable[k] .. "   " .. TextFileTable[i])
							end							
						else
							if string.match(TextFileTable[i], [[=%s*(%w+)]]) then 
								OBJ_DB_STRING = OBJ_DB_STRING .. '\n\t["' .. KeyWordTable[k] .. '"]=' .. '"' .. string.match(TextFileTable[i], [[=%s*(%w+)]]) .. '",'
							else
								print(KeyWordTable[k] .. "   " .. TextFileTable[i])
							end
						end		
						if k == #KeyWordTable and string.find(TextFileTable[i], "Geometry ") then 
							--OBJ_DB_STRING = OBJ_DB_STRING .. "\n},\n{\n"
							break
						end
						-- if k ~= #KeyWordTable then 
							-- if ObjectsCount == ObjectsToParse then
								-- --OBJ_DB_STRING = OBJ_DB_STRING .. "\n},{\n" 					
							-- else
								-- OBJ_DB_STRING = OBJ_DB_STRING .. "\n"
							-- end
							-- LineCount = i
						-- else
							-- OBJ_DB_STRING = OBJ_DB_STRING .. "\n},\n{\n"
						-- end
						-- break
					end
					if (string.find(TextFileTable[i], "Geometry ")) then
						ObjectsCount = ObjectsCount + 1				
					end
				end
			end
		end
	--end	
	OBJ_DB_STRING = OBJ_DB_STRING .. "\n},"
end

if FILETYPE == 2 then --xml
	for k=1,#KeyWordTable,1 do
		for i=1,#TextFileTable,1 do
			if k ~= 1 then
				if (string.find(TextFileTable[i], KeyWordTable[k])) then
					if KeyWordTable[k] == "KindOf" then
						OBJ_DB_STRING = OBJ_DB_STRING .. '\t["' .. KeyWordTable[k] .. '"]=' .. GetKindOfString(TextFileTable[i]) .. ','
					elseif k == 1 or k == 2 then
						for n=i,#TextFileTable,1 do
							if string.find(TextFileTable[n], "id=") then
								OBJ_DB_STRING = OBJ_DB_STRING .. "\n},\n{\n"
								OBJ_DB_STRING = OBJ_DB_STRING .. '\t["' .. "Object" .. '"]=' .. '"' .. string.match(TextFileTable[n], [[=%s*"%s*([%w_]+)]]) .. '",'
								break
							end
						end
					elseif k >= NumberKeywordIndexStart then
						OBJ_DB_STRING = OBJ_DB_STRING .. '\t["' .. KeyWordTable[k] .. '"]=' .. string.match(TextFileTable[i], [[%d+]]) .. ',' --[[%d[%d.,]*]]
					else
						OBJ_DB_STRING = OBJ_DB_STRING .. '\t["' .. KeyWordTable[k] .. '"]=' .. '"' .. string.match(TextFileTable[i], [[=%s*"%s*([%w_]+)]]) .. '",' --'[^"]+'
					end
					if k ~= #KeyWordTable then OBJ_DB_STRING = OBJ_DB_STRING .. "\n" end
					break
				end
			end
		end		
	end
end
		




WriteToFileAppend(OBJ_DB_STRING, "output.lua")