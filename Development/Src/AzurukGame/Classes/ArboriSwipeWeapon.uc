class ArboriSwipeWeapon extends Weapon;

var array<Actor> SwingHitActors;
var array<int> Swings;
var const int MaxSwings;
var name StartSocketName;
var name EndSocketName;
var                 ArboriAIController      APC;
var                 ArboriAIPawn            AP;

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	super.ClientGivenTo(NewOwner, bDoNotActivate);
	AP = ArboriAIPawn(Owner);
	APC = ArboriAIController(AP.Controller);
}


function RestoreAmmo(int Amount, optional byte FireModeNum)
{
	Swings[FireModeNum] = Min(Amount, MaxSwings);
}

function ConsumeAmmo(byte FireModeNum)
{
	if (HasAmmo(FireModeNum))
	{
		Swings[FireModeNum]--;
	}
}

simulated function bool HasAmmo(byte FireModeNum, optional int Ammount)
{
	return Swings[FireModeNum] > Ammount;
}

simulated function FireAmmunition()
{
	StopFire(CurrentFireMode);
	SwingHitActors.Remove(0, SwingHitActors.Length);

	if (HasAmmo(CurrentFireMode))
	{
		super.FireAmmunition();
		GotoState('Swipe');
	}
}

simulated state Swinging extends WeaponFiring
{
	 simulated event Tick(float DeltaTime)
	 {
		  super.Tick(DeltaTime);
		  TraceSwing();
	 }

	simulated event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		SetTimer(GetFireInterval(CurrentFireMode), false, nameof(ResetSwings));
	}
}

function ResetSwings()
{
	RestoreAmmo(MaxSwings);
}

function Vector GetSocketLocation(Name SocketName)
{
	local Vector SocketLocation;
	local SkeletalMeshComponent SMC;

	SMC = AzurukPawn(Owner).Mesh;

	if (SMC != none && SMC.GetSocketByName(SocketName) != none)
	{
		SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation);
	}

	return SocketLocation;
}

function bool AddToSwingHitActors(Actor HitActor)
{
	local int i;

	for (i = 0; i < SwingHitActors.Length; i++)
	{
		if (SwingHitActors[i] == HitActor)
		{
			return false;
		}
	}

	SwingHitActors.AddItem(HitActor);
	return true;
}

function TraceSwing()
{
	local Actor HitActor;
	local Vector HitLoc, HitNorm, StartSocket, EndSocket, Momentum;
	local int DamageAmount;

	EndSocket = GetSocketLocation(EndSocketName);
	StartSocket = GetSocketLocation(StartSocketName);
	DamageAmount = FCeil(InstantHitDamage[CurrentFireMode]);

	foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, EndSocket, StartSocket)
	{
		if (HitActor != self && AddToSwingHitActors(HitActor))
		{
			Momentum = Normal(EndSocket - StartSocket) * InstantHitMomentum[CurrentFireMode];
			HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, class'DamageType');
		}
	}
}

//state Swipe
//{
//	event BeginState(Name PreviousStateName)
//	{
//		AP.SetPhysics(PHYS_None);
//	}

//Begin:
//	AP.AttackAnim.PlayCustomAnim('Anim_Arbori_Swipe', 1.0);
//	FinishAnim(AP.AttackAnim.GetCustomAnimNodeSeq());
//	APC.GotoState('PlayerWalking');
//	APC.GotoState(APC.ReturnTransitionState());
//	GotoState('Active');
//}

DefaultProperties
{
	MaxSwings=1
	Swings(0)=1

	bMeleeWeapon=true;
	bInstantHit=true;
	bCanThrow=false;

	FiringStatesArray(0)="Swinging"
	WeaponFireTypes(0)=EWFT_Custom
	InstantHitDamage(0)=25.0
	InstantHitMomentum(0)=25000.0
	FireInterval(0)=0.25

	StartSocketName="RightHandElbow"
	EndSocketName="RightHandIndex"
}
