class BehemothAIController extends CreatureAIController;

var Pawn PPawn;

var vector knownPos, targetPos;

auto state Patrol
{
	// Player is seen - Charge
	event SeePlayer(Pawn Seen)
	{
		super.SeePlayer(Seen);
		PPawn = GetALocalPlayerController().Pawn;
		GotoState('Charge');
	}

	// Patrol around area
}

state Scanforplayer
{
	// Player is seen - Charge
	event SeePlayer(Pawn Seen)
	{
		super.SeePlayer(Seen);
		PPawn = GetALocalPlayerController().Pawn;
		GotoState('Charge');
	}
Begin:
	// Walk to previous known location

	// Look around

	// If not found after time - goto Patrol
}

state Charge
{
	event Tick(float DeltaTime)
	{
		`log((Pawn.Location - targetPos));
		// Charge towards until location > chargeDist + known position
		if (Vsize(Pawn.Location - targetPos) > 1)
		{
			Pawn.Velocity = Normal(targetPos) * Pawn.GroundSpeed;
			Pawn.SetRotation(Rotator(targetPos));
			Pawn.Move(Pawn.Velocity * DeltaTime);
		}
		else
		{
			// Goto Scan for player
			GotoState('Scanforplayer');
		}
	}

	event BeginState(name PreviousStateName)
	{
		// Set known player position
		knownPos = PPawn.Location;
		// Set target position
		targetPos = knownPos - Pawn.Location;
	}

	event EndState(name NextStateName)
	{
		PPawn = none;
	}
}

DefaultProperties
{
}
