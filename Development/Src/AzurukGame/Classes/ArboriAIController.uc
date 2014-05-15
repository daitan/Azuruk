class ArboriAIController extends CreatureAIController;

/**
 * Variables
 */
var                 vector                  RockLocation,
											temp_loc;
var                 AzurukPlayerPawn        PPawn;
var                 float                   MeleeDistance, 
											temp_dist;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}



state Idle
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
auto state Active
{
	event Tick(float DeltaTime)
	{
		PPawn = AzurukPlayerPawn(GetALocalPlayerController().Pawn);
		temp_dist = GetDistanceToLocation(PPawn.Location);
		`log("Active, "$temp_dist);
		/*if (PPawn.bInArboriBossRegion == false) {
			GotoState('Reset');
		}
		else */if (temp_dist <= MeleeDistance)
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
	Sleep(0.5);
	Pawn.StartFire(0);
	Pawn.StopFire(0);
	`log("fire");
	Sleep(1.0);
	GotoState('StompAttack');
}

state StompAttack
{
	event OnAnimPlay(AnimNodeSequence SeqNode)
	{
		
	}

	event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		GotoState('Active');
	}
Begin:
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
	//TODO
	event OnAnimPlay (AnimNodeSequence SeqNode)
	{
		//Create physics volume at target location
		//**OR**
		//Do damage to player at selected location in specified radius
	}

	event OnAnimEnd (AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		GotoState('Active');
	}
	//SMC.PlayAnim('',,false);
Begin:
	GotoState('Active');
}

DefaultProperties
{
	MeleeDistance=150.0
}
