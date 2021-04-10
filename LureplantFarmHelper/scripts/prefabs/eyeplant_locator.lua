local assets =
{
    Asset("ANIM", "anim/eyeplant_locator.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("eyeplant_locator")
    inst.AnimState:SetBuild("eyeplant_locator")
    inst.AnimState:PlayAnimation("position?", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)
    inst.AnimState:SetLightOverride(1)

    inst.number = -1
    inst.mode = "position"

    inst.setNumber = function(n)
        inst.number = n
        inst.updateAnimation()
    end

    inst.setMode = function(mode)
        inst.mode = mode
        inst.updateAnimation()
    end

    inst.updateAnimation = function()
        local n = "?"

        if inst.number >= 1 and inst.number <= 3 then
            n = tostring(inst.number)
        end

        inst.AnimState:PlayAnimation(string.format("%s%s", inst.mode, n), true)
    end

    return inst
end

return Prefab("common/eyeplant_locator", fn, assets)
