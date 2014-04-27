class AzurukMorphSelectionMenu extends CheatManager within AzurukPlayerController;

var int CurrentIndex;
var bool bShowMorphSelectionMenu;
var array<string> Commands;
var AzurukPlayerPawn PPawn;

exec function ToggleMorphSelectionMenu()
{
	CurrentIndex = 0;
	bShowMorphSelectionMenu = !bShowMorphSelectionMenu;
	SetCinematicMode(bShowMorphSelectionMenu,false,false,true,true,true);
}

exec function NextMenuItem()
{
	if (bShowMorphSelectionMenu)
	{
		CurrentIndex = Min(CurrentIndex + 1, Commands.Length);
	}
}

exec function PreviousMenuItem()
{
	if (bShowMorphSelectionMenu)
	{
		CurrentIndex = Max(CurrentIndex -1, 0);
	}
}

exec function SetPlayerMorphSet()
{
	PPawn = AzurukPlayerPawn(Pawn);
	if (bShowMorphSelectionMenu)
	{
		PPawn.SetMorph(PPawn.lastPawnTouched, CurrentIndex);
		ToggleMorphSelectionMenu();
	}
}

function DrawDebugMenu(HUD H)
{
	local float XL, YL, YPos;
	local int array_index;
	local Color command_color;
	local string cmd;

    if (bShowMorphSelectionMenu)
    {
		H.Canvas.Font = class'Engine'.Static.GetLargeFont();
		H.Canvas.StrLen("X", XL, YL);
		YPos = 0;
		H.Canvas.SetPos(0,0);
		H.Canvas.SetDrawColor(10,10,10,128);
		H.Canvas.DrawRect(H.Canvas.SizeX,H.Canvas.SizeY); //Adding a dark overlay to visually notify we're in the menu.
		AzurukHUD(H).DrawTextSimple("Morph Selection Menu",vect2d(0,YPos), H.Canvas.Font,H.WhiteColor);
		YPos += YL;

		foreach Commands(cmd, array_index)
		{
			if (array_index == CurrentIndex)
			{
				command_color = H.GreenColor;
			}
			else
			{
				command_color = H.WhiteColor;
			}
			AzurukHUD(H).DrawTextSimple(array_index$":"@cmd,vect2d(0,YPos), H.Canvas.Font,command_color);
			YPos += YL;
		}
	}
}

DefaultProperties
{
	bShowMorphSelectionMenu=false
	CurrentIndex=0
	Commands(0)="Replace First Form"
	Commands(1)="Replace Second Form"
}
