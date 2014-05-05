class AzurukPawn extends GamePawn
	abstract
	config(Game);

enum MoveType
{
	M_PlayerWalking,
	M_CreatureWalking,
	M_CreatureFlying,
	M_Behemoth,
};

/*
 * Functions to do with PawnFeatures
 * Struct - SkeletalMesh, AnimSet, AnimTree
 */
Struct PawnFeatures
{
    var SkeletalMesh pawnMesh;
    var AnimSet pawnAnimSet;
    var AnimTree pawnAnimTree;
	var MoveType pawnMoveType;
	var string CreatureName;
};

/*
 * Variables
 */
var() const DynamicLightEnvironmentComponent LightEnvironment;

// spawn location
var vector          spawnLoc;

// PawnFeatures Default Features Object
var PawnFeatures    defaultFeatures, currentFeatures;
var MoveType        defaultMoveType;

// Behemoth Variables
var int             chargeDamage;
var float           hitMomentum;

/*
 * Initialisation
 */
function PostBeginPlay()
{
	super.PostBeginPlay();
	
	spawnLoc = Location;
	defaultFeatures.pawnMesh = Mesh.SkeletalMesh;
	defaultFeatures.pawnAnimSet = Mesh.AnimSets[0];
	defaultFeatures.pawnAnimTree = Mesh.AnimTreeTemplate;
	defaultFeatures.pawnMoveType = defaultMoveType;
	currentFeatures = defaultFeatures;
}

/*
 * Returns the features of the Pawn
 */
function PawnFeatures returnPawnFeatures(Pawn Other)
{
	return AzurukPawn(Other).defaultFeatures;
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	local Pawn otherPawn;
	local KActor otherKActor;
	local Vector Momentum;

	super.Bump(Other, OtherComp, HitNormal);

	otherPawn = Pawn(Other);
	otherKActor = KActor(Other);
	
	if (GroundSpeed > 700 && self.currentFeatures.pawnMoveType == M_Behemoth)
	{
		if (otherPawn != none)
		{
			Momentum = Normal(otherPawn.Location + Location) * hitMomentum;
			otherPawn.TakeDamage(chargeDamage, Instigator.Controller, HitNormal, Momentum, class'DmgType_Crushed');
			otherPawn.Controller.GotoState('Stunned');
		}
		else if (otherKActor != none)
		{
			Momentum = Normal(otherKActor.Location + Location) * hitMomentum;
			otherKActor.TakeDamage(chargeDamage, Instigator.Controller, HitNormal, Momentum, class'DmgType_Crushed');
		}
	}
}

//simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
//{
//	local vector ApplyImpulse, ShotDir;
  
//	bReplicateMovement = false;
//	bTearOff = true;
//	Velocity += TearOffMomentum;
//	SetDyingPhysics();
//	bPlayedDeath = true;
//	HitDamageType = DamageType; // these are replicated to other clients
//	TakeHitLocation = HitLoc;
//	if ( WorldInfo.NetMode == NM_DedicatedServer )
//	{
//		GotoState('Dying');
//		return;
//	}
//	Mesh.SetBlockRigidBody(true);
//	InitRagdoll();
//	mesh.MinDistFactorForKinematicUpdate = 0.f;
  
//	if (Physics == PHYS_RigidBody)
//	{
//		//@note: Falling instead of None so Velocity/Acceleration don't get cleared
//		setPhysics(PHYS_Falling);
//	}
//	PreRagdollCollisionComponent = CollisionComponent;
//	CollisionComponent = Mesh;
//	if( Mesh.bNotUpdatingKinematicDueToDistance )
//	{
//		Mesh.ForceSkelUpdate();
//		Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
//	}
//	if( Mesh.PhysicsAssetInstance != None )
//	{
//		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
//		Mesh.SetRBChannel(RBCC_Pawn);
//		Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
//		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
//		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
//		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
//		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
//		Mesh.ForceSkelUpdate();
//		Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
//		Mesh.PhysicsWeight = 1.0;
//		Mesh.bUpdateKinematicBonesFromAnimation=false;
//		// mesh.bPauseAnims=True;
//		Mesh.SetRBLinearVelocity(Velocity, false);
//		mesh.SetTranslation(vect(0,0,1) * 6);
//		Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
//		Mesh.SetNotifyRigidBodyCollision(true);
//		Mesh.WakeRigidBody();
//	}
//	if( TearOffMomentum != vect(0,0,0) )
//	{
//		ShotDir = normal(TearOffMomentum);
//		ApplyImpulse = ShotDir * DamageType.default.KDamageImpulse;
//		// If not moving downwards - give extra upward kick
//		if ( Velocity.Z > -10 )
//		{
//			ApplyImpulse += Vect(0,0,1)*2;
//		}
//		Mesh.AddImpulse(ApplyImpulse, TakeHitLocation,, true);
//	}
//	GotoState('Dying');
//}

State Dying
{
ignores Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;

	simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon) {}
	simulated function PlayNextAnimation() {}
	singular event BaseChange() {}
	event Landed(vector HitNormal, Actor FloorActor) {}

	function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation);

	  simulated singular event OutsideWorldBounds()
	  {
		  SetPhysics(PHYS_None);
		  SetHidden(True);
		  LifeSpan = FMin(LifeSpan, 1.0);
	  }

	event Timer()
	{
		LifeSpan = 0.0;
		SetTimer(2.0, false);
	}

	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		SetPhysics(PHYS_Falling);

		if ( (Physics == PHYS_None) && (Momentum.Z < 0) )
			Momentum.Z *= -1;

		Velocity += 3 * momentum/(Mass + 200);

		if ( damagetype == None )
		{
			// `warn("No damagetype for damage by "$instigatedby.pawn$" with weapon "$InstigatedBy.Pawn.Weapon);
			DamageType = class'DamageType';
		}

		Health -= Damage;
	}

	event BeginState(Name PreviousStateName)
	{
		local Actor A;
		local array<SequenceEvent> TouchEvents;
		local int i;

		if ( bTearOff && (WorldInfo.NetMode == NM_DedicatedServer) )
		{
			LifeSpan = 2.0;
		}
		else
		{
			SetTimer(5.0, false);
			// add a failsafe termination
			LifeSpan = 25.f;
		}

		SetDyingPhysics();

		SetCollision(true, false);

		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
			{
				DetachFromController();
			}
			else
			{
				Controller.Destroy();
			}
		}

		foreach TouchingActors(class'Actor', A)
		{
			if (A.FindEventsOfClass(class'SeqEvent_Touch', TouchEvents))
			{
				for (i = 0; i < TouchEvents.length; i++)
				{
					SeqEvent_Touch(TouchEvents[i]).NotifyTouchingPawnDied(self);
				}
				// clear array for next iteration
				TouchEvents.length = 0;
			}
		}
		foreach BasedActors(class'Actor', A)
		{
			A.PawnBaseDied();
		}
	}

Begin:
	Sleep(0.2);
	PlayDyingSound();
}

defaultproperties
{
	SightRadius=3000.00

	// Behemoth Defaults
	chargeDamage = 5
	hitMomentum = 40000.0

	defaultMoveType = M_PlayerWalking

	Components.Remove(Sprite)
	
	CollisionType = Collide_BlockAll
	BlockRigidBody = true
	bCollideWorld = true
	bBlockActors = true
	bCollideActors = true

	Begin Object Class=DynamicLightEnvironmentComponent Name=PawnLightEnvironment
        bSynthesizeSHLight=true
        bIsCharacterLightEnvironment=true
        bUseBooleanEnvironmentShadowing=false
    End Object
    Components.Add(PawnLightEnvironment)
    LightEnvironment=PawnLightEnvironment

	Begin Object Name=CollisionCylinder
		CollisionRadius=+30.000000
		CollisionHeight=+50.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
}
