if not Menagerie_Pets then Menagerie_Pets = { } end
if not Menagerie_Mounts then Menagerie_Mounts = { } end
Menagerie_LastPet = ""
Menagerie_LastMount = ""
local gfind = string.gmatch or string.gfind
local function strmatch(str, pat, init)
	local a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a13,a14,a15,a16,a17,a18,a19,a20 = string.find(str, pat, init)
	return a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a13,a14,a15,a16,a17,a18,a19,a20
end

function Menagerie_OnEvent(event, arg1)
	if event == "UNIT_FLAGS" and arg1 == "player" then
		if UnitOnTaxi("player") == 1 then
			DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[Turtle Menagerie]|r Flying")
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[Turtle Menagerie]|r NOT flying")
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[Turtle Menagerie]|r Entering World")
	end
end

-- Generate the list of friends
local function FindFriends()
	for i = 1, MAX_SKILLLINE_TABS do
	   local name, texture, offset, numSpells = GetSpellTabInfo(i);
	   
	   if not name then
		  break;
	   end

		if name == "ZzCompanions" then
			for s = offset + 1, offset + numSpells do
				local spell, rank = GetSpellName(s, BOOKTYPE_SPELL);
				
				-- Check for blacklisted pets
				local bl = false
				for i=1,table.getn(Menagerie_Pets) do
					if  string.lower(spell) == Menagerie_Pets[i] then
						bl = true
					end
				end
				if string.lower(spell) == string.lower(Menagerie_LastPet) then
					bl = true
				end
				if not bl then 
					table.insert(pets, spell)
				end
			end
		end
		
		if name == "ZMounts" then
			for s = offset + 1, offset + numSpells do
				local spell, rank = GetSpellName(s, BOOKTYPE_SPELL);

				-- Check for blacklisted mounts
				local bl = false
				for i=1,table.getn(Menagerie_Mounts) do
					if  string.lower(spell) == Menagerie_Mounts[i] then
						bl = true
					end
				end
				if not bl then
					-- Dirty check to see if we're in AQ40 or not and only add the appropriate mounts to the list. ...I'm tired, this is messy. But probably works? IDK
					if GetZoneText() ~= "Ahn'Qiraj" then
						if not string.find(spell, "Qiraji Battle Tank") then
							table.insert(mounts, spell)
						end
					else
						if string.find(spell, "Qiraji Battle Tank") then
							table.insert(mounts, spell)
						end
					end
				end
			end
		end
	end
end

SLASH_MENAGERIEPET1, SLASH_MENAGERIEPET2 = "/randompet", "/randpet"
SlashCmdList["MENAGERIEPET"] = function(message)
	Menagerie("pets " .. message)
end

SLASH_MENAGERIEMOUNT1, SLASH_MENAGERIEMOUNT2 = "/randommount", "/randmount"
SlashCmdList["MENAGERIEMOUNT"] = function(message)
	Menagerie("mounts " .. message)
end

SLASH_MENAGERIEBANK1 = "/bank"
SlashCmdList["SLASH_MENAGERIEBANK1"] = function(message)
	 CastSpellByName("Forworn Mule")
end

-- A lot of this blacklist code is heavily based on Shagu's ShaguChat.
function Menagerie(message)

	pets = {}
	mounts = {}

	local commandlist = { }
	local command

	for command in gfind(message, "[^ ]+") do
		table.insert(commandlist, string.lower(command))
	end
	
	FindFriends()
	
	-- Add to blacklist
	if commandlist[2] == "bl" then
		local addstring = table.concat(commandlist," ",3)
		if addstring == "" then return end
		local m = strmatch(addstring, "%[(.+)%]")
		if m then addstring = m end
		if commandlist[1] == "pets" then
			table.insert(Menagerie_Pets, string.lower(addstring))
		else
			table.insert(Menagerie_Mounts, string.lower(addstring))
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[Turtle Menagerie]|r Adding |cffbe5eff".. addstring .."|r to your blacklist list.")

	-- Remove from blacklist
	elseif commandlist[2] == "rm" then
		local name = ""
		local rmTable = Menagerie_Mounts
		if commandlist[1] == "pets" then rmTable = Menagerie_Pets end
		for i = 3, table.getn(commandlist) do
			name = name .. commandlist[i] .. " "
		end
		name= string.sub(name,1, string.len(name)-1)
		local isContained, index = doesTableContain(rmTable,name)
		if isContained and commandlist[1] == "pets" then
			DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[Turtle Menagerie]|r Removing |cffbe5eff" .. name .. "|r from your blacklist list")
			table.remove(Menagerie_Pets, index)
		elseif isContained then
			DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[Turtle Menagerie]|r Removing |cffbe5eff" .. name .. "|r from your blacklist list")
			table.remove(Menagerie_Mounts, index)
		end
	
	-- List the blacklist
	elseif commandlist[2] == "ls" then
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[Turtle Menagerie] Blacklist|r ")
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5effPets:")
		printID = 0
		for id, bl in pairs(Menagerie_Pets) do
			DEFAULT_CHAT_FRAME:AddMessage(" |r[|cffbe5eff"..id.."|r] "..bl)
			printID = id
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cffbe5effMounts:")
		for id, bl in pairs(Menagerie_Mounts) do
			DEFAULT_CHAT_FRAME:AddMessage(" |r[|cffbe5eff"..id+printID.."|r] "..bl)
		end
		
	-- Summon our friends!
	else
		if commandlist[1] == "pets" then
			if table.getn(pets) > 1 then
				table.insert(pets, Menagerie_LastPet)
			end
			if table.getn(pets) > 0 then
				Menagerie_LastPet = pets[math.random(table.getn(pets))]
				CastSpellByName(Menagerie_LastPet)
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[Turtle Menagerie]|r No pets available.")
			end
		else
			if table.getn(mounts) > 1 then
				table.insert(mounts, Menagerie_LastMount)
			end
			if table.getn(mounts) > 0 then
				Menagerie_LastMount = mounts[math.random(table.getn(mounts))]
				CastSpellByName(Menagerie_LastMount)
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cffbe5eff[Turtle Menagerie]|r No mounts available.")
			end
		end
	end
end

function doesTableContain(table, contains)
	local found = false
	local index = nil
	for k, v in pairs(table) do
		if v == contains then 
			found = true 
			index = k
		end
	end
	return found, index
end
