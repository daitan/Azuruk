class AzurukController extends PlayerController
	config(Game);

/*
 * Camera Zoom Execute Functions
 */
exec function CamZoomIn()
{
	if (!AzurukPlayerPawn(GetALocalPlayerController().Pawn).bInMenu) {
		AzurukCamera(PlayerCamera).ZoomIn();
	}
}

exec function CamZoomOut()
{
	if (!AzurukPlayerPawn(GetALocalPlayerController().Pawn).bInMenu) {
		AzurukCamera(PlayerCamera).ZoomOut();
	}
}

/*
 * Morphing Execute Functions
 */
exec function TransformOne()
{
	if (!AzurukPlayerPawn(GetALocalPlayerController().Pawn).bInMenu) {
		AzurukPlayerPawn(Pawn).SetMorphSet(AzurukPlayerPawn(GetALocalPlayerController().Pawn).IndexFirstForm);
	}
}

exec function TransformTwo()
{
	if (!AzurukPlayerPawn(GetALocalPlayerController().Pawn).bInMenu) {
		AzurukPlayerPawn(Pawn).SetMorphSet(AzurukPlayerPawn(GetALocalPlayerController().Pawn).IndexSecondForm);
	}
}

defaultproperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
}