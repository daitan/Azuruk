class ArboriPrimaryProjectile extends Projectile;

DefaultProperties

{
	Damage=+10.0
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
