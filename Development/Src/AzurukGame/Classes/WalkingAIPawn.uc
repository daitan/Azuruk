class WalkingAIPawn extends AzurukPawn
	placeable;

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=+30.000000
		CollisionHeight=+50.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

    Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'AzurukContent.SkeletalMeshes.frank'
		AnimSets[0]=AnimSet'AzurukContent.AnimSets.FrankAnims'
		AnimTreeTemplate=AnimTree'AzurukContent.AnimTrees.FrankAnimTree'
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	ControllerClass=class'AzurukGame.WalkingAIController'
}
