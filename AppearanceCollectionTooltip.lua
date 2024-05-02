local function fnAddAppearanceInfo(self)
	local link = select(2, self:GetItem())
	if not link then return end
	
	local itemQuality = select(3, GetItemInfo(link))
	if itemQuality and itemQuality < 2 then return end --disregard poor and common items
	
	local id = string.match(link, "item:(%d*)")
	if id then
		local sourceID = select(2, C_TransmogCollection.GetItemInfo(id))
		if not sourceID then return end
		local isCollected = select(5, C_TransmogCollection.GetAppearanceSourceInfo(sourceID))
		local canCollect = select(2, C_TransmogCollection.PlayerCanCollectSource(sourceID))
		if isCollected then
			self:AddDoubleLine("Appearance", "Collected", 1, 1, 1, 0, 1, 0)
		else
			if canCollect then
				self:AddDoubleLine("Appearance", "Not collected", 1, 1, 1, 1, 1, 0)
			else
				self:AddDoubleLine("Appearance", "Not collected", 1, 1, 1, 1, 0, 0)
			end
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)
ItemRefTooltip:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)
ShoppingTooltip1:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)
ShoppingTooltip2:HookScript("OnTooltipSetItem", fnAddAppearanceInfo)