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
var vector spawnLoc;

// PawnFeatures Default Features Object
var PawnFeatures defaultFeatures, currentFeatures;
var MoveType defaultMoveType;

// Dodging
var vector DodgeVelocity;
var int DodgeSpeed;
var bool isDodging;
var float dodgeDuration;

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

	super.Bump(Other, OtherComp, HitNormal);

	otherPawn = Pawn(Other);
	
	switch (self.currentFeatures.pawnMoveType)
	{
		case M_Behemoth:
			if (!(AzurukPlayerController(Controller) == none || BehemothAIController(Controller) == none))
			{
				//otherPawn.TakeDamage(
			}			
			break;
	}
}

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

	DodgeSpeed = 1200
	DodgeDuration = 0.3
	isDodging = false
}
