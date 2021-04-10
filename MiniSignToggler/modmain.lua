local toggle_key = GetModConfigData("toggle_key"):lower():byte()

local minisigns = {}
local hidesigns = false

GLOBAL.TheInput:AddKeyDownHandler(toggle_key, function()
    hidesigns = not hidesigns

    --set all minisigns to either hide/show
    for minisign in pairs(minisigns) do
        if hidesigns then
            minisign:Hide()
        else
            minisign:Show()
        end
    end
end)

AddPrefabPostInit("minisign", function(inst)
    --add new minisigns
    minisigns[inst] = true
    inst:ListenForEvent("onremove", function()
        --remove minisigns when they are despawned
        minisigns[inst] = nil
    end)

    --update the state of newly spawned minisigns to match the intended state.
    inst:DoTaskInTime(0.5, function()
        if hidesigns then
            inst:Hide()
        else
            inst:Show()
        end
    end)
end)

