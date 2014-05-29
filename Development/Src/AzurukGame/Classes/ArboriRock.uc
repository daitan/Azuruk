class ArboriRock extends Actor;

DefaultProperties
{
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
