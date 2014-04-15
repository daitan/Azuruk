/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukPlayerPawn extends AzurukPawn
	config(Game) placeable;;

/*
 * Constants
 */
var() const DynamicLightEnvironmentComponent LightEnvironment;
var() const Name SwordHandSocketName;

/*
 * Variables
 */
var PawnFeatures morphSets[4], currentFeatures;
var Pawn interactingPawn;
var int MorphEnergyMax, MorphEnergyCurrent[4];
var float MorphEnergyDrainRate, MorphEnergyRechargeRate;

var bool blockingState;

/*
 * AzurukPlayerPawn Initializations
 */
function PostBeginPlay()
{
	super.PostBeginPlay();
	
	currentFeatures = defaultFeatures;
}

/*
 * Camera Related Functions
 */
simulated function name GetDefaultCameraMode( PlayerController RequestedBy )
{
	return 'ThirdPerson';
}

/*
 * Mesh, AnimSet and AnimTree Changes
 * Related to Morphing Mechanic
 */

exec function GBA_DefaultFormTransform()
{
	Mesh.SetSkeletalMesh(defaultFeatures.pawnMesh);
}

function SetMorphSet(int index)
{
	if (morphSets[index].pawnMesh == none && MorphEnergyCurrent[index] != 0)
	{
		`log("Can't Morph");
	}
	else if (morphSets[index] != currentFeatures)
	{
		currentFeatures = morphSets[index];
		Mesh.SetSkeletalMesh(currentFeatures.pawnMesh);
		Mesh.AnimSets[0] = currentFeatures.pawnAnimSet;
		Mesh.SetAnimTreeTemplate(currentFeatures.pawnAnimTree);
		SetTimer(0.1f, true, 'DrainMorphEnergyFormOne');
	}
	else 
	{
		currentFeatures = defaultFeatures;
		Mesh.SetSkeletalMesh(currentFeatures.pawnMesh);
		Mesh.AnimSets[0] = currentFeatures.pawnAnimSet;
		Mesh.SetAnimTreeTemplate(currentFeatures.pawnAnimTree);
		StopMorphFormOne();
	}
}

simulated function int GetMorphEnergyCurrent(int morph)
{
	return MorphEnergyCurrent[morph];
}

simulated function int GetMorphEnergyMax()
{
	return MorphEnergyMax;
}

simulated function DrainMorphEnergyFormOne()
{
	if (MorphEnergyCurrent[0] > 0)
	{
		MorphEnergyCurrent[0] -= MorphEnergyDrainRate;
	}

	if (MorphEnergyCurrent[0] < 0) {
		MorphEnergyCurrent[0] = 0;
	}

	if (MorphEnergyCurrent[0] == 0)
	{
		StopMorphFormOne();
	}
}

simulated function RechargeMorphEnergyFormOne()
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

exec function StopRechargeFormOne()
{
	ClearTimer('RechargeMorphEnergyFormOne');
}

exec function StopMorphFormOne()
{
	GBA_DefaultFormTransform();
	ClearTimer('DrainMorphEnergyFormOne');
	SetTimer(0.1f, true, 'RechargeMorphEnergyFormOne');
}

/*
 * Touch Event Overloads
 */
event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if (Pawn(Other) != none)
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

/*
 * Blocking State Functions
 */
simulated function bool isBlocking()
{
	return blockingState;
}

simulated function StartFire(byte FireModeNum)
{
	super.StartFire(FireModeNum);
	if(FireModeNum == 1)
			blockingState = true;
}

simulated function StopFire(byte FireModeNum)
{
	super.StartFire(FireModeNum);
	if(FireModeNum == 1)
			blockingState = false;
}

defaultproperties
{
	MorphEnergyMax=100
	MorphEnergyDrainRate=1.f
	MorphEnergyRechargeRate=2.f

	MorphEnergyCurrent[0]=100
	MorphEnergyCurrent[1]=100
	MorphEnergyCurrent[2]=100
	MorphEnergyCurrent[3]=100
	
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