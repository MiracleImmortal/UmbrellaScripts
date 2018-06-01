local wtfBrist = {}

wtfBrist.IsEnable = Menu.AddOptionBool({"Hero Specific", "WTF+ Bristleback"}, "Enable", false)
wtfBrist.Debug = true

wtfBrist.LastUpdateTime = 0
wtfBrist.UpdateTime = 0.0001

function wtfBrist.OnUpdate()
    if not Menu.IsEnabled(wtfBrist.IsEnable) or not Engine.IsInGame() or not Heroes.GetLocal() then return end

    if ((os.clock() - wtfBrist.LastUpdateTime) < wtfBrist.UpdateTime) then
        return
    end
    wtfBrist.LastUpdateTime = os.clock();

    wtfBrist.MyHero = Heroes.GetLocal()
    if NPC.GetUnitName(wtfBrist.MyHero) ~= "npc_dota_hero_bristleback" then return end
    if not Entity.IsAlive(wtfBrist.MyHero) or NPC.IsStunned(wtfBrist.MyHero) or NPC.IsSilenced(wtfBrist.MyHero) then return end

    local quillSpray = NPC.GetAbility(wtfBrist.MyHero, "bristleback_quill_spray")
    if not quillSpray then return end

    local quillSprayCastRange = Ability.GetCastRange(quillSpray)

    local AllHeroes = Entity.GetUnitsInRadius(wtfBrist.MyHero, quillSprayCastRange, Enum.TeamType.TEAM_ENEMY)
    if not AllHeroes then return end

    for i, hero in pairs(AllHeroes) do
        if hero ~= nil and hero ~= 0 and NPCs.Contains(hero) and NPC.IsEntityInRange(wtfBrist.MyHero, hero, quillSprayCastRange) and not Entity.IsSameTeam(hero, wtfBrist.MyHero) then
            if Entity.IsAlive(hero) and not Entity.IsDormant(hero) and Ability.IsReady(quillSpray) and NPC.GetUnitName(hero) ~= "npc_dota_neutral_caster" then
                if NPC.IsCreep(hero) or NPC.IsIllusion(hero) or NPC.IsHero(hero) or NPC.IsCourier(hero) then
                    if wtfBrist.Debug then Log.Write("Attak! [".. NPC.GetUnitName(hero) .."]") end
                    Ability.CastNoTarget(quillSpray)
                    break
                end
            end
        end
    end
end

return wtfBrist
