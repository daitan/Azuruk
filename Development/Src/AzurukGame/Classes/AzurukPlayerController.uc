/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukPlayerController extends AzurukController;

var eDoubleClickDir tempClick;
var float clickTime;
var bool bFirstKeyPress;

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
		
		if (bFirstKeyPress == true) {
			clickTime = PlayerInput.DoubleClickTime;
			bFirstKeyPress = false;
		} else {
			clickTime = PlayerInput.DoubleClickTimer;
			bFirstKeyPress = true;
		}

		if (clickTime != PlayerInput.DoubleClickTime) {

		}

		playerPawn = AzurukPlayerPawn(Pawn);
		DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );
		tempClick = DoubleClickMove;
		
		if (playerPawn != none && DoubleClickMove == EDoubleClickDir.DCLICK_Right || DoubleClickMove == EDoubleClickDir.DCLICK_Left)
		{
			playerPawn.DoDodge(DoubleClickMove);
		}
	}
begin:
}

defaultproperties
{
	bFirstKeyPress=PlayerInput.DoubleClickTime
	clickTime=0.25
	CameraClass=class'AzurukGame.AzurukCamera'
}