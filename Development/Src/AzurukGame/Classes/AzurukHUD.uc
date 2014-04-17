class AzurukHUD extends HUD
	config(AzurukHUD);

/*
 * Variables
 */
var AzurukPlayerPawn PPawn;
var int currentForm;

simulated event postrender()
	{
		super.postrender();
		DrawGameHUD();
	}
	

function DrawGameHUD()
{
	PPawn = AzurukPlayerPawn(PlayerOwner.Pawn);

    if (!PlayerOwner.IsDead())
    {
        DrawBar("Health",PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax,20,20,200,80,80,200);
		DrawBar("Form One",PPawn.GetMorphEnergyCurrent(0),PPawn.GetMorphEnergyMax(),20,40,80,80,255,200);
		DrawBar("Form Two",PPawn.GetMorphEnergyCurrent(1),PPawn.GetMorphEnergyMax(),20,60,80,80,255,200);
		DrawCustomText(GetCurrentFormToString(PPawn),20,80,80,80,255,200);
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

function String GetCurrentFormToString(AzurukPlayerPawn PPawn) {
	currentForm = PPawn.GetMorphCurrentForm();
	switch (currentForm)
	{
		case 0:
			return "Default Form";
		case 1:
			return "Form One";
		case 2:
			return "Form Two";
		default:
			return "UNKNOWN FORM";
	}
}

DefaultProperties
{
	currentForm = 0;
}