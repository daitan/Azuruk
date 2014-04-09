/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukGameInfo extends GameInfo;

var() archetype AzurukWeaponSword SwordArchetype;

auto State PendingMatch
{
Begin:
	StartMatch();
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

defaultproperties
{
	SwordArchetype=AzurukWeaponSword'AzurukContent.Archetypes.AzurukWeaponSword'
	HUDType=class'AzurukGame.AzurukHUD'
	PlayerControllerClass=class'AzurukGame.AzurukPlayerController'
	DefaultPawnClass=class'AzurukGame.AzurukPlayerPawn'
	bDelayedStart=false
}


