class CreatureAIController extends AIController;

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
	MoveTo(AzurukPawn.spawnLoc);
	GotoState('Idle');
}

state Dead
{
	// TODO:
}

DefaultProperties
{
}
