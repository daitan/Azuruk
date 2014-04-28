class AzurukPlayerController extends AzurukController;

/*
 * Variables
 */
var eDoubleClickDir tempClick;
var float clickTime;
var bool bFirstKeyPress;

var float speedupRate, slowdownRate, minSpeed, maxSpeed;

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

	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local bool				bSaveJump;

		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Pawn.Rotation,X,Y,Z);

			switch (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType)
			{
				case M_LargeWalking:
					if (PlayerInput.aForward > 0)
					{
						Pawn.GroundSpeed += speedupRate;
					}
					else
					{
						Pawn.GroundSpeed -= slowdownRate;
					}

					if (Pawn.GroundSpeed > 0.00800)
					{
						NewAccel = PlayerInput.aForward * X;
					}
					else
					{
						NewAccel = PlayerInput.aForward * X + PlayerInput.aStrafe * Y;
					}
					FClamp(Pawn.GroundSpeed, minSpeed, maxSpeed);
					break;
				default:
					Pawn.GroundSpeed = 600;
					NewAccel = PlayerInput.aForward * X + PlayerInput.aStrafe * Y;
					break;
			}

			// Update acceleration.
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			if (IsLocalPlayerController())
			{
				AdjustPlayerWalkingMoveAccel(NewAccel);
			}

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			OldRotation = Rotation;
			UpdateRotation( DeltaTime );
			bDoubleJump = false;

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			bPressedJump = bSaveJump;
		}
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

	speedupRate=5
	slowdownRate=10
	minSpeed=600
	maxSpeed=1000
}