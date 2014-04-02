class AzurukPawn extends UDKPawn
	config(Game);

// Constants
var() const DynamicLightEnvironmentComponent LightEnvironment;

// Camera Type Controller
simulated function name GetDefaultCameraMode( PlayerController RequestedBy )
{
	return 'ThirdPerson';
}

DefaultProperties
{
	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
    End Object

    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bSynthesizeSHLight=true
        bIsCharacterLightEnvironment=true
        bUseBooleanEnvironmentShadowing=false
    End Object
    Components.Add(MyLightEnvironment)
    LightEnvironment=MyLightEnvironment

    Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
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