local CrystalMaiden = {}

CrystalMaiden.optionEnable = Menu.AddOptionBool({ "Hero Specific", "Crystal Maiden" }, "Enable", false)
CrystalMaiden.optionKey = Menu.AddKeyOption({ "Hero Specific", "Crystal Maiden" }, "Combo Key", Enum.ButtonCode.KEY_1)

CrystalMaiden.AddBKB = Menu.AddOptionBool({"Hero Specific", "Crystal Maiden", "Combo"}, "BKB", false)
CrystalMaiden.AddGlimmer = Menu.AddOptionBool({"Hero Specific", "Crystal Maiden", "Combo"}, "Glimmer", false)

local combo_start = false
local combo_bkb = false
local combo_ult = false
local combo_glimmer = false

function CrystalMaiden.OnUpdate()
    if not Menu.IsEnabled(CrystalMaiden.optionEnable) then return end

    local MyHero = Heroes.GetLocal()

    if not MyHero or NPC.GetUnitName(MyHero) ~= "npc_dota_hero_crystal_maiden" then return end
    if not Entity.IsAlive(MyHero) or NPC.IsStunned(MyHero) or NPC.IsSilenced(MyHero) then return end

    if Menu.IsKeyDownOnce(CrystalMaiden.optionKey) then CrystalMaiden.Combo(MyHero) end
end

function CrystalMaiden.Combo(MyHero)
    local freezingField = NPC.GetAbility(MyHero, "crystal_maiden_freezing_field")
    local bkb           = NPC.GetItem(MyHero, "item_black_king_bar")
    local glimmer       = NPC.GetItem(MyHero, "item_glimmer_cape")

    local manaCount = NPC.GetMana(MyHero)

    local manaNeed = CrystalMaiden.GetManaNeed(MyHero, freezingField, bkb, glimmer)
    if manaNeed==nil then return end

    if not combo_start and manaCount >= manaNeed then
        combo_start = true
    end

    if combo_start then
        if not combo_bkb and bkb and Menu.IsEnabled(CrystalMaiden.AddBKB) and Ability.IsCastable(bkb, manaCount) and Ability.IsReady(bkb) then
            Ability.CastNoTarget(bkb, true)
            combo_bkb = true
        end

        if not combo_ult and freezingField and Menu.IsEnabled(CrystalMaiden.AddGlimmer) and Ability.IsCastable(freezingField, manaCount) and Ability.IsReady(freezingField) then
            Ability.CastNoTarget(freezingField, true)
            combo_ult = true
        end

        if not combo_glimmer and glimmer and Menu.IsEnabled(CrystalMaiden.AddGlimmer) and Ability.IsCastable(glimmer, manaCount) and Ability.IsReady(glimmer) then
            Ability.CastTarget(glimmer, MyHero)
            combo_glimmer = true
        end

        if combo_start and combo_bkb and combo_glimmer and combo_ult then
            combo_start = false
            combo_bkb = false
            combo_glimmer = false
            combo_ult = false
        end
    end
end

function CrystalMaiden.GetManaNeed(MyHero, freezingField, bkb, glimmer)
    local mana = 0

    if not freezingField then return nil end
    mana = mana + Ability.GetManaCost(freezingField)

    if not bkb then return nil end
    if bkb and Menu.IsEnabled(CrystalMaiden.AddBKB) then
        mana = mana + Ability.GetManaCost(bkb)
    end

    if not glimmer then return nil end
    if glimmer and Menu.IsEnabled(CrystalMaiden.AddGlimmer) then
        mana = mana + Ability.GetManaCost(glimmer)
    end

    return mana
end

return CrystalMaiden
