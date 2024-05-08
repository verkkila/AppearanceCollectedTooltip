local addonName, ACT = ...

ACT.UNCOLLECTABLE = 0
ACT.COLLECTED = 1
ACT.COLLECTABLE = 2
ACT.NOT_COLLECTABLE = 3

ACT.REASON_WRONGCLASS = 1
ACT.REASON_INVALIDCHAR = 2

local armorClassId = {
	["Cloth"] = 1,
	["Leather"] = 2,
	["Mail"] = 3,
	["Plate"] = 4
}

local function ACT_PrimaryArmorType()
	local primaryArmorType = 0
	for i = 1, GetNumSkillLines() do --skill lines are hidden in Cata but still accessible, this may break in the future
		local skillName = GetSkillLineInfo(i)
		if armorClassId[skillName] and armorClassId[skillName] > primaryArmorType then
			primaryArmorType = armorClassId[skillName]
		end
	end
	return primaryArmorType
end

local function ACT_GetReason(itemId)
	local itemClassId, itemSubclassId = select(12, GetItemInfo(itemId))
	if itemClassId == 4 then --TODO: swap to enum
		if itemSubclassId == ACT_PrimaryArmorType() then
			return ACT.REASON_INVALIDCHAR
		end
	end
	return ACT.REASON_WRONGCLASS
end

local function ACT_GetReasonStr(reason)
	if reason == ACT.REASON_WRONGCLASS then
		return select(1, UnitClass("player"))
	end
	return select(1, UnitName("player"))
end

function ACT.GetAppearanceCollectionStatus(itemId)
	if not itemId then return 0 end
	local sourceId = select(2, C_TransmogCollection.GetItemInfo(itemId))
	if not sourceId then return 0 end
	local info = C_TransmogCollection.GetAppearanceInfoBySource(sourceId)
	if not info then return 0 end
	local canCollect = select(2, C_TransmogCollection.PlayerCanCollectSource(sourceId))
	if info.appearanceIsCollected then
		return ACT.COLLECTED
	else
		if canCollect then
			return ACT.COLLECTABLE
		else
			return ACT.NOT_COLLECTABLE, ACT_GetReason(itemId)
		end
	end
	return ACT.UNCOLLECTABLE
end

local function ACT_SetTooltip(tooltip, collectionStatus, reason)
	if collectionStatus == ACT.COLLECTED then
		tooltip:AddDoubleLine("Appearance", "Collected", 1, 1, 1, 0, 1, 0)
	else
		if collectionStatus == ACT.COLLECTABLE then
			tooltip:AddDoubleLine("Appearance", "Collectable", 1, 1, 1, 1, 1, 0)
		elseif collectionStatus == ACT.NOT_COLLECTABLE then
			tooltip:AddDoubleLine("Appearance", "Not collectable on " .. ACT_GetReasonStr(reason), 1, 1, 1, 1, 0, 0)
		end
	end
end

local function fnAddAppearanceInfo(self)
	local name, link = self:GetItem()
	if not link then return end

	if ACT.IsItemTierToken(name, link) then
		local status, reason = ACT.GetTierTokenStatus(name)
		if status > 0 then
			ACT_SetTooltip(self, status, reason)
		end
	else
		local itemQuality = select(3, GetItemInfo(link))
		if itemQuality and itemQuality < 2 then return end --disregard poor and common items
	
		local id = string.match(link, "item:(%d*)")
		if id then
			local status, reason = ACT.GetAppearanceCollectionStatus(id)
			if status > 0 then
				ACT_SetTooltip(self, status, reason)
			end
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)
ItemRefTooltip:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)