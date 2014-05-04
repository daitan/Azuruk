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

// spawn location
var vector spawnLoc;

// PawnFeatures Default Features Object
var PawnFeatures defaultFeatures;
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
}

/*
 * Returns the features of the Pawn
 */
function PawnFeatures returnPawnFeatures(Pawn Other)
{
	return AzurukPawn(Other).defaultFeatures;
}

function bool DoDodge(eDoubleClickDir DoubleClickMove)
{
	local vector X,Y,Z;
	
	//finds global axes of pawn
	GetAxes(Rotation, X, Y, Z);

	if( !isDodging && Physics == Phys_Walking )
	{
		//temporarily raise speeds
		AirSpeed = DodgeSpeed;
		GroundSpeed = DodgeSpeed;
		isDodging = true;
		Velocity.Z = -default.GroundSpeed;

		switch ( DoubleClickMove )
		{
			//dodge left
			case DCLICK_Left:
				DodgeVelocity = -DodgeSpeed*Normal(Y);
				break;
			//dodge right
			case DCLICK_Right:
				DodgeVelocity = DodgeSpeed*Normal(Y);
				break;
				//dodge left
			case DCLICK_Forward:
				DodgeVelocity = DodgeSpeed*Normal(X);
				break;
			//dodge right
			case DCLICK_Back:
				DodgeVelocity = -DodgeSpeed*Normal(X);
				break;
			//in case there is an error
			default:
				`log('DoDodge Error');
				break;
		}

		Velocity = DodgeVelocity;
		isDodging = false; //prevent dodging mid dodge
		PlayerController(Controller).IgnoreMoveInput(true); //prevent the player from controlling pawn direction
		PlayerController(Controller).IgnoreLookInput(true); //prevent the player from controlling rotation
		SetPhysics(Phys_Flying); //gives the right physics
		SetTimer(DodgeDuration,false,'UnDodge'); //time until the dodge is done
		return true;
	}
	else
	{
		return false;
	}
	
}

function Dodging()
{
	local vector TraceStart3;
	local vector TraceEnd1, TraceEnd2, TraceEnd3;


	if( isDodging )
	{
		//trace location for detecting objects just below pawn
		TraceEnd1 = Location;
		TraceEnd1.Z = Location.Z - 50;

		//trace location for detecting objects below pawn that are close
		TraceEnd2 = Location;
		TraceEnd2.Z = Location.Z - 120;

		//trace locations for detecting ledges pawn will fall off
		TraceStart3 = Location + 10*normal(DodgeVelocity);
		TraceEnd3 = TraceStart3;
		TraceEnd3.Z = TraceStart3.Z - 121;

		if( FastTrace(TraceEnd1) && !FastTrace(TraceEnd2) ) //nothing is very close and something is sort of close
		{
			Velocity.Z = -default.GroundSpeed; //push pawn to the ground
		}


		if( FastTrace(TraceEnd3, TraceStart3) ) //pawn is about to fall off a ledge
		{
			UnDodge();
		}
		else
		{
			//maintain a constant velocity
			Velocity.X = DodgeVelocity.X;
			Velocity.Y = DodgeVelocity.Y;
		}
	}
}

function UnDodge()
{
	local vector IdealVelocity;

	SetPhysics(Phys_Falling); //use falling instead of walking in case we are mid-air after the dodge
	isDodging = false;
	PlayerController(Controller).IgnoreMoveInput(false);
	PlayerController(Controller).IgnoreLookInput(false);
	GroundSpeed = default.GroundSpeed;
	AirSpeed = default.AirSpeed;

	//reset the velocity of pawn
	IdealVelocity = normal(DodgeVelocity)*default.GroundSpeed;
	Velocity.X = IdealVelocity.X;
	Velocity.Y = IdealVelocity.Y;
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

	DodgeSpeed = 1200
	DodgeDuration = 0.3
	isDodging = false
}
