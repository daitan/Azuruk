class ObjectPhysics extends KActorSpawnable;

var() bool bFrankUsable;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	self.StaticMeshComponent.SetRBChannel(RBCC_Default);
	self.StaticMeshComponent.SetRBCollidesWithChannel(RBCC_Default,true);
	self.SetPhysics(PHYS_RigidBody);

}

DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=PhysicsObjectLightComponent
	End Object

	Components(0)=PhysicsObjectLightComponent

	Begin Object Class=StaticMeshComponent Name=ObjectPhysicsMesh
	
	// StaticMesh=StaticMesh''
	bNotifyRigidBodyCollision=true
	
	HiddenGame=FALSE 
	ScriptRigidBodyCollisionThreshold=0.001 
	LightingChannels=(Dynamic=TRUE) 
	End Object
	Components(1)=ObjectPhysicsMesh
	CollisionComponent = ObjectPhysicsMesh

	bBlockActors= true
	bCollideActors=true
	bCollideWorld = true
	bWakeOnLevelStart = true
}
