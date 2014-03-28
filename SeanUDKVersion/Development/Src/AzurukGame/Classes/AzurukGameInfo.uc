class AzurukGameInfo extends UDKGame;

var() archetype AzurukPawn PawnArchetype;

function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
    local Pawn SpawnedPawn;

    if (NewPlayer == none || StartSpot == none)
    {
        return none;
    }

    SpawnedPawn = Spawn(PawnArchetype.Class,,, StartSpot.Location,, PawnArchetype);

    return SpawnedPawn;
}

DefaultProperties
{
	PawnArchetype=AzurukPawn'AzurukContent.Archetypes.AzurukPawn'
	PlayerControllerClass=class'AzurukGame.AzurukPlayerController'
}