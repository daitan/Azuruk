class ArboriAIController extends CreatureAIController;

/**
 * Variables
 */
var     vector              RockLocation,
							temp_loc;
var     AzurukPlayerPawn    PPawn;
var     float               MeleeDistance, 
							temp_dist;

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
			GotoState('Reset');
		}
		else if (temp_dist <= MeleeDistance)
		{
			GotoState('MeleeAttack');
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

state MeleeAttack
{
	//TODO
	event OnAnimPlay (AnimNodeSequence SeqNode)
	{
		//Attach physics volume to socket
	}

	event OnAnimEnd (AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		//Destroy physics volume
		GotoState('Active');
	}
	//SMC.PlayAnim('',,false);
}

state ThrowRock
{
	//TODO
	//SMC.PlayAnim('',,false);
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
}

DefaultProperties
{
}
