local addonName, ACT = ...

local helmTokens = {
    "Helm",
    "Crown",
    "Regalia",
    "Mark of Sanctification"
}

local shoulderTokens = {
    "Pauldrons",
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

local tokenAttr = {}

function ACT.SlotInfoForToken(phrase)
    for i=1, 4 do
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
    for _, t in pairs(tokenizedStr) do
        local s, t, c = ACT.SlotInfoForToken(t), ACT.TierInfoForToken(t), classInfo[t]
        if s then ret["slot"] = s end
        if t then ret["tier"] = t end
        if c then ret["classes"] = c end
    end
    return ret.slot, ret.tier, ret.classes
end

local function ACT_IsTokenForMyClass(classesList)
    local myClass = select(2, UnitClass("player"))
    for _, c in pairs(classesList) do
        if myClass == c then return true end
    end
    return false
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
    local slot, tier, classes = ACT_GetTokenAttributes(splitName)
    if not slot or not tier or not classes then return 0 end
    local myClassName = select(2, UnitClass("player"))
    for _, c in pairs(classes) do
        if c == myClassName then
            local id = ACT.TierLookup[tier][myClassName][slot]
            if not id or id == 0 then return 0 end
            return ACT.GetAppearanceCollectionStatus(id)
        end
    end
    return 0
end