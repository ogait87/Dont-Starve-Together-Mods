local DISTANCE_MODIFIER = 11
local POS_MODIFIER = 1.2
local MAX_MINIONS = 27 * POS_MODIFIER

local VALID_TILES = {
    [GROUND.DIRT] = true,
    [GROUND.SAVANNA] = true,
    [GROUND.GRASS] = true,
    [GROUND.FOREST] = true,
    [GROUND.MARSH] = true,

    -- CAVES
    [GROUND.CAVE] = true,
    [GROUND.FUNGUS] = true,
    [GROUND.SINKHOLE] = true,
    [GROUND.MUD] = true,
    [GROUND.FUNGUSRED] = true,
    [GROUND.FUNGUSGREEN] = true,

    --EXPANDED FLOOR TILES
    [GROUND.DECIDUOUS] = true,
}

local function generateNumbers()
    local list = {}

    for i = 1, 3 do
        table.insert(list, i)
    end

    return list
end

local NUMBERS = generateNumbers()

local LureplantFarmHelper = Class(function(self, inst)
    self.inst = inst
    self.display_state = false
    self.lureplants = {}
    self.n_active_lureplants = 0
    self.refresh_timer_active = false
    self:generateAvailableNumbers()
end)

function LureplantFarmHelper:AddLureplant(lureplant)
    self.lureplants[lureplant] = {}
    self.lureplants[lureplant]["Visible"] = false
    self.lureplants[lureplant]["Number"] = nil

    self.inst:DoTaskInTime(0.2, function()
        if self.display_state == true then
            self:DisplayLureplant(lureplant)
        end
    end)

    lureplant:ListenForEvent("onremove", function()
        self:HideLureplant(lureplant)
        self.lureplants[lureplant] = nil
    end)
end

function LureplantFarmHelper:isValidTile(tile)
    return VALID_TILES[tile]
end

function LureplantFarmHelper:DisplayLureplant(lureplant)
    if self.lureplants[lureplant]["Visible"] == true then
        return
    end

    self.lureplants[lureplant]["Visible"] = true
    self.n_active_lureplants = self.n_active_lureplants + 1

    local x, y, z = lureplant.Transform:GetWorldPosition()
    self.lureplants[lureplant]["Number"] = self:getNextAvailableNumber()

    local locator = SpawnPrefab("lureplant_locator")
    locator.Transform:SetPosition(x, y, z)
    locator.setNumber(self.lureplants[lureplant]["Number"])
    locator:Show()

    self.lureplants[lureplant]["Position"] = locator

    self.lureplants[lureplant]["Locators"] = {}
    for i = 1, 100 do
        local s = i / 32
        local a = math.sqrt(s * 512)
        local b = math.sqrt(s) * DISTANCE_MODIFIER
        local ix = x + math.sin(a) * b
        local iy = 0
        local iz = z + math.cos(a) * b

        local isValidPosition = TheWorld.Map:IsAboveGroundAtPoint(ix, iy, iz)
            and not TheWorld.Map:IsPointNearHole(Vector3(ix, iy, iz))
            and TheWorld.Pathfinder:IsClear(x, 0, z, ix, 0, iz, { ignorewalls = true })

        if isValidPosition then
            local locator = SpawnPrefab("eyeplant_locator")
            locator.setNumber(self.lureplants[lureplant]["Number"])
            locator.Transform:SetPosition(ix, iy, iz)
            locator:Show()

            self.lureplants[lureplant]["Locators"][i] = locator
        end
    end

    self:RefreshLureplant(lureplant)
    self:TryStartingRefreshTimer()
end

function LureplantFarmHelper:HideLureplant(lureplant)
    if self.lureplants[lureplant]["Visible"] == false then
        return
    end

    if self.lureplants[lureplant]["Position"] then
        self.lureplants[lureplant]["Position"]:Remove()
        self.lureplants[lureplant]["Position"] = nil
    end

    for i, locator in ipairs(self.lureplants[lureplant]["Locators"]) do
        locator:Remove()
    end
    self.lureplants[lureplant]["Locators"] = {}

    self:addAvailableNumber(self.lureplants[lureplant]["Number"])
    self.lureplants[lureplant]["Number"] = nil

    self.lureplants[lureplant]["Visible"] = false
    self.n_active_lureplants = self.n_active_lureplants - 1

    self:TryStartingRefreshTimer()
end

function LureplantFarmHelper:RefreshLureplants()
    for lureplant in pairs(self.lureplants) do
        self:RefreshLureplant(lureplant)
    end
end

function LureplantFarmHelper:RefreshLureplant(lureplant)
    if self.lureplants[lureplant]["Visible"] == true then
        local amount = 0

        for i, locator in ipairs(self.lureplants[lureplant]["Locators"]) do
            local x, y, z = locator.Transform:GetWorldPosition()
            local isGroundCompatible = self:isValidTile(TheWorld.Map:GetTileAtPoint(x, y, z))
            local isPrefabColliding = #TheSim:FindEntities(x, y, z, 1, nil, {"NOBLOCK"}) > 0

            if not isGroundCompatible then
                locator.setMode("position")
                locator.AnimState:SetSortOrder(0)
            elseif isPrefabColliding then
                locator.setMode("blocked")
                locator.AnimState:SetSortOrder(1)
            elseif amount < MAX_MINIONS then
                locator.setMode("selected")
                locator.AnimState:SetSortOrder(3)
                amount = amount + 1
            else
                locator.setMode("open")
                locator.AnimState:SetSortOrder(2)
            end
        end
    end
end

function LureplantFarmHelper:ToggleDisplayMode()
    self.display_state = not self.display_state

    if self.display_state == true then
        ThePlayer.components.talker:Say("Enabled")
        for lureplant in pairs(self.lureplants) do
            self:DisplayLureplant(lureplant)
        end
    else
        ThePlayer.components.talker:Say("Disabled")
        for lureplant in pairs(self.lureplants) do
            self:HideLureplant(lureplant)
        end
    end
end

function LureplantFarmHelper:ToggleDisplayLureplant(lureplant)
    if self.lureplants[lureplant]["Visible"] == true then
        self:HideLureplant(lureplant)
    else
        self:DisplayLureplant(lureplant)
    end
end

function LureplantFarmHelper:TryStartingRefreshTimer()
    if self.refresh_timer_active == true then
        return
    end

    if self.n_active_lureplants == 0 then
        return
    end

    self.refresh_timer_active = true

    self.inst:DoTaskInTime(0.5, function()
        self.refresh_timer_active = false
        self:RefreshLureplants()
        self:TryStartingRefreshTimer()
    end)
end

function LureplantFarmHelper:generateAvailableNumbers()
    self.available_numbers = {}
    for i, v in ipairs(NUMBERS) do
        table.insert(self.available_numbers, v)
    end
end

function LureplantFarmHelper:getNextAvailableNumber()
    for i, v in ipairs(self.available_numbers) do
        table.remove(self.available_numbers, i)
        return v
    end

    return -1
end

function LureplantFarmHelper:addAvailableNumber(number)
    if not(number == -1) then
        table.insert(self.available_numbers, number)
    end
end

return LureplantFarmHelper