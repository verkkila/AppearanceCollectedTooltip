local addonName, ACT = ...

local helmTokens = {
    "Helm",
    "Crown",
    "Regalia",
    "Mark of Sanctification"
}

local shoulderTokens = {
    "Pauldrons",
    "Spaulders",
    "Mantle",
    "Regalia",
    "Mark of Sanctification"
}

local chestTokens = {
    "Chestguard",
    "Breastplate",
    "Regalia",
    "Mark of Sanctification"
}

local legTokens = {
    "Leggings",
    "Legplates",
    "Regalia",
    "Mark of Sanctification"
}

local gloveTokens = {
    "Gloves",
    "Gauntlets",
    "Regalia",
    "Mark of Sanctification"
}

local tokenDifficulty = {
    ["Helm"] = ACT.NORMAL,
    ["Spaulders"] = ACT.NORMAL,
    ["Chestguard"] = ACT.NORMAL,
    ["Leggings"] = ACT.NORMAL,
    ["Gloves"] = ACT.NORMAL,
    ["Crown"] = ACT.HEROIC,
    ["Mantle"] = ACT.HEROIC,
    ["Breastplate"] = ACT.HEROIC,
    ["Legplates"] = ACT.HEROIC,
    ["Gauntlets"] = ACT.HEROIC,
}

local tierInfo = {
    ["Fallen"] = ACT.TIER_4,
    ["Vanquished"] = ACT.TIER_5,
    ["Forgotten"] = ACT.TIER_6,
    ["Lost"] = ACT.TIER_7_10,
    ["Wayward"] = ACT.TIER_8_10,
    ["Grand"] = ACT.TIER_9
}

local classInfo = {
    ["Champion"] = {"PALADIN", "ROGUE", "SHAMAN"},
    ["Defender"] = {"WARRIOR", "PRIEST", "DRUID"},
    ["Hero"] = {"HUNTER", "MAGE", "WARLOCK"},
    ["Conqueror"] = {"PALADIN", "PRIEST", "WARLOCK"},
    ["Protector"] = {"WARRIOR", "HUNTER", "SHAMAN"},
    ["Vanquisher"] = {"ROGUE", "MAGE", "DRUID", "DEATHKNIGHT"},
}

function ACT.SlotInfoForToken(phrase)
    for i=1, 5 do
        if helmTokens[i] == phrase then return "HEADSLOT" end
        if shoulderTokens[i] == phrase then return "SHOULDERSLOT" end
        if chestTokens[i] == phrase then return "CHESTSLOT" end
        if legTokens[i] == phrase then return "LEGSSLOT" end
        if gloveTokens[i] == phrase then return "HANDSSLOT" end
        if phrase == "Bracers" then return "WRISTSLOT" end
        if phrase == "Belt" then return "WAISTSLOT" end
        if phrase == "Boots" then return "FEETSLOT" end
    end
    return nil
end

function ACT.TierInfoForToken(phrase)
    if phrase then return tierInfo[phrase] end
    return nil
end

local function ACT_TokenizeTierTokenName(fullName)
    local splitName = {}
    for token in string.gmatch(fullName, "[^%s]+") do
        if token ~= "of" and token ~= "the" then
            table.insert(splitName, token)
        end
    end
    return splitName
end

local function ACT_GetTokenAttributes(tokenizedStr)
    local ret = {}
    for _, token in pairs(tokenizedStr) do
        local slot, tier, classes = ACT.SlotInfoForToken(token), ACT.TierInfoForToken(token), classInfo[token]
        if slot then
            ret["originalSlot"] = token
            ret["slot"] = slot
        end
        if tier then ret["tier"] = tier end
        if classes then ret["classes"] = classes end
    end
    return ret.slot, ret.tier, ret.classes, ret.originalSlot
end

function ACT.IsItemTierToken(itemName, itemLink)
    local classId, subclassId = select(12, GetItemInfo(itemLink))
    if classId ~= 15 or subclassId ~= 0 then return false end -- tier tokens are officially miscellaneous junk
    local splitName = ACT_TokenizeTierTokenName(itemName)
    local slot, tier, classes = ACT_GetTokenAttributes(splitName)
    return slot and tier and classes
end

--Slot of the Tier Classes
function ACT.GetTierTokenStatus(tokenName)
    local splitName = ACT_TokenizeTierTokenName(tokenName)
    if not splitName then return 0 end

    local slot, tier, classes, origSlot = ACT_GetTokenAttributes(splitName)
    if not slot or not tier or not classes then return 0 end

    if tier > ACT.TIER_8_25 then return 0 end --prevent erroring on Regalias until implemented

    local myClassName = select(2, UnitClass("player"))
    for _, c in pairs(classes) do
        if c == myClassName then
            local id = nil
            if tier == ACT.TIER_7_10 or tier == ACT.TIER_8_10 then
                local version = tokenDifficulty[origSlot] --bump version up one index if it's 25-man
                tier = tier + version
            end
            id = ACT.TierLookup[tier][myClassName][slot]
            if not id or id == 0 then return 0 end
            return ACT.GetAppearanceCollectionStatus(id)
        end
    end
    return 0
end