class AzurukPlayerController extends AzurukController;

/*
 * Variables
 */
var eDoubleClickDir tempClick;
var float clickTime;
var bool bFirstKeyPress;

/*
 * PerformedUseAction Override 
 * 
 * @change - added check for creature DNA collection
 */
function bool PerformedUseAction()
{
	super.PerformedUseAction();

	return AzurukPlayerPawn(Pawn).GetMorphSet();
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
}