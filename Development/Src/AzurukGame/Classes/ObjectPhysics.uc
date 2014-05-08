class ObjectPhysics extends KActorSpawnable;

var bool bFrankUsable;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	self.StaticMeshComponent.SetRBChannel(RBCC_Default);
	self.StaticMeshComponent.SetRBCollidesWithChannel(RBCC_Default,true);
	self.SetPhysics(PHYS_RigidBody);

}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=ObjectPhysicsMesh
		bNotifyRigidBodyCollision=true
		HiddenGame=false 
		ColllidActors=true
		BlockActors=true
		AlwaysCheckCollision=true
		ScriptRigidBodyCollisionThreshold=0.001
		LightingChannels=(Dynamic=true)
		BlockRigidBody=true
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=True,GameplayPhysics=True)
	End Object
	Components.Add(ObjectPhysicsMesh)
	CollisionComponent=ObjectPhysicsMesh

	Physics=PHYS_RigidBody

	bNoEnroachCheck=false
	bBlocksTeleport=true
	bBlockActors= true
	bCollideActors=true
	bCollideWorld=true
	bWakeOnLevelStart=true
	bFrankUsable=true
}
