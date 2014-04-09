/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class AzurukPlayerController extends GamePlayerController
	config(Game);

/*
 * Camera Zoom Execute Functions
 */
exec function GBA_ZoomIn()
{
	AzurukCamera(PlayerCamera).ZoomIn();
}

exec function GBA_ZoomOut()
{
	AzurukCamera(PlayerCamera).ZoomOut();
}

defaultproperties
{
	CameraClass=class'AzurukGame.AzurukCamera'
}