class AzurukPlayerController extends UDKPlayerController
	config(Game);

// Zoom Execute Functions
exec function GBA_ZoomIn()
{
	AzurukCamera(PlayerCamera).ZoomIn();
}

exec function GBA_ZoomOut()
{
	AzurukCamera(PlayerCamera).ZoomOut();
}

DefaultProperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
}