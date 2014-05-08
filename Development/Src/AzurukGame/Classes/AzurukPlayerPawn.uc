/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukPlayerPawn extends AzurukPawn;

/*
 * Variables
 */
var PawnFeatures morphSets[4];
var Pawn interactingPawn, lastPawnTouched;
var int MorphCurrentForm, numStoredMorphs;
var float MorphEnergyDrainRate, MorphEnergyRechargeRate, UpdateRate,
		  MorphEnergyMax, MorphEnergyCurrent[2], MorphEnergyRechargeDelay;
var bool bNoEmptyMorphs, bInMenu, bInArboriBossRegion;

// Dodging
var vector DodgeVelocity;
var int DodgeSpeed;
var bool isDodging;
var float dodgeDuration;

/*
 * AzurukPlayerPawn Initializations
 */
function PostBeginPlay()
{
	super.PostBeginPlay();
	defaultFeatures.CreatureName = "No morph";
}

/*
 * GetDefaultCameraMode
 * 
 * @change - sets default camera to ThirdPerson
 */
simulated function name GetDefaultCameraMode( PlayerController RequestedBy )
{
	return 'ThirdPerson';
}

/*
 * SetMorphSet
 * 
 * Sets the pawns features according to the index of morphSets[]
 */
function SetMorphSet(int index)
{
	if (index < 0) {
		`log("No Morph Found");
	}
	else if (morphSets[index].pawnMesh == none && MorphEnergyCurrent[index] != 0)
	{
		`log("Can't Morph");
	}
	else if (morphSets[index] != currentFeatures)
	{
		if (MorphCurrentForm == 1)
		{
			StopMorphFormOne();
		}
		else if (MorphCurrentForm == 2)
		{
			StopMorphFormTwo();
		}

		MorphCurrentForm = index + 1;
		currentFeatures = morphSets[index];
		Mesh.SetSkeletalMesh(currentFeatures.pawnMesh);
		Mesh.AnimSets[0] = currentFeatures.pawnAnimSet;
		Mesh.SetAnimTreeTemplate(currentFeatures.pawnAnimTree);
		GetCreatureWeapon(currentFeatures.CreatureName);
		
		if (MorphCurrentForm == 1)
		{
			StopRechargeFormOne();
			SetTimer(UpdateRate, true, 'DrainMorphEnergyFormOne');
		} 
		else if (MorphCurrentForm == 2)
		{
			StopRechargeFormTwo();
			SetTimer(UpdateRate, true, 'DrainMorphEnergyFormTwo');
		}
	}
	else 
	{
		if (MorphCurrentForm == 1) {
			StopMorphFormOne();
		} else if (MorphCurrentForm == 2) {
			StopMorphFormTwo();
		}
		DefaultFormTransform();
	}
}

function GetCreatureWeapon(string name)
{
	switch (name)
	{
		case "Frank":
			InvManager.DiscardInventory();
			InvManager.CreateInventory(class'CreatureThrowWeapon');
			break;
		case "None":
			InvManager.DiscardInventory();
			break;
		default:
			InvManager.DiscardInventory();
			break;
	}
}

/*
 * GetMorphSet
 * 
 * Gets the morphSet from a dead touched pawn (interactingPawn)
 */

function bool GetMorphSet()
{
	local int i;
	local pawnFeatures tempFeatures;

	if (interactingPawn != none)
	{
		if (!bNoEmptyMorphs) {
			tempFeatures = returnPawnFeatures(interactingPawn);
			for (i = 0; i < ArrayCount(morphSets); i++)
			{
				if (morphSets[i].pawnMesh == none)
				{
					morphSets[i] = tempFeatures;
					numStoredMorphs += 1;
					if (numStoredMorphs == ArrayCount(morphSets)) {
						bNoEmptyMorphs = true;
					}
					break;
				}
				else if (morphSets[i] == tempFeatures)
				{
					break;
				}
			}
		}
		else
		{
			AzurukHUD(PlayerController(Controller).myHUD).ToggleMorphSelectionMenu();
		}
	}
	return true;
}

/**
 * Set morph for specific index
 */
function SetMorph(Pawn P, int index) {
	local int i;

	if (P != none) {
		for (i = 0; i < ArrayCount(morphSets); i++)
		{
			if (i == index)
			{
				morphSets[i] = returnPawnFeatures(P);
				break;
			}
		}	
	}
}

function array<string> GetCurrentCreatureNames()
{
	local array<string> names;
	local int i;

	for (i = 0; i < ArrayCount(morphSets); i++)
	{
		//if (morphSets[i].CreatureName == none) {
		//	names[i] = "No DNA";
		//}
		//else
		//{
			names[i] = morphSets[i].CreatureName;
		//}
	}

	return names;
}

function SwitchStoredMorphs(int oldInd, int newInd)
{
	local pawnFeatures temp;

	temp = morphSets[oldInd];
	morphSets[oldInd] = morphSets[newInd];
	morphSets[newInd] = temp;
}

exec function ChangeFirstMorph()
{
	local int temp;
	if (AzurukHUD(PlayerController(Controller).myHUD).bShowMorphSelectionMenu) {
		temp = AzurukHUD(PlayerController(Controller).myHUD).CurrentIndex;
		if (morphSets[temp].pawnMesh != none) 
		{
			SwitchStoredMorphs(0, temp);
		}
	}
}

exec function ChangeSecondMorph()
{
	local int temp;
	if (AzurukHUD(PlayerController(Controller).myHUD).bShowMorphSelectionMenu) {
		temp = AzurukHUD(PlayerController(Controller).myHUD).CurrentIndex;
		if (morphSets[temp].pawnMesh != none) 
		{
			SwitchStoredMorphs(1, temp);
		}
	}
}

exec function DefaultFormTransform()
{
	MorphCurrentForm = 0;
	currentFeatures = defaultFeatures;
	Mesh.SetSkeletalMesh(currentFeatures.pawnMesh);
	Mesh.AnimSets[0] = currentFeatures.pawnAnimSet;
	Mesh.SetAnimTreeTemplate(currentFeatures.pawnAnimTree);
	GetCreatureWeapon("None");
}

function float GetMorphEnergyCurrent(int morph)
{
	return MorphEnergyCurrent[morph];
}

function float GetMorphEnergyMax()
{
	return MorphEnergyMax;
}

function DrainMorphEnergyFormOne()
{
	if (MorphEnergyCurrent[0] > 0.0)
	{
		MorphEnergyCurrent[0] -= MorphEnergyDrainRate;
	}

	if (MorphEnergyCurrent[0] < 0.0) {
		MorphEnergyCurrent[0] = 0.0;
	}

	if (MorphEnergyCurrent[0] == 0.0)
	{
		StopMorphFormOne();
	}
}

function RechargeMorphEnergyFormOne()
{
	if (MorphEnergyCurrent[0] < MorphEnergyMax)
	{
		MorphEnergyCurrent[0] += MorphEnergyRechargeRate;
	}

	if (MorphEnergyCurrent[0] > MorphEnergyMax) {
		MorphEnergyCurrent[0] = MorphEnergyMax;
	}

	if (MorphEnergyCurrent[0] == MorphEnergyMax)
	{
		StopRechargeFormOne();
	}
}

function StopRechargeFormOne()
{
	ClearTimer('RechargeMorphEnergyFormOne');
	ClearTimer('StartRechargeFormOne');
}

function StopDrainFormOne()
{
	
	ClearTimer('DrainMorphEnergyFormOne');
}

function StartRechargeFormOne()
{
	SetTimer(UpdateRate, true, 'RechargeMorphEnergyFormOne');
}

function StopMorphFormOne()
{
	DefaultFormTransform();
	StopDrainFormOne();
	SetTimer(MorphEnergyRechargeDelay, false, 'StartRechargeFormOne');
}

function DrainMorphEnergyFormTwo()
{
	if (MorphEnergyCurrent[1] > 0.0)
	{
		MorphEnergyCurrent[1] -= MorphEnergyDrainRate;
	}

	if (MorphEnergyCurrent[1] < 0.0) {
		MorphEnergyCurrent[1] = 0.0;
	}

	if (MorphEnergyCurrent[1] == 0.0)
	{
		StopMorphFormOne();
	}
}

function RechargeMorphEnergyFormTwo()
{
	if (MorphEnergyCurrent[1] < MorphEnergyMax)
	{
		MorphEnergyCurrent[1] += MorphEnergyRechargeRate;
	}

	if (MorphEnergyCurrent[1] > MorphEnergyMax) {
		MorphEnergyCurrent[1] = MorphEnergyMax;
	}

	if (MorphEnergyCurrent[1] == MorphEnergyMax)
	{
		StopRechargeFormOne();
	}
}

function StopRechargeFormTwo()
{
	ClearTimer('RechargeMorphEnergyFormTwo');
	ClearTimer('StartRechargeFormTwo');
}

function StopDrainFormTwo()
{
	ClearTimer('DrainMorphEnergyFormTwo');
}

function StartRechargeFormTwo()
{
	SetTimer(UpdateRate, true, 'RechargeMorphEnergyFormTwo');
}

function StopMorphFormTwo()
{
	DefaultFormTransform();
	StopDrainFormTwo();
	SetTimer(MorphEnergyRechargeDelay, false, 'StartRechargeFormTwo');
}

/*
 * Doudge Functions
 * 
 * DoDodge() - Sets Dodge Direction based on eDoubleClickDir
 * UnDodge() - Resets 
 */
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

/*
 * Touch Event Overloads
 * 
 * @change - sets interactingPawn if a Pawn is touched & dead
 */
event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if (Pawn(Other) != none && Pawn(Other).Health <= 0)
    {
		interactingPawn = Pawn(Other);
    }
}

event UnTouch(Actor Other)
{
    super.UnTouch(Other);
 
    if (Pawn(Other) != none)
    {
        interactingPawn = none;
    }
}

defaultproperties
{
	// Dodging Defaults
	DodgeSpeed = 1200
	DodgeDuration = 0.3
	isDodging = false

	// Morph Bar Defaults
	MorphCurrentForm = 0;
	MorphEnergyMax=100.0
	MorphEnergyDrainRate=0.1
	MorphEnergyRechargeRate=0.2
	MorphEnergyRechargeDelay=1.0

	MorphEnergyCurrent[0]=100.0
	MorphEnergyCurrent[1]=100.0

	UpdateRate=0.01
	
	// Morph Menu Defaults
	bNoEmptyMorphs=false
	bInMenu=false
	numStoredMorphs=0
	IndexFirstForm=-1
	IndexSecondForm=-1

	bInArboriBossRegion=false

	defaultMoveType = M_PlayerWalking
	
	InventoryManagerClass=class'AzurukGame.AzurukInventoryManager'

	Begin Object Class=SkeletalMeshComponent Name=PawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'Main_Char_JinRok.skel_.JinRok'
		AnimSets[0]=AnimSet'Main_Char_JinRok.skel_.Anim_JinRok'
		AnimTreeTemplate=AnimTree'Main_Char_JinRok.AnimTree.AnimTree_JinRok'
		PhysicsAsset=PhysicsAsset'Main_Char_JinRok.physicsasset_.JinRok_Physics'
        LightEnvironment=PawnLightEnvironment
		BlockActors=true
        CollideActors=true
    End Object
	Mesh=PawnSkeletalMesh
    Components.Add(PawnSkeletalMesh)
}