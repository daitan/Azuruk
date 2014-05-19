class VespaPrimaryProjectile extends Projectile;

var class<VespaPrimarySlow> SlowClass;

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( Role == ROLE_Authority )
	{
		MakeNoise(1.0);
	}
	Spawn(SlowClass,self,, HitLocation, Rotator(vect(0,0,0)));
	Destroy();
}

simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	Super.HitWall(HitNormal, Wall, WallComp);

	Explode(Location, HitNormal);
}

simulated singular event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
}

DefaultProperties
{
	SlowClass=class'AzurukGame.VespaPrimarySlow'

	Damage=+0.0
	DamageRadius=0.0

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    Components.Add(MyLightEnvironment)

    begin object class=StaticMeshComponent Name=PawnSkeletalMesh
        StaticMesh=StaticMesh'collision_assets.StaticMesh.Sphere_Collision'
        LightEnvironment=MyLightEnvironment
    end object
 
    Components.Add(PawnSkeletalMesh)
}
