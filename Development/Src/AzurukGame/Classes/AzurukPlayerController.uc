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
exec function CamZoomIn()
{
	AzurukCamera(PlayerCamera).ZoomIn();
}

exec function CamZoomOut()
{
	AzurukCamera(PlayerCamera).ZoomOut();
}

/*
 * Morphing Execute Functions
 */
exec function TransformOne()
{
	AzurukPlayerPawn(Pawn).SetMorphSet(0);
}

exec function TransformTwo()
{
	AzurukPlayerPawn(Pawn).SetMorphSet(1);
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
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( AzurukPlayerPawn(Pawn).DoDodge(DoubleClickMove) )
				DoubleClickDir = DCLICK_Active;
		}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}

	//Replaced function

	//function PlayerMove(float DeltaTime)
	//{
	//	local eDoubleClickDir DoubleClickMove;
	//	local AzurukPlayerPawn playerPawn;
	//	super.PlayerMove(DeltaTime);
		
	//	if (bFirstKeyPress == true) {
	//		clickTime = PlayerInput.DoubleClickTime;
	//		bFirstKeyPress = false;
	//	} else {
	//		clickTime = PlayerInput.DoubleClickTimer;
	//		bFirstKeyPress = true;
	//	}

	//	if (clickTime != PlayerInput.DoubleClickTime) {
	//		playerPawn = AzurukPlayerPawn(Pawn);
	//		DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );
	//		tempClick = DoubleClickMove;
	//	}
		
	//	if (playerPawn != none && DoubleClickMove == EDoubleClickDir.DCLICK_Right || DoubleClickMove == EDoubleClickDir.DCLICK_Left)
	//	{
	//		playerPawn.DoDodge(DoubleClickMove);
	//	}
	//}
begin:
}

defaultproperties
{
	clickTime=0.25
	CameraClass=class'AzurukGame.AzurukCamera'
}