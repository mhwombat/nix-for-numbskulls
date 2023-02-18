# ## Shell with access to a Haskell package on your local computer
#
# This shell provides access to three Haskell packages that are on my hard drive.
#
with (import <nixpkgs> {});
let
  pandoc-linear-table = haskellPackages.callCabal2nix "pandoc-linear-table" /home/amy/github/pandoc-linear-table {};
  pandoc-logic-proof = haskellPackages.callCabal2nix "pandoc-logic-proof" /home/amy/github/pandoc-logic-proof {};
  pandoc-columns = haskellPackages.callCabal2nix "pandoc-columns" /home/amy/github/pandoc-columns {};
in
mkShell {
  buildInputs = [
                  pandoc
                  pandoc-linear-table
                  pandoc-logic-proof
                  pandoc-columns
                ];
}
