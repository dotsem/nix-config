final: prev: {
  monique = final.callPackage ./monique.nix { };
  tmog = final.callPackage ./tmog.nix { };
}
