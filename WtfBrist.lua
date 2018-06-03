local wtfBrist = {}

wtfBrist.IsEnable = Menu.AddOptionBool({"Hero Specific", "WTF+ Bristleback"}, "Enable", false)
wtfBrist.SprayKey = Menu.AddKeyOption({"Hero Specific", "WTF+ Bristleback"}, "Spray Key", Enum.ButtonCode.KEY_1);
wtfBrist.Debug    = Menu.AddOptionBool({"Hero Specific", "WTF+ Bristleback"}, "Debug", false)

wtfBrist.LastUpdateTime = 0
wtfBrist.UpdateTime = 0.0

wtfBrist.WarPathLevel         = 0
wtfBrist.WarPathCounter       = 0
wtfBrist.MaxWarPathCounter    = 0
wtfBrist.WarPathBasicCounter  = 3

function wtfBrist.OnUpdate()
    if not Menu.IsEnabled(wtfBrist.IsEnable) or not Engine.IsInGame() or not Heroes.GetLocal() then return end

    if ((os.clock() - wtfBrist.LastUpdateTime) < wtfBrist.UpdateTime) then
        return
    end
    wtfBrist.LastUpdateTime = os.clock();

    wtfBrist.MyHero = Heroes.GetLocal()
    if not wtfBrist.MyHero or NPC.GetUnitName(wtfBrist.MyHero) ~= "npc_dota_hero_bristleback" then return end

    local warPath = NPC.GetAbility(wtfBrist.MyHero, "bristleback_warpath")
    if warPath and Ability.GetLevel(warPath) > wtfBrist.WarPathLevel then
        wtfBrist.WarPathLevel = Ability.GetLevel(warPath)

        if wtfBrist.WarPathLevel > 0 then
            wtfBrist.MaxWarPathCounter = (wtfBrist.WarPathBasicCounter + (wtfBrist.WarPathLevel * 2))
        else
            wtfBrist.MaxWarPathCounter = 0
        end
    end

    if not Entity.IsAlive(wtfBrist.MyHero) or NPC.IsStunned(wtfBrist.MyHero) or NPC.IsSilenced(wtfBrist.MyHero) then return end
    local quillSpray = NPC.GetAbility(wtfBrist.MyHero, "bristleback_quill_spray")
    if not quillSpray then return end

    local quillSprayCastRange = Ability.GetCastRange(quillSpray)

    if wtfBrist.IsHeroInvisible(wtfBrist.MyHero) and not Menu.IsKeyDown(wtfBrist.SprayKey) then
        return
    elseif Menu.IsKeyDown(wtfBrist.SprayKey) then
        Ability.CastNoTarget(quillSpray)
        if Menu.IsEnabled(wtfBrist.Debug) then Log.Write("Force quillSpray!") end
        return
    elseif not wtfBrist.IsHeroInvisible(wtfBrist.MyHero) and wtfBrist.WarPathCounter < wtfBrist.MaxWarPathCounter then
        Ability.CastNoTarget(quillSpray)
        if Menu.IsEnabled(wtfBrist.Debug) then Log.Write("Increase warPath by quillSpray!") end
        return
    end

    local Units = Entity.GetUnitsInRadius(wtfBrist.MyHero, quillSprayCastRange, Enum.TeamType.TEAM_ENEMY)
    if not Units then return end

    for i, unit in pairs(Units) do
        if unit ~= nil and unit ~= 0 and NPCs.Contains(unit) and NPC.IsEntityInRange(wtfBrist.MyHero, unit, quillSprayCastRange) then
            if not Entity.IsSameTeam(unit, wtfBrist.MyHero) and not NPC.IsStructure(unit) and NPC.GetUnitName(unit) ~= "npc_dota_neutral_caster" then
                if NPC.GetUnitName(unit) ~= "npc_dota_observer_wards" then
                    if Entity.IsAlive(unit) and not NPC.IsWaitingToSpawn(unit) and not Entity.IsDormant(unit) and Ability.IsReady(quillSpray) then
                        if NPC.IsCreep(unit) or NPC.IsIllusion(unit) or NPC.IsHero(unit) or NPC.IsCourier(unit) then
                            if Menu.IsEnabled(wtfBrist.Debug) then Log.Write("Attack! [".. NPC.GetUnitName(unit) .."]") end
                            Ability.CastNoTarget(quillSpray)
                            break
                        end
                    end
                end
            end
        end
    end
end

function wtfBrist.OnModifierCreate(ent, xMod)
    if ent == wtfBrist.MyHero and Modifier.GetName(xMod) == "modifier_bristleback_warpath_stack" then
        wtfBrist.WarPathCounter = wtfBrist.WarPathCounter + 1
        if Menu.IsEnabled(wtfBrist.Debug) then Log.Write("Create xMod -> "..Modifier.GetName(xMod).." -> "..wtfBrist.WarPathCounter) end
    end
end

function wtfBrist.OnModifierDestroy(ent, xMod)
    if ent == wtfBrist.MyHero and Modifier.GetName(xMod) == "modifier_bristleback_warpath_stack" then
        wtfBrist.WarPathCounter = wtfBrist.WarPathCounter - 1
        if Menu.IsEnabled(wtfBrist.Debug) then Log.Write("Destroy xMod -> "..Modifier.GetName(xMod).." -> "..wtfBrist.WarPathCounter) end
    end
end

function wtfBrist.IsHeroInvisible(myHero)
  if not myHero then return false end
  if not Entity.IsAlive(myHero) then return false end

  if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return true end
  if NPC.HasModifier(myHero, "modifier_invoker_ghost_walk_self") then return true end
  if NPC.HasAbility(myHero, "invoker_ghost_walk") then
    if Ability.SecondsSinceLastUse(NPC.GetAbility(myHero, "invoker_ghost_walk")) > - 1 and Ability.SecondsSinceLastUse(NPC.GetAbility(myHero, "invoker_ghost_walk")) < 1 then
      return true
    end
  end

  if NPC.HasItem(myHero, "item_invis_sword", true) then
    if Ability.SecondsSinceLastUse(NPC.GetItem(myHero, "item_invis_sword", true)) > - 1 and Ability.SecondsSinceLastUse(NPC.GetItem(myHero, "item_invis_sword", true)) < 1 then
      return true
    end
  end
  if NPC.HasItem(myHero, "item_silver_edge", true) then
    if Ability.SecondsSinceLastUse(NPC.GetItem(myHero, "item_silver_edge", true)) > - 1 and Ability.SecondsSinceLastUse(NPC.GetItem(myHero, "item_silver_edge", true)) < 1 then
      return true
    end
  end

  return false
end

return wtfBrist
