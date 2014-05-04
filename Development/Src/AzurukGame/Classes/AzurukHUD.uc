class AzurukHUD extends HUD
	config(AzurukHUD);

/*
 * Variables
 */
var AzurukPlayerPawn PPawn;
var int CurrentIndex;
var bool bShowMorphSelectionMenu;

simulated event postrender()
{
	super.postrender();
	PPawn = AzurukPlayerPawn(PlayerOwner.Pawn);
	DrawGameHUD();
	DrawMorphSelectionMenu();
}
	

function DrawGameHUD()
{
    if (!PlayerOwner.IsDead())
    {
        DrawBar("Health",PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax,20,20,200,80,80,200);
		DrawBar("Form One",PPawn.GetMorphEnergyCurrent(0),PPawn.GetMorphEnergyMax(),20,40,80,80,255,200);
		DrawBar("Form Two",PPawn.GetMorphEnergyCurrent(1),PPawn.GetMorphEnergyMax(),20,60,80,80,255,200);
		DrawCustomText(PPawn.currentFeatures.CreatureName,20,80,80,80,255,200);
    }
}

/** This is our function to draw bars.
  * They will be displayed as a String, "NameOfBar" , CurrentValue , MaxValue , PosX , PosY , WhatColourItIs
  */  
function DrawBar(String  Title, float Value, float MaxValue, int X, int Y, int R, int G, int B, int A)
{
	local int PosX; // This will control where our variable will end up on the X-Axis
	local int BarSizeX; // This will control how big our bar will be

	PosX = 20; //Where we should draw the rectangle
	BarSizeX = 300 * FMin(Value / MaxValue, 1); // size of active rectangle (change 300 to however big you want your bar to be)
	
	//Displays the bar that will be used to store the health
	Canvas.SetPos(PosX, Y);
	Canvas.SetDrawColor(R, G, B, A); //(Red, Green, Blue, Alpha);
	Canvas.DrawRect(BarSizeX, 12); //Canvas.DrawRect(X, Y);
	
	//Displays empty rectangle
	Canvas.SetPos(BarSizeX+X,Y);
	Canvas.SetDrawColor(255, 255, 255, 80);
	Canvas.DrawRect(300 - BarSizeX, 12); 
 

	//Draw our title
	Canvas.SetPos(PosX+300+5, Y); 
	Canvas.SetDrawColor(R, G, B, A);
	Canvas.Font = class'Engine'.static.GetSmallFont();
	Canvas.DrawText(Title);
}

function DrawCustomText(String Text, int X, int Y, int R, int G, int B, int A)
{
	Canvas.SetPos(X, Y);
	Canvas.SetDrawColor(R, G, B, A);
	Canvas.Font = class'Engine'.static.GetSmallFont();
	Canvas.DrawText(Text);
}

function DrawTextSimple(string text, Vector2D position, Font font, Color text_color)
{
	Canvas.SetPos(position.X,position.Y);
	Canvas.SetDrawColorStruct(text_color);
	Canvas.Font = font;
	Canvas.DrawText(text);
}

exec function ToggleMorphSelectionMenu()
{
	CurrentIndex = 0;
	bShowMorphSelectionMenu = !bShowMorphSelectionMenu;
	PPawn.bInMenu = !PPawn.bInMenu;
	PPawn.SetCinematicMode(bShowMorphSelectionMenu);
}

exec function NextMenuItem()
{
	if (bShowMorphSelectionMenu)
	{
		CurrentIndex = Min(CurrentIndex + 1, ArrayCount(PPawn.morphSets) - 1);
	}
}

exec function PreviousMenuItem()
{
	if (bShowMorphSelectionMenu)
	{
		CurrentIndex = Max(CurrentIndex - 1, 0);
	}
}

exec function SetPlayerMorphSet()
{
	if (bShowMorphSelectionMenu)
	{
		PPawn.SetMorph(PPawn.lastPawnTouched, CurrentIndex);
		ToggleMorphSelectionMenu();
	}
}

function DrawMorphSelectionMenu()
{
	local float XL, YL, YPos;
	local int array_index;
	local Color command_color;
	local string creature_name;
	local array<string> names;

    if (bShowMorphSelectionMenu)
    {
		Canvas.Font = class'Engine'.Static.GetLargeFont();
		Canvas.StrLen("X", XL, YL);
		YPos = 0;
		Canvas.SetPos(0,0);
		Canvas.SetDrawColor(10,10,10,128);
		Canvas.DrawRect(Canvas.SizeX, Canvas.SizeY); //Adding a dark overlay to visually notify we're in the menu.
		DrawTextSimple("Morph Selection Menu", vect2d(0,YPos), Canvas.Font, WhiteColor);
		YPos += YL;

		names = PPawn.GetCurrentCreatureNames();
		foreach names (creature_name, array_index)
		{
			if (array_index == CurrentIndex)
			{
				command_color = GreenColor;
			}
			else
			{
				command_color = WhiteColor;
			}
			DrawTextSimple(array_index$":"@creature_name, vect2d(0,YPos), Canvas.Font, command_color);
			YPos += YL;
		}
	}
}

exec function HideAllMenus()
{
	PPawn.bInMenu = false;
	bShowMorphSelectionMenu = false;
}

DefaultProperties
{
	bShowMorphSelectionMenu=false
	CurrentIndex=0
}