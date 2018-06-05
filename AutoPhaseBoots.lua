local PhaseBoots = {}

PhaseBoots.Enable = Menu.AddOptionBool({ "Utility", "AutoUse" }, "PhaseBoots", false)

PhaseBoots.LastUpdateTime = 0
PhaseBoots.UpdateTime = 0.25

function PhaseBoots.OnUpdate()
    if not Menu.IsEnabled(PhaseBoots.Enable) then
        return
    end

    if ((os.clock() - PhaseBoots.LastUpdateTime) < PhaseBoots.UpdateTime) then
        return
    end
    PhaseBoots.LastUpdateTime = os.clock();

    local hero = Heroes.GetLocal()
    if not hero or not Entity.IsAlive(hero) then
        return
    end

    local phaseBoots = NPC.GetItem(hero, "item_phase_boots")
    if not phaseBoots then
        return
    end

    local mana = NPC.GetMana(hero)
    if mana == nil then
        return
    end

    if PhaseBoots.IsHeroInvisible(hero) then
        return
    end

    if NPC.IsRunning(hero) and Ability.IsCastable(phaseBoots, mana) then
        Ability.CastNoTarget(phaseBoots)
    end
end

function PhaseBoots.IsHeroInvisible(myHero)
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

return PhaseBoots
