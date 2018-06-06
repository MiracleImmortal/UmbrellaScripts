local AutoArcaneBoots = {}

local MenuPath = { "Utility", "AutoUse", "ArcaneBoots" }

AutoArcaneBoots.EnableForYou = Menu.AddOptionBool(MenuPath, "Enable for you", false)
AutoArcaneBoots.EnableForTeammates = Menu.AddOptionBool(MenuPath, "Enable for teammates", false)
AutoArcaneBoots.MinTeammatesCount = Menu.AddOptionSlider(MenuPath, "Minimum teammates count", 1, 4, 1)
--AutoArcaneBoots.optionDebug = Menu.AddOptionBool(MenuPath, "Debug", false)

AutoArcaneBoots.LastUpdateTime = 0
AutoArcaneBoots.UpdateTime = 0.25

function AutoArcaneBoots.OnUpdate()
    if ((os.clock() - AutoArcaneBoots.LastUpdateTime) < AutoArcaneBoots.UpdateTime) then
        return
    end
    AutoArcaneBoots.LastUpdateTime = os.clock()

    local MyHero = Heroes.GetLocal()
    if not MyHero or not Entity.IsAlive(MyHero) or NPC.IsStunned(MyHero) or NPC.IsSilenced(MyHero) then
        return
    end

    local ArcaneBoots = NPC.GetItem(MyHero, "item_arcane_boots", true)
    if not ArcaneBoots then
        return
    end

    if Menu.IsEnabled(AutoArcaneBoots.EnableForYou) then
        if NPC.GetMaxMana(MyHero) - NPC.GetMana(MyHero) > 135 and ArcaneBoots and Ability.IsReady(ArcaneBoots) then
            Ability.CastNoTarget(ArcaneBoots)
            return
        end
    end

    if Menu.IsEnabled(AutoArcaneBoots.EnableForTeammates) then
        local CastRange = Ability.GetCastRange(ArcaneBoots)

        local Heroes = Heroes.GetAll()
        local Teammates = {}

        for i, hero in pairs(Heroes) do
            if hero ~= nil and hero ~= 0 and hero ~= MyHero and NPCs.Contains(hero) and NPC.IsEntityInRange(MyHero, hero, CastRange) and Entity.IsSameTeam(hero, MyHero) then
                table.insert(Teammates, hero)
            end
        end

        local NeedManaRegen = Menu.GetValue(AutoArcaneBoots.MinTeammatesCount) * 135 -- 135 - Arcane boots regen

        local RealManaNeed = 0
        for i, hero in pairs(Teammates) do
            if hero and Entity.IsAlive(hero) then
                local HeroManaNeed = NPC.GetMaxMana(hero) - NPC.GetMana(hero)
                if HeroManaNeed >= 135 then
                    RealManaNeed = RealManaNeed + 135
                elseif HeroManaNeed < 135 then
                    RealManaNeed = RealManaNeed + (NPC.GetMaxMana(hero) - NPC.GetMana(hero))
                end
            end
        end

        if RealManaNeed >= NeedManaRegen and ArcaneBoots and Ability.IsReady(ArcaneBoots) then
            Ability.CastNoTarget(ArcaneBoots)
            return
        end
    end
end

return AutoArcaneBoots
