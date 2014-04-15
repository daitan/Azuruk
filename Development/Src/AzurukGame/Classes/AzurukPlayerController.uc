/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukPlayerController extends AzurukController;

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

/*
 * Morphing Execute Functions
 */
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

/*
 * PlayerWalking State Override
 * 
 * @change - dodging
 */
state PlayerWalking
{
	function PlayerMove(float DeltaTime)
	{
		local eDoubleClickDir DoubleClickMove;
		local AzurukPlayerPawn playerPawn;

		super.PlayerMove(DeltaTime);

		playerPawn = AzurukPlayerPawn(Pawn);
		DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );
		
		if (playerPawn != none && DoubleClickMove == EDoubleClickDir.DCLICK_Right || DoubleClickMove == EDoubleClickDir.DCLICK_Left)
		{
			playerPawn.DoDodge(DoubleClickMove);
		}
	}
begin:
}

defaultproperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
}