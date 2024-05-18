local addonName, ACT = ...

function ACT.GetTokenAttributes(itemId)
    local nItemId = tonumber(itemId)
    return ACT.TokenAttributes[nItemId]
end

function ACT.IsItemTierToken(itemId)
    return ACT.GetTokenAttributes(itemId) ~= nil
end

function ACT.GetTierTokenStatus(tokenItemId)
    local tokenAttr = ACT.GetTokenAttributes(tokenItemId)
    if not tokenAttr.tier or type(tokenAttr.tier) ~= "number" or
       not tokenAttr.slot or type(tokenAttr.slot) ~= "string" or
       not tokenAttr.classes or type(tokenAttr.classes) ~= "table" then return 0, nil end

    local myClassName = select(2, UnitClass("player"))
    for _, c in pairs(tokenAttr.classes) do
        if c == myClassName then
            local itemId = ACT.TierLookup[tokenAttr.tier][myClassName][tokenAttr.slot]
            if not itemId then return 0 end
            local statusPvE, reasonPvE = ACT.GetAppearanceCollectionStatus(itemId)

            local itemIdPvP = nil
            if tokenAttr.tier == ACT.TIER_4 or
               tokenAttr.tier == ACT.TIER_5 or
               tokenAttr.tier == ACT.TIER_6 then
                itemIdPvP = ACT.TierLookupPvP[tokenAttr.tier][myClassName][tokenAttr.slot]
            end

            if itemIdPvP then
                local statusPvP, reasonPvP = ACT.GetAppearanceCollectionStatus(itemIdPvP)
                return {
                    {["extra"] = "PvE", ["status"] = statusPvE, ["reason"] = reasonPvE},
                    {["extra"] = "PvP", ["status"] = statusPvP, ["reason"] = reasonPvP}
                }
            else
                return {
                    {["status"] = statusPvE, ["reason"] = reasonPvE}
                }
            end
        end
    end
    return {
        {["status"] = ACT.NOT_COLLECTABLE, ["reason"] = ACT.REASON_WRONGCLASS}
    }
end