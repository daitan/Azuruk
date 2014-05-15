class ArboriTriggerVolume extends Trigger
	placeable;

var AzurukPlayerPawn PPawn;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	//check if pawn is a player controller pawn
	if ((Pawn(Other) != none) && (Other.IsA('AzurukPlayerPawn')))
    {
        PPawn = AzurukPlayerPawn(Other);
		PPawn.bInArboriBossRegion = true;
    }
}

event UnTouch(Actor Other)
{
	super.UnTouch(Other);

	//check if pawn is a player controller pawn
	if ((Pawn(Other) != none) && (Other.IsA('AzurukPlayerPawn')))
    {
        PPawn = AzurukPlayerPawn(Other);
		PPawn.bInArboriBossRegion = false;
    }
}

DefaultProperties
{
}
