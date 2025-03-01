---@diagnostic disable: undefined-field
---@class BetterBags: AceAddon
local BetterBags = LibStub("AceAddon-3.0"):GetAddon("BetterBags")
assert(BetterBags, "BetterBags_IRLGoblin requires BetterBags")


---@class MoneyFrame: AceModule
local money = BetterBags:GetModule('MoneyFrame')


C_WowTokenPublic.UpdateMarketPrice()
local marketPrice = C_WowTokenPublic.GetCurrentMarketPrice()
timeSinceLastUpdate = 0
if marketPrice then
    print("Current Token Market Price:", marketPrice / 10000, "gold")
    print(money.overlay)
end


goldIcon = "Interface\\AddOns\\BetterBags_IRLGoblin\\icons\\gold.tga"
silverIcon = "Interface\\AddOns\\BetterBags_IRLGoblin\\icons\\silver.tga"
copperIcon = "Interface\\AddOns\\BetterBags_IRLGoblin\\icons\\copper.tga"


local function ChangeCurrencyIcons()
    hooksecurefunc("MoneyFrame_Update", function(frame, money)
        if frame and frame.GoldButton then

            frame.SilverButton:SetNormalTexture(goldIcon)
            frame.SilverButton:SetPushedTexture(goldIcon)

            frame.CopperButton:SetNormalTexture(copperIcon)
            frame.CopperButton:SetPushedTexture(copperIcon)

        end
    end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", ChangeCurrencyIcons)


local function periodicUpdate()
    C_WowTokenPublic.UpdateMarketPrice()
    marketPrice = C_WowTokenPublic.GetCurrentMarketPrice()
    print("New market price =", marketPrice)
end

C_Timer.NewTicker(300, periodicUpdate)


local function GoblinMoney(amount)
    res = amount / (marketPrice/20) * 100 --get silver amount digits and assign € icon to it and for copper cent icon
    return round(res,2)
end

function round(num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

hooksecurefunc("MoneyFrame_Update", function(frame, money)
    if not frame then
        return
    end

    if type(frame) == "table" then
        local frameName = frame:GetName() or "Unknown Frame"
        if frameName == "ContainerFrame1MoneyFrame" or frameName == "MerchantMoneyFrame"  then
            money = GetMoney()
        end
        if frameName ~= "ContainerFrame1MoneyFrame" and frameName ~= "MerchantMoneyFrame" then
            return
        end
    end

    if isUpdating then
        return
    end

    isUpdating = true
    local euroMoney = GoblinMoney(money)
    MoneyFrame_Update(frame, euroMoney)
    isUpdating = false
end)
