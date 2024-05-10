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
            return ACT.GetAppearanceCollectionStatus(itemId)
        end
    end
    return ACT.NOT_COLLECTABLE, ACT.REASON_WRONGCLASS
end