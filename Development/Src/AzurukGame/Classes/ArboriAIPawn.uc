class ArboriAIPawn extends AzurukPawn
	placeable;

//function AddDefaultInventory()
//{
//	InvManager.CreateInventory(class'AzurukGame.FrankPrimaryAttack');
//}

//event PostBeginPlay()
//{
//	super.PostBeginPlay();
//	AddDefaultInventory();
//}

DefaultProperties
{
	defaultMoveType = M_DefaultWalking

	RotationRate=(Pitch=20000,Yaw=60000,Roll=20000)

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
		SkeletalMesh=SkeletalMesh''
		AnimSets[0]=AnimSet''
		AnimTreeTemplate=AnimTree''
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	InventoryManagerClass=class'AzurukGame.CreatureInventoryManager'
	ControllerClass=class'AzurukGame.ArboriAIController'
}
