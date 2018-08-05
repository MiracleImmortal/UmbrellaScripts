local wtfBrist = {}

wtfBrist.optionEnable = Menu.AddOptionBool({ "Hero Specific", "WTF+ Bristleback" }, "Enable", false)
wtfBrist.optionPause = Menu.AddOptionSlider({ "Hero Specific", "WTF+ Bristleback" }, "Pause", 0, 99, 0)
wtfBrist.optionSprayKey = Menu.AddKeyOption({ "Hero Specific", "WTF+ Bristleback" }, "Spray Key", Enum.ButtonCode.KEY_1);
wtfBrist.optionDebug = Menu.AddOptionBool({ "Hero Specific", "WTF+ Bristleback" }, "Debug", false)

wtfBrist.LastUpdateTime = 0
wtfBrist.PauseTime = 0.0

wtfBrist.WarPathLevel = 0
wtfBrist.WarPathCounter = 0
wtfBrist.MaxWarPathCounter = 0
wtfBrist.WarPathBasicCounter = 3

function wtfBrist.OnMenuOptionChange(option, oldValue, newValue)
    wtfBrist.PauseTime = tonumber("0." .. Menu.GetValue(wtfBrist.optionPause))
end

function wtfBrist.OnUpdate()
    if not Menu.IsEnabled(wtfBrist.optionEnable) or not Engine.IsInGame() or not Heroes.GetLocal() then
        return
    end

    if ((os.clock() - wtfBrist.LastUpdateTime) < wtfBrist.PauseTime) then
        return
    end
    wtfBrist.LastUpdateTime = os.clock();

    wtfBrist.MyHero = Heroes.GetLocal()
    if not wtfBrist.MyHero or NPC.GetUnitName(wtfBrist.MyHero) ~= "npc_dota_hero_bristleback" then
        return
    end

    local warPath = NPC.GetAbility(wtfBrist.MyHero, "bristleback_warpath")
    if warPath and Ability.GetLevel(warPath) > wtfBrist.WarPathLevel then
        wtfBrist.WarPathLevel = Ability.GetLevel(warPath)

        if wtfBrist.WarPathLevel > 0 then
            wtfBrist.MaxWarPathCounter = (wtfBrist.WarPathBasicCounter + (wtfBrist.WarPathLevel * 2))
        else
            wtfBrist.MaxWarPathCounter = 0
        end
    end

    if not Entity.IsAlive(wtfBrist.MyHero) or NPC.IsStunned(wtfBrist.MyHero) or NPC.IsSilenced(wtfBrist.MyHero) then
        return
    end
    local quillSpray = NPC.GetAbility(wtfBrist.MyHero, "bristleback_quill_spray")
    if not quillSpray then
        return
    end

    local quillSprayCastRange = Ability.GetCastRange(quillSpray)

    if wtfBrist.IsHeroInvisible(wtfBrist.MyHero) and not Menu.IsKeyDown(wtfBrist.optionSprayKey) then
        return
    elseif Menu.IsKeyDown(wtfBrist.optionSprayKey) then
        Ability.CastNoTarget(quillSpray)
        if Menu.IsEnabled(wtfBrist.optionDebug) then
            Log.Write("Force quillSpray!")
        end
        return
    elseif not wtfBrist.IsHeroInvisible(wtfBrist.MyHero) and wtfBrist.WarPathCounter < wtfBrist.MaxWarPathCounter then
        Ability.CastNoTarget(quillSpray)
        if Menu.IsEnabled(wtfBrist.optionDebug) then
            Log.Write("Increase warPath by quillSpray!")
        end
        return
    end

    local Units = Entity.GetUnitsInRadius(wtfBrist.MyHero, quillSprayCastRange, Enum.TeamType.TEAM_ENEMY)
    if not Units then
        return
    end

    for i, unit in pairs(Units) do
        if wtfBrist.isItTarget(unit, wtfBrist.MyHero, quillSprayCastRange) and Ability.IsReady(quillSpray) then
            if Menu.IsEnabled(wtfBrist.optionDebug) then
                Log.Write("Attack! [" .. NPC.GetUnitName(unit) .. "]")
            end
            Ability.CastNoTarget(quillSpray)
            break
        end
    end

    -- if Menu.IsEnabled(wtfBrist.optionDebug) then
    --     Log.Write("Start iretation")
    -- end
--    for i, unit in pairs(Units) do
--        -- if Menu.IsEnabled(wtfBrist.optionDebug) then
--        --     Log.Write("Before if! [" .. NPC.GetUnitName(unit) .. "]")
--        -- end
--
--        if unit ~= nil and unit ~= 0 and NPCs.Contains(unit) and NPC.IsEntityInRange(wtfBrist.MyHero, unit, quillSprayCastRange) then
--            -- if Menu.IsEnabled(wtfBrist.optionDebug) then
--            --     Log.Write("First if! [" .. NPC.GetUnitName(unit) .. "]")
--            -- end
--
--            if not Entity.IsSameTeam(unit, wtfBrist.MyHero) and not NPC.IsStructure(unit) and NPC.GetUnitName(unit) ~= "npc_dota_neutral_caster" then
--                -- if Menu.IsEnabled(wtfBrist.optionDebug) then
--                --     Log.Write("Second if! [" .. NPC.GetUnitName(unit) .. "]")
--                -- end
--
--                if NPC.GetUnitName(unit) ~= "npc_dota_observer_wards" then
--                    if Entity.IsAlive(unit) and not NPC.IsWaitingToSpawn(unit) and not Entity.IsDormant(unit) and Ability.IsReady(quillSpray) then
--                        if NPC.IsCreep(unit) or NPC.IsIllusion(unit) or NPC.IsHero(unit) or NPC.IsCourier(unit) then
--                            if Menu.IsEnabled(wtfBrist.optionDebug) then
--                                Log.Write("Attack! [" .. NPC.GetUnitName(unit) .. "]")
--                            end
--                            Ability.CastNoTarget(quillSpray)
--                            break
--                        end
--                    end
--                end
--            end
--        end
--    end
end

function wtfBrist.isItTarget(unit, mySelf, abilCastRange)
    if unit == nil or unit == 0 then
        return false
    end

--    if not NPCs.Contains(unit) then
--        return false
--    end

    if not NPC.IsEntityInRange(mySelf, unit, abilCastRange) then
        return false
    end

    if Entity.IsSameTeam(unit, mySelf) then
        return false
    end

    if NPC.IsStructure(unit) then
        return false
    end

    local unitName = NPC.GetUnitName(unit)

    if unitName == "npc_dota_neutral_caster" then
        return false
    end

    if unitName == "npc_dota_observer_wards" then
        return false
    end

    if unitName == "" then
        return false
    end

    if not Entity.IsAlive(unit) then
        return false
    end

    if NPC.IsWaitingToSpawn(unit) then
        return false
    end

    if Entity.IsDormant(unit) then
        return false
    end

--    if NPC.IsCreep(unit) or NPC.IsIllusion(unit) or NPC.IsHero(unit) or NPC.IsCourier(unit) then
--        return true
--    end

    return true
end

function wtfBrist.OnModifierCreate(ent, xMod)
    if ent == wtfBrist.MyHero and Modifier.GetName(xMod) == "modifier_bristleback_warpath_stack" then
        wtfBrist.WarPathCounter = wtfBrist.WarPathCounter + 1
        if Menu.IsEnabled(wtfBrist.optionDebug) then
            Log.Write("Create xMod -> " .. Modifier.GetName(xMod) .. " -> " .. wtfBrist.WarPathCounter)
        end
    end
end

function wtfBrist.OnModifierDestroy(ent, xMod)
    if ent == wtfBrist.MyHero and Modifier.GetName(xMod) == "modifier_bristleback_warpath_stack" then
        wtfBrist.WarPathCounter = wtfBrist.WarPathCounter - 1
        if Menu.IsEnabled(wtfBrist.optionDebug) then
            Log.Write("Destroy xMod -> " .. Modifier.GetName(xMod) .. " -> " .. wtfBrist.WarPathCounter)
        end
    end
end

function wtfBrist.IsHeroInvisible(myHero)
    if not myHero then
        return false
    end
    if not Entity.IsAlive(myHero) then
        return false
    end

    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then
        return true
    end
    if NPC.HasModifier(myHero, "modifier_invoker_ghost_walk_self") then
        return true
    end
    if NPC.HasAbility(myHero, "invoker_ghost_walk") then
        if Ability.SecondsSinceLastUse(NPC.GetAbility(myHero, "invoker_ghost_walk")) > -1 and Ability.SecondsSinceLastUse(NPC.GetAbility(myHero, "invoker_ghost_walk")) < 1 then
            return true
        end
    end

    if NPC.HasItem(myHero, "item_invis_sword", true) then
        if Ability.SecondsSinceLastUse(NPC.GetItem(myHero, "item_invis_sword", true)) > -1 and Ability.SecondsSinceLastUse(NPC.GetItem(myHero, "item_invis_sword", true)) < 1 then
            return true
        end
    end
    if NPC.HasItem(myHero, "item_silver_edge", true) then
        if Ability.SecondsSinceLastUse(NPC.GetItem(myHero, "item_silver_edge", true)) > -1 and Ability.SecondsSinceLastUse(NPC.GetItem(myHero, "item_silver_edge", true)) < 1 then
            return true
        end
    end

    return false
end

return wtfBrist
