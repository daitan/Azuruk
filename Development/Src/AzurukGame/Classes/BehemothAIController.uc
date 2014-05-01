class BehemothAIController extends CreatureAIController;

var Pawn PPawn;

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

DefaultProperties
{
}
