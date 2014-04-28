/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukPlayerPawn extends AzurukPawn;

/*
 * Constants
 */
var() const DynamicLightEnvironmentComponent LightEnvironment;
var() const Name SwordHandSocketName;

/*
 * Variables
 */
var PawnFeatures morphSets[2], currentFeatures;
var Pawn interactingPawn, lastPawnTouched;
var int MorphCurrentForm, numStoredMorphs;
var float MorphEnergyDrainRate, MorphEnergyRechargeRate, UpdateRate,
		  MorphEnergyMax, MorphEnergyCurrent[2], MorphEnergyRechargeDelay;
var bool bNoEmptyMorphs;

/*
 * AzurukPlayerPawn Initializations
 */
function PostBeginPlay()
{
	super.PostBeginPlay();

	currentFeatures = defaultFeatures;
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
	if (morphSets[index].pawnMesh == none && MorphEnergyCurrent[index] != 0)
	{
		`log("Can't Morph");
	}
	else if (morphSets[index] != currentFeatures)
	{
		MorphCurrentForm = index + 1;
		currentFeatures = morphSets[index];
		Mesh.SetSkeletalMesh(currentFeatures.pawnMesh);
		Mesh.AnimSets[0] = currentFeatures.pawnAnimSet;
		Mesh.SetAnimTreeTemplate(currentFeatures.pawnAnimTree);
		
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
		GBA_DefaultFormTransform();
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

	if (interactingPawn != none)
	{
		if (!bNoEmptyMorphs) {
			for (i = 0; i < ArrayCount(morphSets); i++)
			{
				if (morphSets[i].pawnMesh == none)
				{
					morphSets[i] = returnPawnFeatures(interactingPawn);
					numStoredMorphs += 1;
					if (numStoredMorphs == ArrayCount(morphSets)) {
						bNoEmptyMorphs = true;
					}
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

exec function GBA_DefaultFormTransform()
{
	MorphCurrentForm = 0;
	currentFeatures = defaultFeatures;
	Mesh.SetSkeletalMesh(currentFeatures.pawnMesh);
	Mesh.AnimSets[0] = currentFeatures.pawnAnimSet;
	Mesh.SetAnimTreeTemplate(currentFeatures.pawnAnimTree);
}

function int GetMorphCurrentForm()
{
	return MorphCurrentForm;
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
	GBA_DefaultFormTransform();
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
	SetTimer(UpdateRate, true, 'RechargeMorphEnergyFormOne');
}

function StopMorphFormTwo()
{
	GBA_DefaultFormTransform();
	StopDrainFormTwo();
	SetTimer(MorphEnergyRechargeDelay, false, 'StartRechargeFormTwo');
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
	MorphCurrentForm = 0;

	MorphEnergyMax=100.0
	MorphEnergyDrainRate=0.1
	MorphEnergyRechargeRate=0.2
	MorphEnergyRechargeDelay=1.0

	MorphEnergyCurrent[0]=100.0
	MorphEnergyCurrent[1]=100.0

	UpdateRate=0.01

	bNoEmptyMorphs=false
	numStoredMorphs=0
	
	InventoryManagerClass=class'AzurukGame.AzurukInventoryManager'

	SwordHandSocketName="WeaponPoint"

	Components.Remove(Sprite)

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

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bSynthesizeSHLight=true
        bIsCharacterLightEnvironment=true
        bUseBooleanEnvironmentShadowing=false
    End Object
    Components.Add(MyLightEnvironment)
    LightEnvironment=MyLightEnvironment

	bCollideActors = true
    CollisionType = Collide_BlockAll

	Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'AzurukContent.SkeletalMeshes.SK_Crowd_Robot'
        LightEnvironment=MyLightEnvironment
        BlockNonZeroExtent = True
        BlockZeroExtent = True
        BlockActors = True
        CollideActors =True
    End Object
	Mesh=MySkeletalMeshComponent
    Components.Add(MySkeletalMeshComponent)
}