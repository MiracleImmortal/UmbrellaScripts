local AutoGuardianGreaves = {}

local MenuPath = { "Utility", "AutoUse", "GuardianGreaves" }

AutoGuardianGreaves.YouHealthRegen  = Menu.AddOptionBool(MenuPath, "Health regen for you", false)
AutoGuardianGreaves.YouManaRegen    = Menu.AddOptionBool(MenuPath, "Mana regen for you", false)

AutoGuardianGreaves.TeamHealthRegen = Menu.AddOptionBool(MenuPath, "Health regen for teammates", false)
AutoGuardianGreaves.TeamManaRegen   = Menu.AddOptionBool(MenuPath, "Mana regen for teammates", false)

AutoGuardianGreaves.MinTeammatesCount = Menu.AddOptionSlider(MenuPath, "Minimum teammates count", 1, 4, 1)
--AutoGuardianGreaves.optionDebug = Menu.AddOptionBool(MenuPath, "Debug", false)

AutoGuardianGreaves.LastUpdateTime = 0
AutoGuardianGreaves.UpdateTime = 0.25

AutoGuardianGreaves.ManaRegen = 160
AutoGuardianGreaves.HealthRegen = 250

function AutoGuardianGreaves.OnUpdate()
    if ((os.clock() - AutoGuardianGreaves.LastUpdateTime) < AutoGuardianGreaves.UpdateTime) then
        return
    end
    AutoGuardianGreaves.LastUpdateTime = os.clock()

    local MyHero = Heroes.GetLocal()
    if not MyHero or not Entity.IsAlive(MyHero) or NPC.IsStunned(MyHero) or NPC.IsSilenced(MyHero) then
        return
    end

    local GuardianGreaves = NPC.GetItem(MyHero, "item_guardian_greaves", true)
    if not GuardianGreaves then
        return
    end

    if Menu.IsEnabled(AutoGuardianGreaves.YouManaRegen) then
        if NPC.GetMaxMana(MyHero) - NPC.GetMana(MyHero) > AutoGuardianGreaves.ManaRegen and GuardianGreaves and Ability.IsReady(GuardianGreaves) then
            Ability.CastNoTarget(GuardianGreaves)
            return
        end
    end

    if Menu.IsEnabled(AutoGuardianGreaves.YouHealthRegen) then
        if Entity.GetMaxHealth(MyHero) - Entity.GetHealth(MyHero) > AutoGuardianGreaves.HealthRegen and GuardianGreaves and Ability.IsReady(GuardianGreaves) then
            Ability.CastNoTarget(GuardianGreaves)
            return
        end
    end

    if Menu.IsEnabled(AutoGuardianGreaves.TeamManaRegen) then
        local CastRange = Ability.GetCastRange(GuardianGreaves)

        local Heroes = Heroes.GetAll()
        local Teammates = {}

        for i, hero in pairs(Heroes) do
            if hero ~= nil and hero ~= 0 and hero ~= MyHero and NPCs.Contains(hero) and NPC.IsEntityInRange(MyHero, hero, CastRange) and Entity.IsSameTeam(hero, MyHero) then
                table.insert(Teammates, hero)
            end
        end

        local NeedManaRegen = Menu.GetValue(AutoGuardianGreaves.MinTeammatesCount) * AutoGuardianGreaves.ManaRegen

        local RealManaNeed = 0
        for i, hero in pairs(Teammates) do
            if hero and Entity.IsAlive(hero) then
                local HeroManaNeed = NPC.GetMaxMana(hero) - NPC.GetMana(hero)
                if HeroManaNeed >= AutoGuardianGreaves.ManaRegen then
                    RealManaNeed = RealManaNeed + AutoGuardianGreaves.ManaRegen
                elseif HeroManaNeed < AutoGuardianGreaves.ManaRegen then
                    RealManaNeed = RealManaNeed + (NPC.GetMaxMana(hero) - NPC.GetMana(hero))
                end
            end
        end

        if RealManaNeed >= NeedManaRegen and GuardianGreaves and Ability.IsReady(GuardianGreaves) then
            Ability.CastNoTarget(GuardianGreaves)
            return
        end
    end

    if Menu.IsEnabled(AutoGuardianGreaves.TeamHealthRegen) then
        local CastRange = Ability.GetCastRange(GuardianGreaves)

        local Heroes = Heroes.GetAll()
        local Teammates = {}

        for i, hero in pairs(Heroes) do
            if hero ~= nil and hero ~= 0 and hero ~= MyHero and NPCs.Contains(hero) and NPC.IsEntityInRange(MyHero, hero, CastRange) and Entity.IsSameTeam(hero, MyHero) then
                table.insert(Teammates, hero)
            end
        end

        local NeedHealthRegen = Menu.GetValue(AutoGuardianGreaves.MinTeammatesCount) * AutoGuardianGreaves.ManaRegen

        local RealHealthNeed = 0
        for i, hero in pairs(Teammates) do
            if hero and Entity.IsAlive(hero) then
                local HeroHealthNeed = Entity.GetMaxHealth(hero) - Entity.GetHealth(hero)
                if HeroHealthNeed >= AutoGuardianGreaves.ManaRegen then
                    RealHealthNeed = RealHealthNeed + AutoGuardianGreaves.ManaRegen
                elseif HeroHealthNeed < AutoGuardianGreaves.ManaRegen then
                    RealHealthNeed = RealHealthNeed + (Entity.GetMaxHealth(hero) - Entity.GetHealth(hero))
                end
            end
        end

        if RealHealthNeed >= NeedHealthRegen and GuardianGreaves and Ability.IsReady(GuardianGreaves) then
            Ability.CastNoTarget(GuardianGreaves)
            return
        end
    end
end

return AutoGuardianGreaves
