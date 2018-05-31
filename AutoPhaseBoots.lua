local PhaseBoots = {}

PhaseBoots.Enable = Menu.AddOptionBool({"Utility", "AutoUse"}, "PhaseBoots", false)

function PhaseBoots.OnUpdate()
    if not Menu.IsEnabled(PhaseBoots.Enable) then return end

    local hero = Heroes.GetLocal()
    if not hero or not Entity.IsAlive(hero) then return end

    local phaseBoots = NPC.GetItem(hero, "item_phase_boots")
    if not phaseBoots then return end

    local mana = NPC.GetMana(hero)
    if mana == nil then return end

    if NPC.IsRunning(hero) and Ability.IsCastable(phaseBoots, mana) then
        Ability.CastNoTarget(phaseBoots)
    end
end

return PhaseBoots
