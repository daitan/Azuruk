class WalkingAIPawn extends AzurukPawn
	placeable;

DefaultProperties
{ 
    Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'AzurukContent.SkeletalMesh.SK_Crowd_Robot'
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	ControllerClass=class'AzurukGame.WalkingAIController'
}
