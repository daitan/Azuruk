class WalkingAIPawn extends UDKPawn
	placeable;

DefaultProperties
{ 
    Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMesh
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	ControllerClass=class'AzurukGame.WalkingAIController'
}
