if SERVER then
    AddCSLuaFile()
    ENT.DamageMultiplierZombie = CreateConVar("vetes_dps_dummy_zombie_damage_multiplier", "1.0", FCVAR_ARCHIVE, "This can be used to tune damage accuracy in-case your server has multipliers for players/humans/zombies.")
end

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "DPS Dummy (Zombie)"
ENT.Author = "Vetes"
ENT.Category = "Vetes' NPCs"
ENT.Spawnable = false
ENT.PhysgunDisabled = false
ENT.IconOverride = "entities/vetes/dps_dummy_zombie.vtf"

list.Set("NPC", "npc_vetes_dps_dummy_zombie", { -- Why can't this be done with the entity structure...?
    Name = ENT.PrintName,
    Class = "npc_vetes_dps_dummy_zombie",
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
    self:SetModel("models/zombie/classic.mdl")
    self:SetBodygroup(1, 1)
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
    dmginfo:ScaleDamage(self.DamageMultiplierZombie:GetFloat())
    local amount = dmginfo:GetDamage()
    local now = CurTime()
    local delta = now - (self.LastDmgTime or now)

    -- Smooth decay (approximately 1s window)
    local decay = math.exp(-delta * 6) -- Decays by ~0.002 per second tick
    self:SetDPS(self:GetDPS() * decay + amount)
    self.LastDmgTime = now

    local effect = EffectData()
    effect:SetOrigin(dmginfo:GetDamagePosition())
    util.Effect("MetalSpark", effect)
    self:EmitSound(string.format("physics/metal/metal_solid_impact_bullet%d.wav", math.random(1, 4)), 70, math.random(90, 110), 0.75)
    return 5
end

--[[function ENT:CanPlayerInteractWith(ply)
    return self:Getowning_ent() == ply or self:GetOwner() == ply or (self.CPPIGetOwner and self:CPPIGetOwner() == ply)
end

hook.Add("CanTool", "CanToolVetesDummyZombie", function(ply, tr, toolname, tool, button)
   if toolname == "remover" and IsValid(tr.Entity) and tr.Entity:GetClass() == "npc_vetes_dps_dummy_zombie" and
    tr.Entity.CanPlayerInteractWith and tr.Entity:CanPlayerInteractWith(ply) then
      return true
   end
end)

hook.Add("PhysgunPickup", "PhysgunPickupVetesDummyZombie", function( ply, ent)
    if IsValid(ent) and ent:GetClass() == "npc_vetes_dps_dummy_zombie" and ent.CanPlayerInteractWith and ent:CanPlayerInteractWith(ply) then
        return true
    end
end)]]

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
            draw.SimpleTextOutlined("DPS: " .. math.Round(self:GetDPS()), "DermaLarge", 0, 0, dpsFontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, dpsFontColorOutline)
        cam.End3D2D()
    end
end