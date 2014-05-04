class AzurukPlayerController extends AzurukController;

/*
 * Variables
 */

// Behemoth Variables
var float   defaultGroundSpeed, 
			chargeSpeed, speedMultiplier, maxSpeed,
			hitMomentum;
var int     chargeDamage;

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

state Stunned
{
	event Tick(float DeltaTime)
	{
		`log("Stunned");
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
		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);

		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( AzurukPlayerPawn(Pawn).DoDodge(DoubleClickMove) )
				DoubleClickDir = DCLICK_Active;
		}
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
				case M_CreatureWalking:
					GotoState('CreatureWalking');
					break;
				case M_Behemoth:
					GotoState('Behemoth');					
					break;
			}

			// Update acceleration.
			NewAccel = PlayerInput.aForward * X + PlayerInput.aStrafe * Y;
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

state CreatureWalking
{
	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;

		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Pawn.Rotation,X,Y,Z);

			// If pawnMoveType is default
			if (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType == M_PlayerWalking)
			{
				GotoState(Pawn.LandMovementState);					
			}

			// Update acceleration.
			NewAccel = PlayerInput.aForward * X + PlayerInput.aStrafe * Y;
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

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
		}
	}

begin:
}

state Behemoth extends CreatureWalking
{
	function bool isCharging()
	{
		return Pawn.GroundSpeed > chargeSpeed;
	}

	function PlayerMove(float DeltaTime)
	{
		local vector			X,Y,Z, NewAccel;
		local float             tGroundSpeed;

		super.PlayerMove(DeltaTime);
		
		if ( Pawn != None )
		{
			GetAxes(Pawn.Rotation,X,Y,Z);

			tGroundSpeed = Pawn.GroundSpeed;

			NewAccel = PlayerInput.aForward * X + PlayerInput.aStrafe * Y;
			
			if (PlayerInput.aForward > 0)
			{
				// Increase Speed
				tGroundSpeed += speedMultiplier;
				Pawn.GroundSpeed = fclamp(tGroundSpeed, Pawn.GroundSpeed, maxSpeed);
				// Normal Movement
				NewAccel = PlayerInput.aForward * X;
			}
			else
			{
				// Decrease Speed
				tGroundSpeed += -speedMultiplier;
				Pawn.GroundSpeed = fclamp(tGroundSpeed, defaultGroundSpeed, Pawn.GroundSpeed);
				// Normal Movement
				NewAccel = PlayerInput.aForward * X + PlayerInput.aStrafe * Y;
			}
						
			// Update acceleration.
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);
		}
	}

	event EndState(name NextStateName)
	{
		Pawn.GroundSpeed = defaultGroundSpeed;
	}
begin:
}

function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot )
{
	switch (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType)
	{
		case M_Behemoth:
			if (Pawn.GroundSpeed > chargeSpeed)
			{
				DeltaRot.Yaw /= 20;
			}			
			break;
	}
	super.ProcessViewRotation(DeltaTime, out_ViewRotation, DeltaRot);
}

defaultproperties
{
	// Behemoth Default Values
	chargeDamage = 5
	hitMomentum = 1000
	defaultGroundSpeed= 00600.000000
	speedMultiplier=00005.000000
	chargeSpeed=00700.000000
	maxSpeed=01000.000000
}