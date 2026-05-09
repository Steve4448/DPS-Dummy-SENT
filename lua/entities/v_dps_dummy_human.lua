if SERVER then
    AddCSLuaFile()
    ENT.DamageMultiplierHuman = CreateConVar("v_dummy_human_damage_multiplier", "1.0", FCVAR_ARCHIVE, "This can be used to tune damage accuracy in-case your server has multipliers for players/humans/zombies.")
    ENT.DamageMultiplierZombie = CreateConVar("v_dummy_zombie_damage_multiplier", "1.0", FCVAR_ARCHIVE, "This can be used to tune damage accuracy in-case your server has multipliers for players/humans/zombies.")
end

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "DPS Dummy (Human)"
ENT.Author = "Vetes"
ENT.Category = "Vetes' NPCs"
ENT.Spawnable = false
ENT.PhysgunDisabled = false
ENT.IconOverride = "entities/vetes/dps_dummy_human.vtf"
ENT.DummyDamagePerMinute = false
ENT.DummyIsZombie = false

list.Set("NPC", "v_dps_dummy_human", { -- Why can't this be done with the entity structure...?
    Name = ENT.PrintName,
    Class = "v_dps_dummy_human",
    Category = ENT.Category,
    IconOverride = ENT.IconOverride
})

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent") -- DarkRP support
    self:NetworkVar("Float", 0, "DPS")
end

function ENT:Initialize()
    self:SetDPS(0)
    if CLIENT then return end
    if self.DummyIsZombie then
        self:SetModel("models/zombie/classic.mdl")
    else
        self:SetModel(string.format("models/humans/group01/male_0%d.mdl", math.random(1, 9)))
    end
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT) -- disables AI thinking
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE) -- can't move
    self:SetUseType(SIMPLE_USE)
    self:SetMaxHealth(999999)
    self:SetHealth(999999)
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    self:DropToFloor()
    self.LastDmgTime = CurTime()
    if self.CPPIGetOwner and IsValid(self:Getowning_ent()) then -- DarkRP support to allow tool gun/phys gun
        self:CPPISetOwner(self:Getowning_ent())
    end
end

function ENT:OnTakeDamage(dmginfo)
    if self.DummyIsZombie then
        dmginfo:ScaleDamage(self.DamageMultiplierZombie:GetFloat())
    else
        dmginfo:ScaleDamage(self.DamageMultiplierHuman:GetFloat())
    end
    local amount = dmginfo:GetDamage()
    local now = CurTime()
    local delta = now - (self.LastDmgTime or now)

    local decayRate = self.DummyDamagePerMinute and 0.1 or 6 -- 0.1 gives ~60s time constant, 6 gives ~0.166s
    local decay = math.exp(-delta * decayRate)
    self:SetDPS(self:GetDPS() * decay + amount)
    self.LastDmgTime = now

    local effect = EffectData()
    effect:SetOrigin(dmginfo:GetDamagePosition())
    util.Effect("MetalSpark", effect)
    self:EmitSound(string.format("physics/metal/metal_solid_impact_bullet%d.wav", math.random(1, 4)), 70, math.random(90, 110), 0.75)
end

if CLIENT then
    local dpsFontColor = Color(255, 50, 50)
    local dpsFontColorOutline = Color(0, 0, 0)
    function ENT:Draw()
        self:DrawModel()

        local pos = self:GetPos() + Vector(0, 0, 85)
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), -90)

        cam.Start3D2D(pos, ang, 0.15)
            if self.DummyDamagePerMinute then
                draw.SimpleTextOutlined("DPM: " .. math.Round(self:GetDPS()), "DermaLarge", 0, 0, dpsFontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, dpsFontColorOutline)
            else
                draw.SimpleTextOutlined("DPS: " .. math.Round(self:GetDPS()), "DermaLarge", 0, 0, dpsFontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, dpsFontColorOutline)
            end
        cam.End3D2D()
    end
end