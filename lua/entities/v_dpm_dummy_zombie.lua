if SERVER then
    AddCSLuaFile()
end

ENT.Base = "v_dps_dummy_human"
ENT.Type = "ai"
ENT.PrintName = "DPM Dummy (Zombie)"
ENT.Author = "Vetes"
ENT.Category = "Vetes' NPCs"
ENT.Spawnable = false
ENT.PhysgunDisabled = false
ENT.IconOverride = "entities/vetes/dps_dummy_zombie.vtf"
ENT.DummyDamagePerMinute = true
ENT.DummyIsZombie = true

list.Set("NPC", "v_dpm_dummy_zombie", { -- Why can't this be done with the entity structure...?
    Name = ENT.PrintName,
    Class = "v_dpm_dummy_zombie",
    Category = ENT.Category,
    IconOverride = ENT.IconOverride
})