class BehemothAIController extends CreatureAIController;

var Pawn PPawn;

auto state Idle
{
	event SeePlayer(Pawn Seen)
	{
		super.SeePlayer(Seen);
		PPawn = GetALocalPlayerController().Pawn;
		GotoState('Charge');
	}
Begin:
	PPawn = none;
}

state Charge
{
}



DefaultProperties
{
}
