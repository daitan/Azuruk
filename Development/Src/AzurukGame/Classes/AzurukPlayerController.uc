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
begin:
}

function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot )
{
	switch (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType)
	{
		case M_LargeWalking:
			DeltaRot.Yaw /= 6;
			break;
	}

	super.ProcessViewRotation(DeltaTime, out_ViewRotation, DeltaRot);
}

defaultproperties
{
	clickTime=0.25
}