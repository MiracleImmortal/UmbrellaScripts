local CrystalMaiden = {}

CrystalMaiden.optionEnable        = Menu.AddOptionBool({ "Hero Specific", "Crystal Maiden" }, "Enable", false)
CrystalMaiden.optionKey           = Menu.AddKeyOption({ "Hero Specific", "Crystal Maiden" }, "Combo Key", Enum.ButtonCode.KEY_1)

CrystalMaiden.optionEscapeGlimmer = Menu.AddOptionBool({ "Hero Specific", "Crystal Maiden", "Auto escape" }, "Glimmer", false)

-- CrystalMaiden.AddBKB           = Menu.AddOptionBool({"Hero Specific", "Crystal Maiden", "Combo skills"}, "Crystal Nova", false)

CrystalMaiden.AddBKB              = Menu.AddOptionBool({"Hero Specific", "Crystal Maiden", "Combo items"}, "BKB", false)
CrystalMaiden.AddGlimmer          = Menu.AddOptionBool({"Hero Specific", "Crystal Maiden", "Combo items"}, "Glimmer", false)
CrystalMaiden.AddShiva            = Menu.AddOptionBool({"Hero Specific", "Crystal Maiden", "Combo items"}, "Shiva", false)

CrystalMaiden.optionDebug         = Menu.AddOptionBool({ "Hero Specific", "Crystal Maiden" }, "Debug", false)

local last_cast_time = 0

function CrystalMaiden.OnUpdate()
    if not Menu.IsEnabled(CrystalMaiden.optionEnable) then return end

    local MyHero = Heroes.GetLocal()
    if not MyHero or NPC.GetUnitName(MyHero) ~= "npc_dota_hero_crystal_maiden" then return end
    if not Entity.IsAlive(MyHero) or NPC.IsStunned(MyHero) or NPC.IsSilenced(MyHero) then return end

    if Menu.IsEnabled(CrystalMaiden.optionEscapeGlimmer) then
        if (os.clock() - last_cast_time) <= (10 + 3) then
            local manaCount = NPC.GetMana(MyHero)
            if not manaCount then return end

            local glimmer = NPC.GetItem(MyHero, "item_glimmer_cape")
            if not glimmer then return end

            local glimmerManaCost = Ability.GetManaCost(glimmer)
            if not glimmerManaCost then return end

            if Ability.IsCastable(glimmer, manaCount) and Ability.IsReady(glimmer) then
                Ability.CastTarget(glimmer, MyHero, true)
                return
            end
        end
    end

    if Menu.IsKeyDownOnce(CrystalMaiden.optionKey) then CrystalMaiden.Combo(MyHero) end
end

function CrystalMaiden.Combo(MyHero)
    local freezingField = NPC.GetAbility(MyHero, "crystal_maiden_freezing_field")
    -- local crystalNova   = NPC.GetAbility(MyHero, "crystal_maiden_crystal_nova")
    local bkb           = NPC.GetItem(MyHero, "item_black_king_bar")
    local glimmer       = NPC.GetItem(MyHero, "item_glimmer_cape")
    local shiva         = NPC.GetItem(MyHero, "item_shivas_guard")

    if not freezingField then return end

    CrystalMaiden.manaCount = NPC.GetMana(MyHero)
    CrystalMaiden.realManaCount = CrystalMaiden.manaCount
    if not CrystalMaiden.manaCount then return end

    freezingFieldManaCost = Ability.GetManaCost(freezingField)
    if not freezingFieldManaCost then return end

    CrystalMaiden.manaCount = CrystalMaiden.manaCount-freezingFieldManaCost
    CrystalMaiden.ManaNeed = CrystalMaiden.GetManaNeed(MyHero, bkb, glimmer, shiva)

    if CrystalMaiden.manaCount >= CrystalMaiden.ManaNeed then
        if bkb and Menu.IsEnabled(CrystalMaiden.AddBKB) and Ability.IsCastable(bkb, CrystalMaiden.manaCount) and Ability.IsReady(bkb) then
            -- if Menu.IsEnabled(CrystalMaiden.optionDebug) then Log.Write("Use BKB") end
            Ability.CastNoTarget(bkb, true)
        end

        if glimmer and Menu.IsEnabled(CrystalMaiden.AddGlimmer) and Ability.IsCastable(glimmer, CrystalMaiden.manaCount) and Ability.IsReady(glimmer) then
            -- if Menu.IsEnabled(CrystalMaiden.optionDebug) then Log.Write("Use Glimmer cape") end
            Ability.CastTarget(glimmer, MyHero, true)
        end

        if shiva and Menu.IsEnabled(CrystalMaiden.AddShiva) and Ability.IsCastable(shiva, CrystalMaiden.manaCount) and Ability.IsReady(shiva) then
            -- if Menu.IsEnabled(CrystalMaiden.optionDebug) then Log.Write("Use Shiva's guard") end
            Ability.CastNoTarget(shiva, true)
        end
    end

    -- if Menu.IsEnabled(CrystalMaiden.optionDebug) then Log.Write("Cat Ult") end
    if freezingField and Ability.IsCastable(freezingField, CrystalMaiden.realManaCount) and Ability.IsReady(freezingField) then
        Ability.CastNoTarget(freezingField, true)
        last_cast_time = os.clock()
    end
end

function CrystalMaiden.GetManaNeed(MyHero, bkb, glimmer, shiva)
    local mana = 0

    if bkb and Menu.IsEnabled(CrystalMaiden.AddBKB) then
        mana = mana + Ability.GetManaCost(bkb)
    end

    if glimmer and Menu.IsEnabled(CrystalMaiden.AddGlimmer) then
        mana = mana + Ability.GetManaCost(glimmer)
    end

    if shiva and Menu.IsEnabled(CrystalMaiden.AddShiva) then
        mana = mana + Ability.GetManaCost(shiva)
    end

    return mana
end

return CrystalMaiden
