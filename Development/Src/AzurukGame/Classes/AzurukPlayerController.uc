/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukPlayerController extends GamePlayerController
	config(Game);

/*
 * Camera Zoom Execute Functions
 */
exec function GBA_ZoomIn()
{
	AzurukCamera(PlayerCamera).ZoomIn();
}

exec function GBA_ZoomOut()
{
	AzurukCamera(PlayerCamera).ZoomOut();
}

exec function GBA_Transform()
{
	AzurukPlayerPawn(Pawn).SetMorphSet(0);
}

function bool PerformedUseAction()
{
	super.PerformedUseAction();

	if (AzurukPlayerPawn(Pawn).interactingPawn != none)
	{
		AzurukPlayerPawn(Pawn).morphSets[0] = AzurukPlayerPawn(Pawn).returnPawnFeatures(AzurukPlayerPawn(Pawn).interactingPawn);
		return true;
	}
}

defaultproperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
}