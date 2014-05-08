class VespaAIPawn extends AzurukPawn
	placeable;

event PostBeginPlay()
{
	super.PostBeginPlay();
	defaultFeatures.CreatureName = "Vespa";
}


DefaultProperties
{
	defaultMoveType = M_CreatureFlying

    Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'creatures_Vespa.SkeletalMesh.vespaCreature'
		AnimSets[0]=AnimSet'creatures_Vespa.AnimSet.vespa_Anims'
		AnimTreeTemplate=AnimTree'creatures_Vespa.AnimTree.vespa_AnimTree'
		PhysicsAsset=PhysicsAsset'creatures_Vespa.PhysicsAsset.vespa_Physics'
		LightEnvironment=PawnLightEnvironment
		BlockActors=true
        CollideActors=true
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	InventoryManagerClass=class'AzurukGame.CreatureInventoryManager'
	ControllerClass=class'AzurukGame.VespaAIController'
}
