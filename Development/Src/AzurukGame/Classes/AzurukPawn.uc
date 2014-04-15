class AzurukPawn extends GamePawn
	config(Game);

/*
 * Functions to do with PawnFeatures
 * Struct - SkeletalMesh, AnimSet, AnimTree
 */
Struct PawnFeatures
{
    var SkeletalMesh pawnMesh;
    var AnimSet pawnAnimSet;
    var AnimTree pawnAnimTree;
};

/*
 * Variables
 */

// PawnFeatures Default Features Object
var PawnFeatures defaultFeatures;

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
	
	defaultFeatures.pawnMesh = Mesh.SkeletalMesh;
	defaultFeatures.pawnAnimSet = Mesh.AnimSets[0];
	defaultFeatures.pawnAnimTree = Mesh.AnimTreeTemplate;
}

//Returns the features of the Pawn
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
			case DClick_Left:
				DodgeVelocity = -DodgeSpeed*Normal(Y);
				break;
			//dodge right
			case DClick_Right:
				DodgeVelocity = DodgeSpeed*Normal(Y);
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

defaultproperties
{
	DodgeSpeed = 1200
	DodgeDuration = 0.3
	isDodging = false
}
