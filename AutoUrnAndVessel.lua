local AutoUrnAndVessel = {}

AutoUrnAndVessel.Enable = Menu.AddOptionBool({ "Utility", "AutoUse", "Urn and Vessel" }, "Enable", false)
AutoUrnAndVessel.FriendlyHP = Menu.AddOptionSlider({ "Utility", "AutoUse", "Urn and Vessel" }, "Friendly HP in percents", 1, 99, 10)
AutoUrnAndVessel.EnemyHP = Menu.AddOptionSlider({ "Utility", "AutoUse", "Urn and Vessel" }, "Enemy HP in percents", 1, 99, 3)
AutoUrnAndVessel.optionDebug = Menu.AddOptionBool({ "Utility", "AutoUse", "Urn and Vessel" }, "Debug", false)

AutoUrnAndVessel.LastUpdateTime = 0
AutoUrnAndVessel.UpdateTime = 0.25

function AutoUrnAndVessel.OnUpdate()
    if not Menu.IsEnabled(AutoUrnAndVessel.Enable) then
        return
    end

    if ((os.clock() - AutoUrnAndVessel.LastUpdateTime) < AutoUrnAndVessel.UpdateTime) then
        return
    end
    AutoUrnAndVessel.LastUpdateTime = os.clock();

    local MyHero = Heroes.GetLocal()
    if not MyHero or not Entity.IsAlive(MyHero) then
        if Menu.IsEnabled(AutoUrnAndVessel.optionDebug) then
            Log.Write("Your hero is die")
        end
        return
    end

    if AutoUrnAndVessel.IsHeroInvisible(MyHero) then
        if Menu.IsEnabled(AutoUrnAndVessel.optionDebug) then
            Log.Write("Your hero is invisible")
        end
        return
    end

    if NPC.IsStunned(MyHero) or NPC.IsSilenced(MyHero) then
        if Menu.IsEnabled(AutoUrnAndVessel.optionDebug) then
            Log.Write("Your hero is stunned or silenced")
        end
        return
    end

    if AutoUrnAndVessel.IsChannelling(MyHero) then
        if Menu.IsEnabled(AutoUrnAndVessel.optionDebug) then
            Log.Write("Your hero is channelling")
        end
        return
    end

    local UrnOfShadows = NPC.GetItem(MyHero, "item_urn_of_shadows")
    local SpiritVessel = NPC.GetItem(MyHero, "item_spirit_vessel")
    if not UrnOfShadows and not SpiritVessel then
        return
    end

    local CastRange = nil
    if UrnOfShadows then
        CastRange = Ability.GetCastRange(UrnOfShadows)
    elseif SpiritVessel then
        CastRange = Ability.GetCastRange(SpiritVessel)
    else
        return
    end

    local Mana = NPC.GetMana(MyHero)
    if not Mana then
        return
    end

    if UrnOfShadows then
        if not Ability.IsCastable(UrnOfShadows, Mana) or not Ability.IsReady(UrnOfShadows) then
            return
        end
    elseif SpiritVessel then
        if not Ability.IsCastable(SpiritVessel, Mana) or not Ability.IsReady(SpiritVessel) then
            return
        end
    end

    local Heroes = Heroes.GetAll()
    local EnemyHeroes = {}
    local FriendlyHeroes = {}

    for i, hero in pairs(Heroes) do
        if hero ~= nil and hero ~= 0 and NPCs.Contains(hero) and NPC.IsEntityInRange(MyHero, hero, CastRange) and not Entity.IsSameTeam(hero, MyHero) then
            table.insert(EnemyHeroes, hero)
        elseif hero ~= nil and hero ~= 0 and NPCs.Contains(hero) and NPC.IsEntityInRange(MyHero, hero, CastRange) and Entity.IsSameTeam(hero, MyHero) then
            table.insert(FriendlyHeroes, hero)
        end
    end

    for i, friendlyHero in pairs(FriendlyHeroes) do
        if friendlyHero and Entity.IsAlive(friendlyHero) then
            local Health = Entity.GetHealth(friendlyHero)
            local MaxHealth = Entity.GetMaxHealth(friendlyHero)
            local inPercents = (Health / MaxHealth) * 100
            --if Menu.IsEnabled(AutoUrnAndVessel.optionDebug) then
            --    Log.Write("Prepare heal to friendly " .. NPC.GetUnitName(friendlyHero) .. " with " .. inPercents .. "% HP < " .. Menu.GetValue(AutoUrnAndVessel.FriendlyHP) .. "%")
            --end

            if inPercents <= Menu.GetValue(AutoUrnAndVessel.FriendlyHP) then
                --if Menu.IsEnabled(AutoUrnAndVessel.optionDebug) then
                --    Log.Write("Use heal to friendly " .. NPC.GetUnitName(friendlyHero) .. " with " .. inPercents .. "% HP")
                --end

                if UrnOfShadows then
                    Ability.CastTarget(UrnOfShadows, friendlyHero, true)
                    return
                elseif SpiritVessel then
                    Ability.CastTarget(SpiritVessel, friendlyHero, true)
                    return
                end
            end
        end
    end

    for i, enemyHero in pairs(EnemyHeroes) do
        if enemyHero and Entity.IsAlive(enemyHero) then
            local Health = Entity.GetHealth(enemyHero)
            local MaxHealth = Entity.GetMaxHealth(enemyHero)
            local inPercents = (Health / MaxHealth) * 100
            --if Menu.IsEnabled(AutoUrnAndVessel.optionDebug) then
            --    Log.Write("Prepare heal to enemy " .. NPC.GetUnitName(enemyHero) .. " with " .. inPercents .. "% HP < " .. Menu.GetValue(AutoUrnAndVessel.EnemyHP) .. "%")
            --end

            if inPercents <= Menu.GetValue(AutoUrnAndVessel.EnemyHP) then
                --if Menu.IsEnabled(AutoUrnAndVessel.optionDebug) then
                --    Log.Write("Use heal to enemy " .. NPC.GetUnitName(enemyHero) .. " with " .. inPercents .. "% HP")
                --end

                if UrnOfShadows then
                    Ability.CastTarget(UrnOfShadows, enemyHero, true)
                    return
                elseif SpiritVessel then
                    Ability.CastTarget(SpiritVessel, enemyHero, true)
                    return
                end
            end
        end
    end
end

function AutoUrnAndVessel.IsHeroInvisible(MyHero)
    if not MyHero then
        return false
    end
    if not Entity.IsAlive(MyHero) then
        return false
    end

    if NPC.HasState(MyHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then
        return true
    end
    if NPC.HasModifier(MyHero, "modifier_invoker_ghost_walk_self") then
        return true
    end
    if NPC.HasAbility(MyHero, "invoker_ghost_walk") then
        if Ability.SecondsSinceLastUse(NPC.GetAbility(MyHero, "invoker_ghost_walk")) > -1 and Ability.SecondsSinceLastUse(NPC.GetAbility(MyHero, "invoker_ghost_walk")) < 1 then
            return true
        end
    end

    if NPC.HasItem(MyHero, "item_invis_sword", true) then
        if Ability.SecondsSinceLastUse(NPC.GetItem(MyHero, "item_invis_sword", true)) > -1 and Ability.SecondsSinceLastUse(NPC.GetItem(MyHero, "item_invis_sword", true)) < 1 then
            return true
        end
    end
    if NPC.HasItem(MyHero, "item_silver_edge", true) then
        if Ability.SecondsSinceLastUse(NPC.GetItem(MyHero, "item_silver_edge", true)) > -1 and Ability.SecondsSinceLastUse(NPC.GetItem(MyHero, "item_silver_edge", true)) < 1 then
            return true
        end
    end

    return false
end

function AutoUrnAndVessel.IsChannelling(MyHero)
    if NPC.IsChannellingAbility(MyHero) then return true end
    if NPC.HasModifier(MyHero, "modifier_teleporting") then return true end
    return false
end

return AutoUrnAndVessel
