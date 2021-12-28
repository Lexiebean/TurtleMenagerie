local pets = {}
local mounts = {}

local function FindFriends()
	for i = 1, MAX_SKILLLINE_TABS do
	   local name, texture, offset, numSpells = GetSpellTabInfo(i);
	   
	   if not name then
		  break;
	   end

		if name == "ZCompanions" then
			for s = offset + 1, offset + numSpells do
				local spell, rank = GetSpellName(s, BOOKTYPE_SPELL);
				table.insert(pets, spell)
			end
		end
		
		if name == "ZMounts" then
			for s = offset + 1, offset + numSpells do
				local spell, rank = GetSpellName(s, BOOKTYPE_SPELL);
				table.insert(mounts, spell)
			end
		end
	end
end

SLASH_MENAGERIEPET1, SLASH_MENAGERIEPET2 = "/randompet", "/randpet"
SlashCmdList["MENAGERIEPET"] = function()
	FindFriends()
	CastSpellByName(pets[math.random(table.getn(pets))])
end

SLASH_MENAGERIEMOUNT1, SLASH_MENAGERIEMOUNT2 = "/randommount", "/randmount"
SlashCmdList["MENAGERIEMOUNT"] = function()
	FindFriends()
	CastSpellByName(mounts[math.random(table.getn(mounts))])
end