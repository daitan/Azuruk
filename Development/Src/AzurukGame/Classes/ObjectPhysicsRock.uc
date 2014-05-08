class ObjectPhysicsRock extends ObjectPhysics;

// The max damage take to the pawn when the hit velocity reaches the  MaxDamageVelocity
var()   int	        MaxDamageAmount;
// The limitation of the velocity to damage the pawn, 40 by default
var()   float	    MinDamageVelocity;
// If the velocity reaches this point, it will take the max damage to the pawn
var()   float	    MaxDamageVelocity;

event RigidBodyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
	out const CollisionImpactData RigidCollisionData, int ContactIndex)
{
	local Pawn P;
	local int DamageAmount; // Damage points take to the pawn

	//P = Pawn(OtherComponent);
	if( P != none && P.Controller != none )
	{
		if( MinDamageVelocity < 0 )
		MinDamageVelocity = 0;

		// Only damage the pawn when the hit velocity reaches to the MinDamageVelocity
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
			P.TakeDamage(DamageAmount, None, RigidCollisionData.ContactInfos[0].ContactPosition, vect(0,0,0), class'DamageType');
		}
	}
	
	super.RigidBodyCollision(HitComponent,OtherComponent,RigidCollisionData,ContactIndex);
}

DefaultProperties
{
	Begin Object Name=ObjectPhysicsMesh
		StaticMesh=StaticMesh'ExplodePodTree.Stat_SmlPod_02' //placeholder mesh
	End Object

	MinDamageVelocity = 40;
	MaxDamageVelocity = 1000;
	MaxDamageAmount = 100;
}
