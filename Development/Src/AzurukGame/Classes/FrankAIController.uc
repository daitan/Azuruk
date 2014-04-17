class FrankAIController extends AIController;

/*
 * Variables
 */
var Actor target;
var float minimumDistance, minimumDefaultAttackDistance,
	distanceToPlayer, speed;
var vector tempLoc;
var Pawn PPawn;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}
 
auto state Idle
{
	event SeePlayer(Pawn P)
	{
		PPawn = P;
		GotoState('Flee');
	}
Begin:
	PPawn = none;
}

//state FindObject
//{

//}

//state ShootObject
//{

//}

state Flee
{
	event PlayerOutOfReach()
	{
		GotoState('Idle');
	}

	event Tick(float DeltaTime)
	{
		tempLoc = Pawn.Location - PPawn.Location;
		distanceToPlayer = Abs(VSize(tempLoc));
		if (distanceToPlayer > minimumDistance) {
			PlayerOutOfReach();
		} else if (distanceToPlayer <= minimumDefaultAttackDistance) {
			GotoState('KnockbackPlayer');
		} else {
			Pawn.Velocity = Normal(tempLoc) * speed;
			Pawn.SetRotation(Rotator(tempLoc));
			Pawn.Move(Pawn.Velocity*DeltaTime);
		}
	}
}

state KnockbackPlayer
{
	function Aim()
	{
		local Rotator final_rot;
		final_rot = Rotator(PPawn.Location);
		Pawn.SetRotation(final_rot);
		Pawn.SetViewRotation(final_rot);
	}

	Begin:
		Pawn.ZeroMovementVariables();
		while (distanceToPlayer <= minimumDefaultAttackDistance) {
			Sleep(0.3);
			Aim();
			Pawn.StartFire(0);
			Pawn.StopFire(0);
		}
		GotoState('Flee');
}

DefaultProperties
{
	minimumDistance = 1024.0;
	minimumDefaultAttackDistance = 256.0;
	speed = 200.0;
}