class BehemothAIController extends CreatureAIController;

var Pawn        PPawn;
var Actor       Destination;
var vector      knownPos, chargeDist;
var float       tGroundSpeed, speedMultiplier, maxSpeed;

function NextDecision()
{
	switch(Rand(2))
	{
		case 0:
			GotoState('Patrol');
			break;
		case 1:
			GotoState('Idle');
			break;
	}
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	super.NotifyTakeHit(Instigatedby, Hitlocation, Damage, DamageType, Momentum);
	
	PPawn = GetALocalPlayerController().Pawn;
	GotoState('Charge');
}

auto state Idle
{
	// Player is seen - Charge
	event SeePlayer(Pawn Seen)
	{
		super.SeePlayer(Seen);
		PPawn = GetALocalPlayerController().Pawn;
		GotoState('Charge');
	}
Begin:
	Pawn.RotationRate.Yaw = 12000;
	Sleep(2);
	NextDecision();
}

state Patrol
{
	// Player is seen - Charge
	event SeePlayer(Pawn Seen)
	{
		super.SeePlayer(Seen);
		PPawn = GetALocalPlayerController().Pawn;
		GotoState('Charge');
	}
ReturnHome:
	// Move to last known Destination
	Pawn.SetDesiredRotation(Rotator(Destination.Location));
	FinishRotation();
	MoveTo(Destination.Location);
	// Decide Next Action
	NextDecision();
Begin:
	//If we just began or we have reached the Destination
	//pick a new destination - at random
	if(Destination == none || Pawn.ReachedDestination(Destination))
	{
		Destination = FindRandomDest();
	}
	// If we have destination and haven't reached it
	// We must return to path area
	else
	{
		Goto 'ReturnHome';
	}
	
	// Rotate towards destination
	//Pawn.SetDesiredRotation(Rotator(FindPathToward(Destination).Location));
	//FinishRotation();
	While (!Pawn.ReachedDestination(Destination))
	{
		MoveTarget = FindPathToward(Destination);
		//Find a path to the destination and move to the next node in the path
		MoveToward(MoveTarget, MoveTarget,,false);
	}

	NextDecision();
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
	// Look at previous known location
	Pawn.SetDesiredRotation(Rotator(knownPos));
	FinishRotation();
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
		if (PreviousStateName == 'Stunned')
		{
			GotoState('Scanforplayer');
		}
	}

	event EndState(name NextStateName)
	{
		Pawn.GroundSpeed = default.tGroundSpeed;
	}
Begin:
	// Set known player position
	knownPos = PPawn.Location;
	// Set charge distance
	chargeDist = knownPos - Pawn.Location;
	// Move toward Player
	MoveToward(PPawn, PPawn, Abs(VSize2D(chargeDist / 6)), false);
	// Run towards the known position
	MoveTo(Pawn.Location + chargeDist);
	// Look for player again
	GotoState('Scanforplayer');	
}

DefaultProperties
{
	
	// Behemoth Default Values
	speedMultiplier =00020.000000
	maxSpeed        =02000.000000
	tGroundSpeed    =0400.000000
}
