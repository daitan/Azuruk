/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukGameInfo extends GameInfo;

auto State PendingMatch
{
Begin:
	StartMatch();
}

defaultproperties
{
	HUDType=class'AzurukGame.AzurukHUD'
	PlayerControllerClass=class'AzurukGame.AzurukPlayerController'
	DefaultPawnClass=class'AzurukGame.AzurukPlayerPawn'
	bDelayedStart=false
}


