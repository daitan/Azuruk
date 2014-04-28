class AzurukController extends PlayerController
	config(Game);

/*
 * Camera Zoom Execute Functions
 */
exec function CamZoomIn()
{
	AzurukCamera(PlayerCamera).ZoomIn();
}

exec function CamZoomOut()
{
	AzurukCamera(PlayerCamera).ZoomOut();
}

/*
 * Morphing Execute Functions
 */
exec function TransformOne()
{
	AzurukPlayerPawn(Pawn).SetMorphSet(0);
}

exec function TransformTwo()
{
	AzurukPlayerPawn(Pawn).SetMorphSet(1);
}

defaultproperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
}