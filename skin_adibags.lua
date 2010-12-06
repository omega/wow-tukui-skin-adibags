-- ORIGINAL CREDITS TO:
--  Chebyshev - http://www.tukui.org/v2/forums/topic.php?id=4964#post-44759
--

if not TukuiDB then return end

local addon = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local mult = TukuiDB.mult
addon.BACKDROP = {

    bgFile = TukuiCF.media.blank,
    edgeFile = TukuiCF.media.blank,
    tile = false,
    tileSize = 0,
    edgeSize = mult,
    insets = {
        left = -mult,
        right = -mult,
        top = -mult,
        bottom = -mult,
    },
}
local ITEM_SIZE = 31
addon.db.profile.backgroundColors.Backpack = TukuiCF.media.backdropcolor
addon.db.profile.backgroundColors.Bank = TukuiCF.media.backdropcolor
addon.db.profile.scale = 1

local childrenNames = { "Cooldown", "IconTexture", "IconQuestTexture", "Count", "Stock", "NormalTexture" }


local bProto = addon:GetClass('ItemButton').prototype
local stackProto = addon:GetClass('StackButton').prototype

function stackProto:OnCreate()
    self:SetWidth(ITEM_SIZE)
    self:SetHeight(ITEM_SIZE)
    self.slots = {}
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)
    self.GetCountHook = function()
        return self.count
    end
end


function reSkin(f)
    f:SetHeight(TukuiDB.Scale(ITEM_SIZE))
    f:SetWidth(TukuiDB.Scale(ITEM_SIZE))

    f:SetBackdrop(addon.BACKDROP)

    f:SetBackdropColor(0,0,0,1)
    f:SetNormalTexture("")
    f.skinned = true
    -- f:SetBackdropBorderColor(0,0,0,0)
    -- print(f, f:GetWidth() .. "x" ..f:GetHeight(), f:GetParent():GetName())
    if f.section then
        f.section.Header:SetFont(TukuiCF["media"].font, 12)
    end
    -- print(f:GetPoint("TOPLEFT"));
    -- print(f:GetRect());
end

function bProto:Update()
    if not self:CanUpdate() then return end
    local icon = self.IconTexture

    if not self.skinned then reSkin(self) end

    icon:ClearAllPoints()
    icon:SetTexCoord(.08, .92, .08, .92)
    -- icon:SetPoint("TOPLEFT", self, TukuiDB.Scale(2), TukuiDB.Scale(-2))
    -- icon:SetPoint("BOTTOMRIGHT", self, TukuiDB.Scale(-2), TukuiDB.Scale(2))
    icon:SetWidth(ITEM_SIZE - TukuiDB.mult * 2)
    icon:SetHeight(ITEM_SIZE - TukuiDB.mult * 2)

    icon:SetPoint("CENTER", self, "CENTER", 0, 0)
    if self.texture then
        icon:SetTexture(self.texture)
    else
        icon:SetTexture(0.3, 0.3, 0.3, 1);
    end
    -- icon:Hide()
    local tag = (not self.itemId or addon.db.profile.showBagType) and addon:GetFamilyTag(self.bagFamily)
    if tag then
        self.Stock:SetText(tag)
        self.Stock:Show()
    else
        self.Stock:Hide()
    end
    self:UpdateCount()
    self:UpdateBorder()
    self:UpdateCooldown()
    self:UpdateLock()
    addon:SendMessage('AdiBags_UpdateButton', self)
end


function bProto:UpdateBorder (isolatedEvent)
    if self.hasItem then
        local r, g, b, a = 1, 1, 1, 1
        local isQuestItem, questId, isActive = GetContainerItemQuestInfo(self.bag, self.slot)
        if addon.db.profile.questIndicator and (questId and not isActive) then
            r,g,b = 1.0, 0.3, 0.3
        elseif addon.db.profile.questIndicator and (questId or isQuestItem) then
            r,g,b = 1.0, 0.3, 0.3
        elseif addon.db.profile.qualityHighlight then
            local _, _, quality = GetItemInfo(self.itemId)
            if quality and quality >= ITEM_QUALITY_UNCOMMON then
                r, g, b = GetItemQualityColor(quality)
            elseif quality == ITEM_QUALITY_POOR and addon.db.profile.dimJunk then
                r,g,b = 0.5, 0.5, 0.5
            end
        end

        self:SetBackdropBorderColor(r,g,b,a)

        if isolatedEvent then
            addon:SendMessage('AdiBags_UpdateBorder', self)
        end
        return
    end
    self.IconQuestTexture:Hide()
    if isolatedEvent then
        addon:SendMessage('AdiBags_UpdateBorder', self)
    end
end

