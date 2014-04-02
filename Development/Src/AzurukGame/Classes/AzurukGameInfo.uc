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

event AddDefaultInventory(Pawn P)
{
    local MeleeWeaponInventoryManager MWInventoryManager;

    super.AddDefaultInventory(P);

    if (SwordArchetype != None)
    {
        MWInventoryManager = MeleeWeaponInventoryManager(P.InvManager);

        if (MWInventoryManager != None)
        {
            MWInventoryManager.CreateInventoryArchetype(SwordArchetype, false);
        }
    }
}

DefaultProperties
{
	SwordArchetype=MeleeWeaponSword'AzurukContent.Archetypes.AzurukSword'
	PawnArchetype=AzurukPawn'AzurukContent.Archetypes.AzurukPawn'
	PlayerControllerClass=class'AzurukGame.AzurukPlayerController'
}

