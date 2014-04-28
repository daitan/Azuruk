class AzurukCamera extends Camera;

// Camera Vars
var float ThirdPersonCamOffsetX, ThirdPersonCamOffsetY, ThirdPersonCamOffsetZ;
var float camzoomMin, camzoomMax, camSpeed;
var rotator CurrentCamOrientation, DesiredCamOrientation;


function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local vector		Loc, HitLocation, HitNormal, X, Y, Z;
	local Actor			HitActor;
	local CameraActor	CamActor;
	local bool			bDoNotApplyModifiers;
	local Pawn          TPawn;

	// Don't update outgoing viewtarget during an interpolation 
	if( PendingViewTarget.Target != None && OutVT == ViewTarget && BlendParams.bLockOutgoing )
	{
		return;
	}

	// Default FOV on viewtarget
	OutVT.POV.FOV = DefaultFOV;

	// Viewing through a camera actor.
	CamActor = CameraActor(OutVT.Target);
	if( CamActor != None )
	{
		CamActor.GetCameraView(DeltaTime, OutVT.POV);

		// Grab aspect ratio from the CameraActor.
		bConstrainAspectRatio	= bConstrainAspectRatio || CamActor.bConstrainAspectRatio;
		OutVT.AspectRatio		= CamActor.AspectRatio;

		// See if the CameraActor wants to override the PostProcess settings used.
		CamOverridePostProcessAlpha = CamActor.CamOverridePostProcessAlpha;
		CamPostProcessSettings = CamActor.CamOverridePostProcess;
	}
	else
	{
		TPawn = Pawn(OutVT.Target);
		// Give Pawn Viewtarget a chance to dictate the camera position.
		// If Pawn doesn't override the camera view, then we proceed with our own defaults
		if( TPawn == None || !TPawn.CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV) )
		{
			// don't apply modifiers when using these debug camera modes.
			bDoNotApplyModifiers = TRUE;

			switch( CameraStyle )
			{
				case 'ThirdPerson': 
					TPawn.GetAxes(DesiredCamOrientation,X,Y,Z); // We will be working with coordinates in pawn space, but rotated according to the Desired Rotation.

					DesiredCamOrientation = TPawn.GetViewRotation();

					if (DesiredCamOrientation != CurrentCamOrientation)
					{
						CurrentCamOrientation = RInterpTo(CurrentCamOrientation, DesiredCamOrientation, DeltaTime, 30);
					}
					OutVT.POV.Rotation = CurrentCamOrientation;

					Loc = TPawn.Location
						+ ThirdPersonCamOffsetX * X 
						+ ThirdPersonCamOffsetY * Y 
						+ (TPawn.GetCollisionHeight() + ThirdPersonCamOffsetZ) * Z;

					HitActor = (Trace(HitLocation, HitNormal, Loc, TPawn.Location, false, vect(12, 12, 12)));
					OutVT.POV.Location = (HitActor == None) ? Loc : HitLocation;

				break;
			}
		}
	}

	if( !bDoNotApplyModifiers )
	{
		// Apply camera modifiers at the end (view shakes for example)
		ApplyCameraModifiers(DeltaTime, OutVT.POV);
	}
}

function ZoomIn()
{
	if (camzoomMin > ThirdPersonCamOffsetX)
	{
		ThirdPersonCamOffsetX += camSpeed;
	}
}

function ZoomOut()
{
	if (camzoomMax < ThirdPersonCamOffsetX)
	{
		ThirdPersonCamOffsetX -= camSpeed;
	}
}


DefaultProperties
{
	ThirdPersonCamOffsetX = -80.0
    ThirdPersonCamOffsetY = 16.0
    ThirdPersonCamOffsetZ = -10.0
	camzoomMax = -200.0
	camzoomMin = -80.0
	camSpeed = 30.0
}
