class AzurukPawn extends GamePawn;

/*
 * Functions to do with PawnFeatures
 * Struct - SkeletalMesh, AnimSet, AnimTree
 */
Struct PawnFeatures
{
    var SkeletalMesh pawnMesh;
    var AnimSet pawnAnimSet;
    var AnimTree pawnAnimTree;
};

// PawnFeatures object that holds the default features
var PawnFeatures defaultFeatures;

//Returns the features of the Pawn
function PawnFeatures returnPawnFeatures(Pawn Other)
{
	return AzurukPawn(Other).defaultFeatures;
}

/*
 * Initialisation
 */
function PostBeginPlay()
{
	super.PostBeginPlay();
	
	defaultFeatures.pawnMesh = Mesh.SkeletalMesh;
	defaultFeatures.pawnAnimSet = Mesh.AnimSets[0];
	defaultFeatures.pawnAnimTree = Mesh.AnimTreeTemplate;
}



