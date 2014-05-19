class VespaPrimaryAttack extends Weapon;

simulated event vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local SkeletalMeshComponent sComp;
	local SkeletalMeshSocket sSocket;

	sComp = AzurukPawn(Owner).Mesh;

	if (sComp != none)
	{
		sSocket = sComp.GetSocketByName('ShootSocket');

		if (sSocket != none)
		{
			return sComp.GetBoneLocation(sSocket.BoneName);
		}
	}
}

DefaultProperties
{
	WeaponProjectiles(0)=class'AzurukGame.VespaPrimaryProjectile'
	FiringStatesArray(0)=WeaponFiring
    WeaponFireTypes(0)=EWFT_Projectile
    FireInterval(0)=3.0
    Spread(0) = 0.0
}
