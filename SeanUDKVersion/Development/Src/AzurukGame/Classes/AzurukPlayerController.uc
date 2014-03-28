class AzurukPlayerController extends UDKPlayerController
	config(Game);

	//self.Pawn.Mesh.AnimSets[0]=tAnimSets[intIterator];
	//self.Pawn.Mesh.SetAnimTreeTemplate(tAnimTrees[intIterator]);

	//tAnimTrees[0] = self.Pawn.Mesh.AnimTreeTemplate;
	//tAnimSets[0] = self.Pawn.Mesh.AnimSets[0];
	
	//tAnimTrees[1] = self.Pawn.Mesh.AnimTreeTemplate;
	//tAnimSets[1] = self.Pawn.Mesh.AnimSets[0];

var SkeletalMesh tMeshes[3];
var AnimTree tAnimTrees[3];
var AnimSet tAnimSets[3];

var int tIterator;

// Zoom Execute Functions
exec function GBA_ZoomIn()
{
	AzurukCamera(PlayerCamera).ZoomIn();
}

exec function GBA_ZoomOut()
{
	AzurukCamera(PlayerCamera).ZoomOut();
}

// Transform Execute Function
exec function GBA_Transform()
{
	tIterator = changeTransform(tIterator);
	`log(tMeshes[tIterator]);
}

function int changeTransform(int intIterator)
{
	self.Pawn.Mesh.SetSkeletalMesh(tMeshes[intIterator]);

	return (intIterator + 1) % 2;
}

DefaultProperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
	tIterator = 1;
	tMeshes[0] = SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
	tMeshes[1] = SkeletalMesh'UTExampleCrowd.Mesh.SK_Crowd_Robot'
}