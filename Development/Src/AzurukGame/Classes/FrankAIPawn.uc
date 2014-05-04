class FrankAIPawn extends AzurukPawn
	placeable;

function AddDefaultInventory()
{
	InvManager.CreateInventory(class'AzurukGame.FrankPrimaryAttack');
}

event PostBeginPlay()
{
	super.PostBeginPlay();
	AddDefaultInventory();
	defaultFeatures.CreatureName = "Frank";
}

DefaultProperties
{
	defaultMoveType = M_CreatureWalking

    Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'Creatures_Frank.SkeletalMeshes.frank'
		AnimSets[0]=AnimSet'Creatures_Frank.AnimSet.FrankAnims'
		AnimTreeTemplate=AnimTree'Creatures_Frank.AnimTree.FrankAnimTree'
		LightEnvironment=PawnLightEnvironment
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	InventoryManagerClass=class'AzurukGame.CreatureInventoryManager'
	ControllerClass=class'AzurukGame.FrankAIController'
}
