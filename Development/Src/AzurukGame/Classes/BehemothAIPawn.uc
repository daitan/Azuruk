class BehemothAIPawn extends AzurukPawn
	placeable;

event PostBeginPlay()
{
	super.PostBeginPlay();
	defaultFeatures.CreatureName = "Behemoth";
}

DefaultProperties
{
	defaultMoveType = M_Behemoth

	GroundSpeed = 400.00
	RotationRate=(Pitch=50000000,Yaw=50000000,Roll=50000000)

    Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'Creatures_Behemoth.SkeletalMeshes.Skel_Behemoth'
		AnimSets[0]=AnimSet'Creatures_Behemoth.AnimSet.behemothArmature'
		AnimTreeTemplate=AnimTree'Creatures_Behemoth.AnimTree.behemothAnimTree'
		PhysicsAsset=PhysicsAsset'Creatures_Behemoth.PhysicsAsset.Skel_Behemoth_Physics'
		LightEnvironment=PawnLightEnvironment
		BlockActors=true
        CollideActors=true
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	InventoryManagerClass=class'AzurukGame.CreatureInventoryManager'
	ControllerClass=class'AzurukGame.BehemothAIController'
}
