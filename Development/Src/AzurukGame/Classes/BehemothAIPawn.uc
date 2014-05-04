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
		SkeletalMesh=SkeletalMesh'Creatures_Behemoth.SkeletalMeshes.Skel_Behemoth'
		AnimSets[0]=AnimSet'Creatures_Behemoth.AnimSet.behemothArmature'
		AnimTreeTemplate=AnimTree'Creatures_Behemoth.AnimTree.behemothAnimTree'
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	InventoryManagerClass=class'AzurukGame.CreatureInventoryManager'
	ControllerClass=class'AzurukGame.BehemothAIController'
}
