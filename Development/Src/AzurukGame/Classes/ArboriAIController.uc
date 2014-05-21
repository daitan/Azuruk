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
			`log('Swipe');
			GotoState('SwipeAttack');
		}
		else if (temp_dist > MeleeDistance)
		{
			if (PPawn.currentFeatures.pawnMoveType == M_CreatureFlying)
			{
				GotoState('ThrowRock');
			}
			else 
			{
				GotoState('VineAttack');
			}
		}
	}
Begin:
}

state SwipeAttack
{
Begin:
	ArboriAIPawn(Pawn).GiveWeapon("Swipe");
	Sleep(0.1);
	temp_loc = GetALocalPlayerController().Pawn.Location - Pawn.Location;
	Pawn.SetDesiredRotation(Rotator(temp_loc));
	FinishRotation();
	Pawn.SetRotation(Rotator(temp_loc));
	Pawn.StartFire(0);
	Pawn.StopFire(0);
	Sleep(2.7);
	GotoState('StompAttack');
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
	GotoState('Active');
}

state ThrowRock
{
	//TODO
	//SMC.PlayAnim('',,false);
Begin:
	GotoState('Active');
}

state VineAttack
{
Begin:
	Sleep(2.0);
	//HurtRadius(1.0, 512.0, class'DamageType', 0.0, GetALocalPlayerController().Pawn.Location, Pawn, self, true);
	GotoState('Active');
}

DefaultProperties
{
	MeleeDistance=448.0
}
