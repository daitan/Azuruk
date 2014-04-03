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

/* SpawnDefaultHUD()
Spawn a HUD (make sure that PlayerController always has valid HUD, even if \
ClientSetHUD() hasn't been called\
*/

DefaultProperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
}