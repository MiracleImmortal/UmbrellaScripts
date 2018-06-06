local AutoMekansm = {}

local MenuPath = { "Utility", "AutoUse", "Mekansm" }

AutoMekansm.YouHealthRegen  = Menu.AddOptionBool(MenuPath, "Health regen for you", false)
AutoMekansm.TeamHealthRegen = Menu.AddOptionBool(MenuPath, "Health regen for teammates", false)

AutoMekansm.MinTeammatesCount = Menu.AddOptionSlider(MenuPath, "Minimum teammates count", 1, 4, 1)
--AutoMekansm.optionDebug = Menu.AddOptionBool(MenuPath, "Debug", false)

AutoMekansm.LastUpdateTime = 0
AutoMekansm.UpdateTime = 0.25

AutoMekansm.HealthRegen = 250

function AutoMekansm.OnUpdate()
    if ((os.clock() - AutoMekansm.LastUpdateTime) < AutoMekansm.UpdateTime) then
        return
    end
    AutoMekansm.LastUpdateTime = os.clock()

    local MyHero = Heroes.GetLocal()
    if not MyHero or not Entity.IsAlive(MyHero) or NPC.IsStunned(MyHero) or NPC.IsSilenced(MyHero) then
        return
    end

    local Mekansm = NPC.GetItem(MyHero, "item_mekansm", true)
    if not Mekansm then
        return
    end

    if Menu.IsEnabled(AutoMekansm.YouHealthRegen) then
        if Entity.GetMaxHealth(MyHero) - Entity.GetHealth(MyHero) > AutoMekansm.HealthRegen and Mekansm and Ability.IsReady(Mekansm) then
            Ability.CastNoTarget(Mekansm)
            return
        end
    end

    if Menu.IsEnabled(AutoMekansm.TeamHealthRegen) then
        local CastRange = Ability.GetCastRange(Mekansm)

        local Heroes = Heroes.GetAll()
        local Teammates = {}

        for i, hero in pairs(Heroes) do
            if hero ~= nil and hero ~= 0 and hero ~= MyHero and NPCs.Contains(hero) and NPC.IsEntityInRange(MyHero, hero, CastRange) and Entity.IsSameTeam(hero, MyHero) then
                table.insert(Teammates, hero)
            end
        end

        local NeedHealthRegen = Menu.GetValue(AutoMekansm.MinTeammatesCount) * AutoMekansm.HealthRegen

        local RealHealthNeed = 0
        for i, hero in pairs(Teammates) do
            if hero and Entity.IsAlive(hero) then
                local HeroHealthNeed = Entity.GetMaxHealth(hero) - Entity.GetHealth(hero)
                if HeroHealthNeed >= AutoMekansm.HealthRegen then
                    RealHealthNeed = RealHealthNeed + AutoMekansm.HealthRegen
                elseif HeroHealthNeed < AutoMekansm.HealthRegen then
                    RealHealthNeed = RealHealthNeed + (Entity.GetMaxHealth(hero) - Entity.GetHealth(hero))
                end
            end
        end

        if RealHealthNeed >= NeedHealthRegen and Mekansm and Ability.IsReady(Mekansm) then
            Ability.CastNoTarget(Mekansm)
            return
        end
    end
end

return AutoMekansm
