class ObjectPhysicsTreePod extends KActorSpawnable
	placeable;

// The max damage take to the pawn when the hit velocity reaches the  MaxDamageVelocity
var()   int	        MaxDamageAmount;
// The limitation of the velocity to damage the pawn, 40 by default
var()   float	    MinDamageVelocity;
// If the velocity reaches this point, it will take the max damage to the pawn
var()   float	    MaxDamageVelocity;
var     bool        bFrankUsable;          

simulated event RigidBodyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
	out const CollisionImpactData RigidCollisionData, int ContactIndex)
{
	local int DamageAmount; // Damage points take to the pawn

	if(OtherComponent != none) 
	{
		if( MinDamageVelocity < 0 )
		          MinDamageVelocity = 0;

		// Only damage the pawn when the hit velocity reaches to the  MinDamageVelocity
		if( VSize(Velocity) >= MinDamageVelocity )
		{
		    // Max damage the pawn when the velocity reaches the max velocity
            if( VSize(Velocity) >= MaxDamageVelocity )
            {
                DamageAmount = MaxDamageAmount;
            }
            else // count the damage if not reaches the max velocity but faster than the min
            {
                DamageAmount = MaxDamageAmount * (( VSize(Velocity) - MinDamageVelocity ) / ( MaxDamageVelocity - MinDamageVelocity ));
            }
            TakeDamage(DamageAmount, None, RigidCollisionData.ContactInfos[0].ContactPosition, vect(0,0,0), class'DamageType');
		}
	}

	super.RigidBodyCollision(HitComponent,OtherComponent,RigidCollisionData,ContactIndex);
}

simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(DamageAmount >= 20)
	{
		Explode();
	}
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

//	switch (Rand(7))
//	{
//		case 0:
//			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_01');
//			break;
//		case 1:
//			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_02');
//			break;
//		case 2:
//			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_03');
//			break;
//		case 3:
//			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_04');
//			break;
//		case 4:
//			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_SmlPod_01');
//			break;
//		case 5:
//			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_SmlPod_02');
//			break;
//		case 6:
//			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_SmlPod_03');
//			break;
//		default:
//			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_01');
//			break;
//	}
}

/** Do actual explosion. */
simulated function Explode()
{
	HurtRadius(50.0, 500.0, class'UTDamageType', 1000.0, Location,,, True);

	//// Fire particles
	//if(ParticlesOnDestroy != None)
	//{
	//	WorldInfo.MyEmitterPool.SpawnEmitter(ParticlesOnDestroy, Location, Rotation);
	//}

	//// Play sound
	//if(SoundOnDestroy != None)
	//{
	//	PlaySound(SoundOnDestroy, TRUE);
	//}
}

DefaultProperties
{
	Begin Object Class=SkeletalMeshComponent Name=ObjectPhysicsMesh
		SkeletalMesh=SkeletalMesh'ExplodePodTree.Skel.Skel_BigPod_01'
		bNotifyRigidBodyCollision=true
		HiddenGame=FALSE 
		LightingChannels=(Dynamic=TRUE)
		BlockRigidBody=true
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		bBlockFootPlacement=false
	End Object
	Components(0)=ObjectPhysicsMesh
	CollisionComponent=ObjectPhysicsMesh

	Physics=PHYS_RigidBody

	bBlockActors= true
	bCollideActors=true
	bCollideWorld=true
	bWakeOnLevelStart=true
	bFrankUsable=true

	MinDamageVelocity = 40;
	MaxDamageVelocity = 1000;
	MaxDamageAmount = 100;
}
