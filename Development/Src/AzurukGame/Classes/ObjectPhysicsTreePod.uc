class ObjectPhysicsTreePod extends ObjectPhysics
	placeable;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	switch (Rand(7))
	{
		case 0:
			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_01');
			break;
		case 1:
			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_02');
			break;
		case 2:
			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_03');
			break;
		case 3:
			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_04');
			break;
		case 4:
			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_SmlPod_01');
			break;
		case 5:
			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_SmlPod_02');
			break;
		case 6:
			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_SmlPod_03');
			break;
		default:
			SetStaticMesh(StaticMesh'ExplodePodTree.Skel.Skel_BigPod_01');
			break;
	}
}

DefaultProperties
{
	Begin Object Name=ObjectPhysicsMesh
	StaticMesh=StaticMesh'ExplodePodTree.Skel.Skel_BigPod_01'
	End Object
	Components(1)=ObjectPhysicsMesh
	CollisionComponent=ObjectPhysicsMesh

	bFrankUsable = true
}
