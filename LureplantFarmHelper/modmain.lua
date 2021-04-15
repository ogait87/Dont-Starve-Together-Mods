PrefabFiles = {
    "lureplant_locator",
	"eyeplant_locator",
}

Assets = {
	Asset("ANIM", "anim/lureplant_locator.zip"),
	Asset("ANIM", "anim/eyeplant_locator.zip"),
}

local toggle_key = GetModConfigData("toggle_key"):lower():byte()
local LureplantFarmHelper = nil

local function InGame()
    return GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and not GLOBAL.ThePlayer.HUD:HasInputFocus()
end

AddComponentPostInit("playercontroller", function(self, inst)
    if inst ~= GLOBAL.ThePlayer then return end

    GLOBAL.ThePlayer:AddComponent("lureplant_farm_helper")
    LureplantFarmHelper = GLOBAL.ThePlayer.components.lureplant_farm_helper

    for k,item in pairs(GLOBAL.Ents) do
        if item.prefab == "lureplant" then
            LureplantFarmHelper:AddLureplant(item)
        end
    end
end)

GLOBAL.TheInput:AddKeyDownHandler(toggle_key, function()
    if not InGame() then
        return
    end

    if LureplantFarmHelper then
        LureplantFarmHelper:ToggleDisplayMode()
    else
        print("Failed to toggle display mode", inst)
    end
end)

GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_PRIMARY, function(down)
    if not InGame() then
        return
    end

    if down and not GLOBAL.TheInput:GetHUDEntityUnderMouse() and GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
        local item = GLOBAL.TheInput:GetWorldEntityUnderMouse()
        if item and item.prefab == "lureplant" then
            LureplantFarmHelper:ToggleDisplayLureplant(item)
        end
    end
end)

AddPrefabPostInit("lureplant", function(inst)
    if LureplantFarmHelper then
        LureplantFarmHelper:AddLureplant(inst)
    else
        print("Failed to add lureplant", inst)
    end
end)

