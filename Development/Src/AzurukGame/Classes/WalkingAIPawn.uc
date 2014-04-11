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
		SkeletalMesh=SkeletalMesh'Creatures_Frank.SkeletalMeshes.frank'
		AnimSets[0]=AnimSet'Creatures_Frank.AnimSet.FrankAnims'
		AnimTreeTemplate=AnimTree'Creatures_Frank.AnimTree.FrankAnimTree'
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	ControllerClass=class'AzurukGame.WalkingAIController'
}
