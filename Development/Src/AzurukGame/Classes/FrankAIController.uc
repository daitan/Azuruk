class FrankAIController extends CreatureAIController;

/*
 * Variables
 */
var Actor target;
var float minimumDistance, minimumPrimaryAttackDistance, objectScanDistance,
	distanceToPlayer, speed;
var vector tempLoc;
var Pawn PPawn;
var ObjectPhysics closestUsableObject;
var bool bCanFire;

/**
 * Find usable object, returns -1 if no object found
 */
function ObjectPhysics FindUsableObject() {
	local ObjectPhysics checkObject;
	local ObjectPhysics closestObject;
	local float objTempDist;
	local float objDistanceToPlayer;
	local vector objTempLoc;

	objDistanceToPlayer = -1.0;

	foreach Pawn.CollidingActors(class'AzurukGame.ObjectPhysics',checkObject,objectScanDistance)
	{
		if (checkObject.bFrankUsable == true) 
		{
			objTempLoc = Pawn.Location - checkObject.Location;
			objTempDist = Abs(VSize(objTempLoc));
			
			//Get the closest object
			if (objTempDist == -1.0) 
			{
				objDistanceToPlayer = objTempDist;
				closestObject = checkObject;
			}
			else if (objTempDist < objDistanceToPlayer)
			{
				objDistanceToPlayer = objTempDist;
				closestObject = checkObject;
			}
		}
	}

	return closestObject;
}
 
auto state Idle
{
	event SeePlayer(Pawn P)
	{
		PPawn = GetALocalPlayerController().Pawn;
		GotoState('FindShootableObject');
	}
Begin:
	PPawn = none;
}

state FindShootableObject
{
Begin:
	closestUsableObject = FindUsableObject();
	if (closestUsableObject == none) 
	{
		GotoState('Flee');
	} 
	else 
	{
		MoveToward(closestUsableObject,, 56.0);
		closestUsableObject = none;
		GotoState('ShootObject');
	}
}

state ShootObject
{
Begin:
	GotoState('FindShootableObject');
}

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
		} else if (distanceToPlayer <= minimumPrimaryAttackDistance) {
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
	event Tick(float DeltaTime)
	{
		tempLoc = Pawn.Location - PPawn.Location;
		distanceToPlayer = Abs(VSize(tempLoc));
	}

Begin:
	Pawn.ZeroMovementVariables();
	while (distanceToPlayer <= minimumPrimaryAttackDistance) {
		Sleep(1.0);
		Pawn.LockDesiredRotation(false);
		Pawn.SetDesiredRotation(Rotator(PPawn.Location - Pawn.Location));
		Pawn.LockDesiredRotation(true, false);
		Pawn.StartFire(0);
		Pawn.StopFire(0);
	}
	GotoState('Flee');
}

DefaultProperties
{
	bCanFire=false
	objectScanDistance=512.0
	minimumDistance=1024.0
	minimumPrimaryAttackDistance=256.0
	speed=200.0
}