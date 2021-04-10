local assets =
{
    Asset("ANIM", "anim/lureplant_locator.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lureplant_locator")
    inst.AnimState:SetBuild("lureplant_locator")
    inst.AnimState:PlayAnimation("position?", true)
    inst.AnimState:SetLightOverride(1)
    inst.Transform:SetScale(1.0, 1.0, 1.0)

    inst.number = -1

    inst.setColor = function(color)
        inst.AnimState:SetMultColour(color.r, color.g, color.b, color.a)
    end

    inst.setNumber = function(n)
        inst.number = n
        inst.updateAnimation()
    end

    inst.updateAnimation = function()
        local n = "?"

        if inst.number >= 1 and inst.number <= 3 then
            n = tostring(inst.number)
        end

        inst.AnimState:PlayAnimation(string.format("position%s", n), true)
    end

    return inst
end

return Prefab("common/lureplant_locator", fn, assets)
