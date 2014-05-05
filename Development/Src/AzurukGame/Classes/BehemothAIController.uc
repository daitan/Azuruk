class BehemothAIController extends CreatureAIController;

var Pawn        PPawn;
var Actor       Destination;
var vector      knownPos, chargeDist;
var float       tGroundSpeed, speedMultiplier, maxSpeed;

auto state Patrol
{
	// Player is seen - Charge
	event SeePlayer(Pawn Seen)
	{
		super.SeePlayer(Seen);
		PPawn = GetALocalPlayerController().Pawn;
		GotoState('Charge');
	}
Begin:
	////If we just began or we have reached the Destination
	////pick a new destination - at random
	//if(Destination == none || Pawn.ReachedDestination(Destination))
	//{
	//	Destination = FindRandomDest();
	//}
	////Find a path to the destination and move to the next node in the path
	//MoveToward(FindPathToward(Destination), FindPathToward(Destination));
	//// Loop until playerseen
	//Goto 'Begin';
}

state Scanforplayer extends Patrol
{
Begin:
	// Look at previous known location
	Pawn.SetRotation(Rotator(knownPos));
	// Goto Patrol
	GotoState('Patrol');
}

state Charge
{
	event Tick(float DeltaTime)
	{
		if (!IsZero(Normal(Pawn.Velocity)))
		{
			// Increase Speed
			tGroundSpeed += speedMultiplier;
			Pawn.GroundSpeed = fclamp(tGroundSpeed, Pawn.GroundSpeed, maxSpeed);
		}
		else
		{
			Pawn.GroundSpeed = default.tGroundSpeed;
		}
	}

	event BeginState(name PreviousStateName)
	{
		// Set known player position
		knownPos = PPawn.Location;
		// Set charge distance
		chargeDist = knownPos - Pawn.Location;
	}

	event EndState(name NextStateName)
	{
		PPawn = none;
	}
Begin:
	// Run towards the known position
	MoveTo(knownPos + chargeDist);
	// Look for player again
	GotoState('Scanforplayer');
}

DefaultProperties
{
	// Behemoth Default Values
	speedMultiplier=00005.000000
	maxSpeed=01000.000000
	tGroundSpeed=0600.000000
}
