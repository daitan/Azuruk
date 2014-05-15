class CreatureAIController extends AIController;

var SkeletalMeshComponent SMC;
var float stunnedTime;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
	SMC = Pawn.Mesh;
}

function float GetDistanceToLocation(vector target)
{
	local vector loc;
	loc = Pawn.Location - target;
	return Abs(VSize(loc));
}

function StartResetHealth()
{
	SetTimer(1.0, true, 'ResetHealth');
}

function StopResetHealth()
{
	ClearTimer('ResetHealth');
}

function ResetHealth()
{
	local float regenAmount;
	if (Pawn.Health < Pawn.HealthMax)
	{
		regenAmount = Pawn.HealthMax * 0.2;
		Pawn.HealDamage(regenAmount, self, class'DamageType');
	}
	else
	{
		StopResetHealth();
	}
}

//empty state
auto state Idle
{
}

state ResetPosition
{
Begin:
	MoveTo(AzurukPawn(self.Pawn).spawnLoc);
	StartResetHealth();
	GotoState('Idle');
}

state Stunned
{
	local name PrevState;

	event BeginState(name PreviousStateName)
	{
		Pawn.SetPhysics(PHYS_None);
		PrevState = PreviousStateName;			
	}

	event EndState(name NextStateName)
	{
		Pawn.SetPhysics(Pawn.WalkingPhysics);
	}
Begin:
	Sleep(stunnedTime);
	GotoState(PrevState);
}

DefaultProperties
{
	stunnedTime = 3.0
}
