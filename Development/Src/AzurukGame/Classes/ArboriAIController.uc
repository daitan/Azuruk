class ArboriAIController extends CreatureAIController;

/**
 * Variables
 */
var                 vector                  RockLocation,
											FootLocation,
											temp_loc;
var                 AzurukPlayerPawn        PPawn;
var                 float                   MeleeDistance, 
											temp_dist;
var                 Actor                   SpawnedObject;
var                 bool                    bCanThrow;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}



auto state Idle
{
	event Tick(float DeltaTime)
	{
		PPawn = AzurukPlayerPawn(GetALocalPlayerController().Pawn);
		if (PPawn.bInArboriBossRegion == true) {
			GotoState('Active');
		}
	}
Begin:
	PPawn = none;
}

//state which decides what to do next
state Active
{
	event Tick(float DeltaTime)
	{
		PPawn = AzurukPlayerPawn(GetALocalPlayerController().Pawn);
		temp_dist = GetDistanceToLocation(PPawn.Location);
		if (PPawn.bInArboriBossRegion == false) {
			GotoState('Idle');
		}
		else if (temp_dist <= MeleeDistance)
		{
			GotoState('StompAttack');
		}
		else if (temp_dist > MeleeDistance)
		{
			//if (PPawn.currentFeatures.pawnMoveType == M_CreatureFlying)
			//{
			//	GotoState('PickupRock');
			//}
			//else 
			//{
			if (bCanThrow)
			{
				GotoState('PickupRock');
			}
			else
			{
				GotoState('MoveToPlayer');
			}
			//}
		}
	}
Begin:
}

state MoveToPlayer
{
Begin:
	MoveToward(GetALocalPlayerController().Pawn, GetALocalPlayerController().Pawn);
	temp_loc = GetALocalPlayerController().Pawn.Location - Pawn.Location;
	Pawn.SetDesiredRotation(Rotator(temp_loc));
	FinishRotation();
	Pawn.SetRotation(Rotator(temp_loc));
	GotoState('StompAttack');
}

state SwipeAttack
{
Begin:
	MoveToward(GetALocalPlayerController().Pawn, GetALocalPlayerController().Pawn);
	ArboriAIPawn(Pawn).GiveWeapon("Swipe");
	Sleep(0.1);
	temp_loc = GetALocalPlayerController().Pawn.Location - Pawn.Location;
	Pawn.SetDesiredRotation(Rotator(temp_loc));
	FinishRotation();
	Pawn.SetRotation(Rotator(temp_loc));
	Pawn.StartFire(0);
	Pawn.StopFire(0);
	Sleep(2.7);
	GotoState('Active');
}

state StompAttack
{
Begin:
	ArboriAIPawn(Pawn).SetPhysics(PHYS_None);
	ArboriAIPawn(Pawn).AttackAnim.PlayCustomAnim('Anim_Arbori_Stomp', 1.0);
	Sleep(0.8);
	ArboriAIPawn(Pawn).Mesh.GetSocketWorldLocationAndRotation('RightFootMiddleToe', FootLocation);
	HurtRadius(20.0, 512.0, class'DamageType', 25000.0, FootLocation, Pawn, self, true);
	Sleep(1.5);
	ArboriAIPawn(Pawn).SetPhysics(PHYS_Walking);
	GotoState('SwipeAttack');
}

state PickupRock
{
Begin:
	ArboriAIPawn(Pawn).SetPhysics(PHYS_None);
	ArboriAIPawn(Pawn).GiveWeapon("Throw");
	ArboriAIPawn(Pawn).AttackAnim.PlayCustomAnim('Anim_Arbori_Pickup', 1.0);
	Sleep(1.7);
	SpawnedObject = Spawn(class'AzurukGame.ArboriRock');
	SpawnedObject.SetBase(Pawn,,Pawn.Mesh, 'HoldItem');
	Sleep(0.3);
	ArboriAIPawn(Pawn).SetPhysics(PHYS_Walking);
	GotoState('ThrowRock');
}

state ThrowRock
{
Begin:
	temp_loc = GetALocalPlayerController().Pawn.Location - Pawn.Location;
	Pawn.SetDesiredRotation(Rotator(temp_loc));
	FinishRotation();
	Pawn.SetRotation(Rotator(temp_loc));
	SetFocalPoint(GetALocalPlayerController().Pawn.Location);
	ArboriAIPawn(Pawn).SetPhysics(PHYS_None);
	ArboriAIPawn(Pawn).AttackAnim.PlayCustomAnim('Anim_Arbori_Throw', 1.0);
	Sleep(0.9);
	SpawnedObject.SetBase(none);
	SpawnedObject.Destroy();
	Pawn.StartFire(0);
	Pawn.StopFire(0);
	Sleep(0.8);
	ArboriAIPawn(Pawn).SetPhysics(PHYS_Walking);
	bCanThrow = false;
	SetTimer(8.0, false, 'ThrowCooldown');
	GotoState('Active');
}

function ThrowCooldown()
{
	bCanThrow = true;
}

//state VineAttack
//{
//Begin:
//	temp_loc = GetALocalPlayerController().Pawn.Location;
//	Sleep(2.0);
//	ArboriAIPawn(Pawn).SetPhysics(PHYS_None);
//	ArboriAIPawn(Pawn).AttackAnim.PlayCustomAnim('Anim_Arbori_Pickup', 1.0);
//	Sleep(2.0);
//	ArboriAIPawn(Pawn).SetPhysics(PHYS_Walking);
//	HurtRadius(1.0, 512.0, class'DamageType', 0.0, temp_loc, Pawn, self, true);
//	GotoState('Active');
//}   

DefaultProperties
{
	bCanThrow=true
	MeleeDistance=448.0
}
