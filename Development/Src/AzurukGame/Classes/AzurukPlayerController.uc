class AzurukPlayerController extends AzurukController;

/*
 * Variables
 */
var float stunnedTime, morphTime, extractTime;

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

	if (AzurukPlayerPawn(Pawn).interactingPawn != none && GetStateName() != 'DNAExtraction')
	{
		GotoState('DNAExtraction');
		return true;
	}
	return false;
}

function name ReturnTransitionState()
{
	switch (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType)
	{
		case M_PlayerWalking:
			return 'PlayerWalking';
		break;

		case M_CreatureWalking:
			return 'CreatureWalking';
		break;

		case M_CreatureFlying:
			return 'CreatureFlying';
		break;

		case M_Behemoth:
			return 'Behemoth';					
		break;
	}
}

state Stunned
{
	event BeginState(Name PreviousStateName)
	{
		Pawn.SetPhysics(PHYS_None);
	}
Begin:
	AzurukPlayerPawn(Pawn).customAnim.PlayCustomAnimByDuration('Stunned', stunnedTime, 0.1, 0.1, false, false);
	FinishAnim(AzurukPlayerPawn(Pawn).customAnim.GetCustomAnimNodeSeq());
	GotoState(ReturnTransitionState());
}

state Transforming
{
	event BeginState(Name PreviousStateName)
	{
		Pawn.SetPhysics(PHYS_None);
	}
Begin:
	AzurukPlayerPawn(Pawn).customAnim.PlayCustomAnimByDuration('Morph', morphTime, 0.1, 0.1, false, false);
	FinishAnim(AzurukPlayerPawn(Pawn).customAnim.GetCustomAnimNodeSeq());
	AzurukPlayerPawn(Pawn).SetMorphSet(morphInput);
	GotoState(ReturnTransitionState());
}

state DNAExtraction
{
	event BeginState(Name PreviousStateName)
	{
		Pawn.SetPhysics(PHYS_None);
	}
Begin:
	Pawn.SetDesiredRotation(Rotator(AzurukPlayerPawn(Pawn).interactingPawn.Location));
	AzurukPlayerPawn(Pawn).customAnim.PlayCustomAnimByDuration('JinRok_DNA', extractTime, 0.1, 0.1, false, false);
	FinishAnim(AzurukPlayerPawn(Pawn).customAnim.GetCustomAnimNodeSeq());
	AzurukPlayerPawn(Pawn).GetMorphSet();
	GotoState(ReturnTransitionState());
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
		super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);

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
		super.PlayerMove(DeltaTime);

		if (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType != M_PlayerWalking)
		{
			GotoState(ReturnTransitionState());
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

			if (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType != M_CreatureWalking)
			{
				GotoState(ReturnTransitionState());
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
		Pawn.SetPhysics(Pawn.WalkingPhysics);
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

		if (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType != M_CreatureFlying)
		{
			GotoState(ReturnTransitionState());
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

			if (AzurukPlayerPawn(Pawn).currentFeatures.pawnMoveType != M_Behemoth)
			{
				GotoState(ReturnTransitionState());
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
	morphTime=2.0
	extractTime=2.0

	// Behemoth Default Values
	defaultGroundSpeed= 00600.000000
	speedMultiplier=00005.000000
	chargeSpeed=00700.000000
	maxSpeed=01000.000000
}