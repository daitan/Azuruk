class VespaPrimarySlow extends Actor;

event Tick(float DeltaTime)
{
	//`log(CreationTime + LifeSpan);
	//if (CreationTime + LifeSpan <= WorldInfo.TimeSeconds )
	//{
	//	Destroy();
	//}
}

singular event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local AzurukPawn aPawn;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	aPawn = AzurukPawn(Other);

	if (aPawn != none && !aPawn.IsPlayerPawn())
	{
		aPawn.MovementSpeedModifier = 0.1;
	}
}

singular event UnTouch( Actor Other )
{
	local AzurukPawn aPawn;

	super.UnTouch(Other);

	aPawn = AzurukPawn(Other);

	if (aPawn != none && !aPawn.IsPlayerPawn())
	{
		aPawn.ResetMovementSpeedModifier();
	}
}

DefaultProperties
{
	LifeSpan=+10.0

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)

    begin object class=StaticMeshComponent Name=PawnSkeletalMesh
        StaticMesh=StaticMesh'collision_assets.StaticMesh.Sphere_Collision'
        LightEnvironment=MyLightEnvironment
    end object
    CollisionComponent=PawnSkeletalMesh
	Components.Add(PawnSkeletalMesh)
	
	DrawScale3D=(X=5,Y=5,Z=0.5)
    bCollideActors=true
    bBlockActors=false
}
