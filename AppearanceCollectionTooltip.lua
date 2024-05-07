local addonName, ACT = ...

ACT.COLLECTED = 1
ACT.COLLECTABLE = 2
ACT.NOT_COLLECTED = 3

function ACT.GetAppearanceCollectionStatus(itemId)
	if not itemId then return end
	local sourceId = select(2, C_TransmogCollection.GetItemInfo(itemId))
	if not sourceId then return end
	local isCollected = select(5, C_TransmogCollection.GetAppearanceSourceInfo(sourceId))
	local canCollect = select(2, C_TransmogCollection.PlayerCanCollectSource(sourceId))
	if isCollected then
		return ACT.COLLECTED
	else
		if canCollect then
			return ACT.COLLECTABLE
		else
			return ACT.NOT_COLLECTED
		end
	end
end

local function ACT_SetTooltip(tooltip, collectionStatus)
	if collectionStatus == ACT.COLLECTED then
		tooltip:AddDoubleLine("Appearance", "Collected", 1, 1, 1, 0, 1, 0)
	else
		if collectionStatus == ACT.COLLECTABLE then
			tooltip:AddDoubleLine("Appearance", "Not collected", 1, 1, 1, 1, 1, 0)
		else
			tooltip:AddDoubleLine("Appearance", "Not collected", 1, 1, 1, 1, 0, 0)
		end
	end
end

local function fnAddAppearanceInfo(self)
	local name, link = self:GetItem()
	if not link then return end

	if ACT.IsItemTierToken(name, link) then
		local status = ACT.GetTierTokenStatus(name)
		if status > 0 then
			ACT_SetTooltip(self, status)
		end
	else
		local itemQuality = select(3, GetItemInfo(link))
		if itemQuality and itemQuality < 2 then return end --disregard poor and common items
	
		local id = string.match(link, "item:(%d*)")
		if id then
			local status = ACT.GetAppearanceCollectionStatus(id)
			ACT_SetTooltip(self, status)
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)
ItemRefTooltip:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)