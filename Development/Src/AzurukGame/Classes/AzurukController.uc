class AzurukController extends PlayerController
	config(Game);

/*
 * Camera Zoom Execute Functions
 */
//exec function CamZoomIn()
//{
//	if (!AzurukPlayerPawn(Pawn).bInMenu) {
//		AzurukCamera(PlayerCamera).ZoomIn();
//	}
//}

//exec function CamZoomOut()
//{
//	if (!AzurukPlayerPawn(Pawn).bInMenu) {
//		AzurukCamera(PlayerCamera).ZoomOut();
//	}
//}

/*
 * Morphing Execute Functions
 */
exec function TransformOne()
{
	if (!AzurukPlayerPawn(Pawn).bInMenu) {
		GotoState('Transforming');
	}
}

exec function TransformTwo()
{
	if (!AzurukPlayerPawn(Pawn).bInMenu) {
		GotoState('Transforming');
	}
}

defaultproperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
}