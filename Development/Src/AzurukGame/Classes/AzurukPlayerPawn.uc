/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukPlayerPawn extends AzurukPawn
	config(Game);

/*
 * Constants
 */
var() const DynamicLightEnvironmentComponent LightEnvironment;
var() const Name SwordHandSocketName;

/*
 * Variables
 */
var PawnFeatures morphSets[4];
var Pawn interactingPawn;
var int currentSet;
var int i;
var int MorphEnergyMax[4];
var int MorphEnergyCurrent[4];
var int MorphEnergyDrainRate[4];
var bool blockingState;

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
exec function GBA_Transform()
{
	SetTimer(0.1f, true, 'DrainMorphEnergyFormOne');
	Mesh.SetSkeletalMesh(morphSets[0].pawnMesh);
}

exec function GBA_getMorph()
{
	if (interactingPawn != none)
	{
		morphSets[0] = returnPawnFeatures(interactingPawn);
	}
}

simulated function int GetMorphEnergyCurrent(int morph)
{
	return MorphEnergyCurrent[morph];
}

simulated function int GetMorphEnergyMax(int morph)
{
	return MorphEnergyMax[morph];
}

simulated function DrainMorphEnergyFormOne()
{
	if (MorphEnergyCurrent[0] > 0)
	{
		MorphEnergyCurrent[0] -= MorphEnergyDrainRate[0];
	}

	if (MorphEnergyCurrent[0] <= 0)
	{
		StopMorphFormOne();
	}
}

exec function StopMorphFormOne()
{
	ClearTimer('DrainMorphEnergyFormOne');
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
	MorphEnergyMax[0]=100
	MorphEnergyMax[1]=100
	MorphEnergyMax[2]=100
	MorphEnergyMax[3]=100
	MorphEnergyCurrent[0]=100
	MorphEnergyCurrent[1]=100
	MorphEnergyCurrent[2]=100
	MorphEnergyCurrent[3]=100
	MorphEnergyDrainRate[0]=1.f
	MorphEnergyDrainRate[1]=1.f
	MorphEnergyDrainRate[2]=1.f
	MorphEnergyDrainRate[3]=1.f

	InventoryManagerClass=class'AzurukGame.AzurukInventoryManager'

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

	Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'UTExampleCrowd.Mesh.SK_Crowd_Robot'
        bCacheAnimSequenceNodes=false
        AlwaysLoadOnClient=true
        AlwaysLoadOnServer=true
        CastShadow=true
        BlockRigidBody=true
        bUpdateSkelWhenNotRendered=false
        bIgnoreControllersWhenNotRendered=true
        bUpdateKinematicBonesFromAnimation=true
        bCastDynamicShadow=true
        RBChannel=RBCC_Untitled3
        RBCollideWithChannels=(Untitled3=true)
        LightEnvironment=MyLightEnvironment
        bOverrideAttachmentOwnerVisibility=true
        bAcceptsDynamicDecals=false
        bHasPhysicsAssetInstance=true
        TickGroup=TG_PreAsyncWork
        MinDistFactorForKinematicUpdate=0.2f
        bChartDistanceFactor=true
        RBDominanceGroup=20
        Scale=1.f
        bAllowAmbientOcclusion=false
        bUseOnePassLightingOnTranslucency=true
        bPerBoneMotionBlur=true
    End Object
    Mesh=MySkeletalMeshComponent
    Components.Add(MySkeletalMeshComponent)
}