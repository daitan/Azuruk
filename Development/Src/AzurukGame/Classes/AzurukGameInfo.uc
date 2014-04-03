class AzurukGameInfo extends UDKGame;

var() archetype AzurukPawn PawnArchetype;
var() archetype AzurukWeaponSword SwordArchetype;

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

event AddDefaultInventory(Pawn P)
{
    local AzurukInventoryManager MWInventoryManager;

    super.AddDefaultInventory(P);

    if (SwordArchetype != None)
    {
        MWInventoryManager = AzurukInventoryManager(P.InvManager);

        if (MWInventoryManager != None)
        {
            MWInventoryManager.CreateInventoryArchetype(SwordArchetype, false);
        }
    }
}

DefaultProperties
{
	SwordArchetype=AzurukWeaponSword'AzurukContent.Archetypes.AzurukSword'
	PawnArchetype=PlayerPawn'AzurukContent.Archetypes.PlayerPawn'
	PlayerControllerClass=class'AzurukGame.AzurukPlayerController'
}

