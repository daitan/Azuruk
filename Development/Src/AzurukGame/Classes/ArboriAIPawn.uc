class ArboriAIPawn extends AzurukPawn
	placeable;

var                 AnimNodePlayCustomAnim  AttackAnim;
//function AddDefaultInventory()
//{
//	InvManager.CreateInventory(class'AzurukGame.FrankPrimaryAttack');
//}

event PostBeginPlay()
{
	super.PostBeginPlay();
	//AddDefaultInventory();
	AttackAnim = AnimNodePlayCustomAnim(Mesh.FindAnimNode('IdleCustom'));
	defaultFeatures.CreatureName = "Arbori";
}

function GiveWeapon(string weaponName)
{
	switch (weaponName)
	{
		case "Swipe":
			InvManager.DiscardInventory();
			InvManager.CreateInventory(class'ArboriSwipeWeapon');
			break;
		case "None":
			InvManager.DiscardInventory();
			break;
		default:
			InvManager.DiscardInventory();
			break;
	}
}

DefaultProperties
{
	defaultMoveType = M_CreatureWalking 

    Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'Creature_Boss_Arbori.Creature_Boss.Skel_Arbori'
		AnimSets[0]=AnimSet'Creature_Boss_Arbori.Creature_Boss.Arbori_AnimSet'
		AnimTreeTemplate=AnimTree'Creature_Boss_Arbori.AnimTree.ArboriAnimTree'
		LightEnvironment=PawnLightEnvironment
    End Object
    Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)

	InventoryManagerClass=class'AzurukGame.CreatureInventoryManager'
	ControllerClass=class'AzurukGame.ArboriAIController'
}
