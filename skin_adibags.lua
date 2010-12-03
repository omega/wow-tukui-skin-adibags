if not TukuiDB then return end

local addon = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local mult = TukuiDB.mult
mult = -3
addon.BACKDROP = {

    bgFile = TukuiCF.media.blank,
    edgeFile = TukuiCF.media.blank,
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = {
        left = -mult,
        right = -mult,
        top = -mult,
        bottom = -mult,
    },
}
addon.db.profile.backgroundColors.Backpack = TukuiCF.media.backdropcolor
addon.db.profile.backgroundColors.Bank = TukuiCF.media.backdropcolor

local childrenNames = { "Cooldown", "IconTexture", "IconQuestTexture", "Count", "Stock", "NormalTexture" }


local bProto = addon:GetClass('ItemButton').prototype
local stackProto = addon:GetClass('StackButton').prototype

function reSkin(f)
    -- f:SetHeight(TukuiDB.Scale(31))
    -- f:SetWidth(TukuiDB.Scale(31))

    f:SetBackdrop(addon.BACKDROP)

    f:SetBackdropColor(1,0,0,1)
    f:SetNormalTexture("")
    f.skinned = true
    -- f:SetBackdropBorderColor(0,0,0,0)
    print(f, f:GetWidth() .. "x" ..f:GetHeight(), f:GetParent():GetName())
    print(f:GetPoint("TOPLEFT"));
    print(f:GetRect());
end

function bProto:Update()
    if not self:CanUpdate() then return end
    local icon = self.IconTexture

    if not self.skinned then reSkin(self) end

    icon:ClearAllPoints()
    icon:SetTexCoord(.08, .92, .08, .92)
    -- icon:SetPoint("TOPLEFT", self, TukuiDB.Scale(2), TukuiDB.Scale(-2))
    -- icon:SetPoint("BOTTOMRIGHT", self, TukuiDB.Scale(-2), TukuiDB.Scale(2))
    icon:SetWidth(addon.ITEM_SIZE - TukuiDB.mult * 2)
    icon:SetHeight(addon.ITEM_SIZE - TukuiDB.mult * 2)

    icon:SetPoint("CENTER", self, "CENTER", 0, 0)
    if self.texture then
        icon:SetTexture(self.texture)
    else
        icon:SetTexture(0.3, 0.3, 0.3, 1);
    end
    icon:Hide()
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
            r,g,b = 1.0, 0, 0
        elseif addon.db.profile.questIndicator and (questId or isQuestItem) then
            r,g,b = 1.0, 0, 0
        elseif addon.db.profile.qualityHighlight then
            local _, _, quality = GetItemInfo(self.itemId)
            if quality and quality >= ITEM_QUALITY_UNCOMMON then
                r, g, b = GetItemQualityColor(quality)
            elseif quality == ITEM_QUALITY_POOR and addon.db.profile.dimJunk then
                r,g,b = 0.5, 0.5, 0.5
            end
        end

        -- self:SetBackdropBorderColor(r,g,b,a)

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

