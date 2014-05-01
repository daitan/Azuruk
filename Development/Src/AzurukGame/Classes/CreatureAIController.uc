class CreatureAIController extends AIController;

var float stunTime;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}

//empty state
auto state Idle
{
}

state ResetPosition
{
Begin:
	//MoveTo(AzurukPawn.spawnLoc);
	GotoState('Idle');
}

state Dead
{
	// TODO:
}

state Stunned
{
	event BeginState(name PreviousStateName)
	{
		GotoState(PreviousStateName);
	}
Begin:
	Sleep(stunTime);
}

DefaultProperties
{
	stunTime = 3.0
}
