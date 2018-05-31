local PhaseBoots = {}

PhaseBoots.Enable = Menu.AddOptionBool({"Utility", "Auto Phase Boots"}, "Enable", false)

function PhaseBoots.OnUpdate()
    local hero = Heroes.GetLocal()
    if hero and Entity.IsAlive(hero) then
        local phaseBoots = NPC.GetItem(hero, "item_phase_boots")
        if Menu.IsEnabled(PhaseBoots.Enable) and NPC.IsRunning(hero) and Ability.IsCastable(phaseBoots, NPC.GetMana(hero)) then
            Ability.CastNoTarget(phaseBoots)
        end
    end
end

return PhaseBoots
