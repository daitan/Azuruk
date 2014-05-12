class AzurukController extends PlayerController
	config(Game);

var int morphInput;

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
	if (!AzurukPlayerPawn(Pawn).bInMenu && AzurukPlayerPawn(Pawn).CanMorph(0)) {
		GotoState('Transforming');
		morphInput = 0;
	}
}

exec function TransformTwo()
{
	if (!AzurukPlayerPawn(Pawn).bInMenu && AzurukPlayerPawn(Pawn).CanMorph(1)) {
		GotoState('Transforming');
		morphInput = 1;
	}
}

defaultproperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
}