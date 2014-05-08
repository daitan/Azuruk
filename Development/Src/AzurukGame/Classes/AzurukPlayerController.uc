class AzurukPlayerController extends AzurukController;

/*
 * Variables
 */
var float stunnedTime;

// Behemoth Variables
var float   defaultGroundSpeed, 
			chargeSpeed, speedMultiplier, maxSpeed,
			hitMomentum;

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
	event BeginState(name PreviousStateName)
	{
		GotoState(PreviousStateName);
	}
Begin:
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
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

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
				case M_CreatureFlying:
					GotoState('CreatureFlying');
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

	event BeginState(Name PreviousStateName)
	{
		DoubleClickDir = DCLICK_None;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody) // FIXME HACK!!!
				Pawn.SetPhysics(Pawn.WalkingPhysics);
		}
	}

	event EndState(Name NextStateName)
	{
		GroundPitch = 0;
	}

begin:
}

state CreatureFlying
{
	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		if (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType == M_PlayerWalking)
		{
			GotoState(Pawn.LandMovementState);					
		}

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = PlayerInput.aForward*X + PlayerInput.aStrafe*Y + PlayerInput.aUp*vect(0,0,1);;
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);

		if (Pawn.Acceleration == vect(0,0,0))
		{
			Pawn.Velocity = vect(0,0,0);
		}

		// Update rotation.
		UpdateRotation( DeltaTime );

		if ( Role < ROLE_Authority ) // then save this move and replicate it
		{
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		}
		else
		{
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		}
	}

	event BeginState(Name PreviousStateName)
	{
		Pawn.SetPhysics(PHYS_Flying);
	}
}

state Behemoth extends CreatureWalking
{
	function PlayerMove(float DeltaTime)
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local float             tGroundSpeed;
		
		if ( Pawn != None )
		{
			GetAxes(Pawn.Rotation,X,Y,Z);

			// If pawnMoveType is default
			if (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType == M_PlayerWalking)
			{
				GotoState(Pawn.LandMovementState);					
			}

			tGroundSpeed = Pawn.GroundSpeed;
			
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
				DeltaRot.Yaw /= 30;
			}			
			break;
	}
	super.ProcessViewRotation(DeltaTime, out_ViewRotation, DeltaRot);
}

defaultproperties
{
	stunnedTime=3.0

	// Behemoth Default Values
	defaultGroundSpeed= 00600.000000
	speedMultiplier=00005.000000
	chargeSpeed=00700.000000
	maxSpeed=01000.000000
}