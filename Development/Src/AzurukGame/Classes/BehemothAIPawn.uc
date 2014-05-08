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

	GroundSpeed = 300.00

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
