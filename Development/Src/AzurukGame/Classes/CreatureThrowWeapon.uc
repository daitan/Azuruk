class CreatureThrowWeapon extends Weapon;

var()				float			HoldDistanceMin;
var()				float			HoldDistanceMax;
var()				float			ThrowImpulse;
var()				float			ChangeHoldDistanceIncrement;

var					RB_Handle		PhysicsGrabber;
var					float			HoldDistance;
var					Quat			HoldOrientation;


simulated function PostBeginPlay()
{
	Super.PostbeginPlay();
}

simulated function StartFire(byte FireModeNum)
{
	local vector					StartShot, EndShot;
	local vector					HitLocation, HitNormal, Extent;
	local actor						HitActor;
	local float						HitDistance;
	local Quat						PawnQuat, InvPawnQuat, ActorQuat;
	local TraceHitInfo				HitInfo;
	local SkeletalMeshComponent		SkelComp;
	local Rotator					Aim;
	local StaticMeshComponent HitComponent;
	local KActorFromStatic NewKActor;

	if ( Role < ROLE_Authority )
		return;

	// Do ray check and grab actor
	StartShot	= Instigator.GetWeaponStartTraceLocation();
	Aim			= GetAdjustedAim( StartShot );
	EndShot		= StartShot + (10000.0 * Vector(Aim));
	Extent		= vect(0,0,0);
	HitActor	= Trace(HitLocation, HitNormal, EndShot, StartShot, True, Extent, HitInfo, TRACEFLAG_Bullet);
	HitDistance = VSize(HitLocation - StartShot);

	HitComponent = StaticMeshComponent(HitInfo.HitComponent);
	if ( (HitComponent != None) ) 
	{
		//if(HitInfo.PhysMaterial != none)
		//{
		//	if(HitInfo.PhysMaterial.ImpactSound != none)
		//	{
		//		PlaySound(HitInfo.PhysMaterial.ImpactSound,,,,HitLocation);
		//	}

		//	if(HitInfo.PhysMaterial.ImpactEffect != none)
		//	{
		//		WorldInf
		//		o.MyEmitterPool.SpawnEmitter(HitInfo.PhysMaterial.ImpactEffect, HitLocation, rotator(HitNormal), none);
		//	}
		//}

		if( HitComponent.CanBecomeDynamic() )
		{
			NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitComponent);
			if ( NewKActor != None )
			{
				HitActor = NewKActor;
			}
		}
	}

	if(FireModeNum == 0)
	{
		if ( PhysicsGrabber.GrabbedComponent != None )
		{
			PhysicsGrabber.GrabbedComponent.SetActorCollision(true, true);
			PhysicsGrabber.ReleaseComponent();
		}
		else if( HitActor != None &&
				 HitActor != WorldInfo &&
				 HitInfo.HitComponent != None &&
				 HitDistance > HoldDistanceMin &&
				 HitDistance < HoldDistanceMax )
		{
			// If grabbing a bone of a skeletal mesh, dont constrain orientation.
			SkelComp = SkeletalMeshComponent(HitInfo.HitComponent);
			PhysicsGrabber.GrabComponent(HitInfo.HitComponent, HitInfo.BoneName, HitLocation, (SkelComp == None) && (PlayerController(Instigator.Controller).bRun==0));
			PhysicsGrabber.GrabbedComponent.SetActorCollision(false, false);

			// If we succesfully grabbed something, store some details.
			if (PhysicsGrabber.GrabbedComponent != None)
			{
				HoldDistance	= 150;
				PawnQuat		= QuatFromRotator( Rotation );
				InvPawnQuat		= QuatInvert( PawnQuat );

				if ( HitInfo.BoneName != '' )
				{
					ActorQuat = SkelComp.GetBoneQuaternion(HitInfo.BoneName);
				}
				else
				{
					ActorQuat = QuatFromRotator( PhysicsGrabber.GrabbedComponent.Owner.Rotation );
				}

				HoldOrientation = QuatProduct(InvPawnQuat, ActorQuat);
			}
		}
	}
	else if(FireModeNum == 1)
	{
		if ( PhysicsGrabber.GrabbedComponent != None )
		{
			PhysicsGrabber.GrabbedComponent.AddImpulse(Vector(GetAdjustedAim(Instigator.GetWeaponStartTraceLocation())) * ThrowImpulse);
			PhysicsGrabber.GrabbedComponent.SetActorCollision(true, true);
			PhysicsGrabber.ReleaseComponent();
		}
		else
		{
			`log("fire");
			Super.StartFire( FireModeNum );
		}
	}
}

//simulated function StopFire(byte FireModeNum)
//{
//	Super.StopFire( FireModeNum );
//}

simulated function bool DoOverridePrevWeapon()
{
	HoldDistance += ChangeHoldDistanceIncrement;
	HoldDistance = FMin(HoldDistance, HoldDistanceMax);
	return false;
}

simulated function bool DoOverrideNextWeapon()
{
	HoldDistance -= ChangeHoldDistanceIncrement;
	HoldDistance = FMax(HoldDistance, HoldDistanceMin);
	return false;
}

simulated function Tick( float DeltaTime )
{
	local vector	NewHandlePos, StartLoc;
	local Quat		PawnQuat, NewHandleOrientation;
	local Rotator	Aim;

 	if ( PhysicsGrabber.GrabbedComponent == None )
 	{
 		return;
 	}

	PhysicsGrabber.GrabbedComponent.WakeRigidBody( PhysicsGrabber.GrabbedBoneName );

	// Update handle position on grabbed actor.
	if( Instigator != None )
	{
		StartLoc		= Instigator.GetWeaponStartTraceLocation();
		Aim				= GetAdjustedAim( StartLoc );
		NewHandlePos	= StartLoc + (HoldDistance * Vector(Aim));
		PhysicsGrabber.SetLocation( NewHandlePos );

		// Update handle orientation on grabbed actor.
		PawnQuat				= QuatFromRotator( Rotation );
		NewHandleOrientation	= QuatProduct(PawnQuat, HoldOrientation);
		PhysicsGrabber.SetOrientation( NewHandleOrientation );
	}
}

defaultproperties
{
	HoldDistanceMin=0.0
	HoldDistanceMax=750.0
	ThrowImpulse=2500.0
	ChangeHoldDistanceIncrement=50.0

	Begin Object Class=RB_Handle Name=RB_Handle0
		LinearDamping=1.0
		LinearStiffness=50.0
		AngularDamping=1.0
		AngularStiffness=50.0
	End Object
	Components.Add(RB_Handle0)
	PhysicsGrabber=RB_Handle0

	FireInterval(0)=+1.0
	FireInterval(1)=+1.0

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_InstantHit

	InstantHitMomentum(1)=50000.0
	InstantHitDamage(1)=10.0
	Spread(1)=0

	WeaponRange=256.0

	FireOffset=(X=16,Y=10)

	bInstantHit=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0
	bCanThrow=false
}
