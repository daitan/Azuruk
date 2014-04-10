class WalkingAIController extends AIController;

var Actor target;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}
 
auto state Follow
{
Begin:
    Target = GetALocalPlayerController().Pawn;
//    Target is an Actor variable defined in my custom AI Controller.
//    Of course, you would normally verify that the Pawn is not None before proceeding.
    MoveToward(Target, Target, 400);
 
    goto 'Begin';
}