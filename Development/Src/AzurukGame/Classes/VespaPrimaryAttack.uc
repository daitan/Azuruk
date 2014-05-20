class VespaPrimaryAttack extends Weapon;

var AzurukPlayerController otherController;
var AzurukPawn otherPawn;

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	super.ClientGivenTo(NewOwner, bDoNotActivate);
	otherPawn = AzurukPawn(Owner);
	otherController = AzurukPlayerController(otherPawn.GetALocalPlayerController());
}

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

simulated function Projectile ProjectileFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		AimDir = Vector(GetAdjustedAim( StartTrace ));

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
		}
		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( AimDir );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

simulated state WeaponFiring
{
Begin:
	otherPawn.SetPhysics(PHYS_None);
	otherPawn.customAnim.PlayCustomAnimByDuration('flyingCreature_shoot', 1.0, 0.1, 0.1, false, false);
	FinishAnim(otherPawn.customAnim.GetCustomAnimNodeSeq());
	otherPawn.SetPhysics(PHYS_Flying);
}

DefaultProperties
{
	WeaponProjectiles(0)=class'AzurukGame.VespaPrimaryProjectile'
	FiringStatesArray(0)=WeaponFiring
    WeaponFireTypes(0)=EWFT_Projectile
    FireInterval(0)=3.0
    Spread(0) = 0.0
}
