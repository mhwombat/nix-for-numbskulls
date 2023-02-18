# ## Shell with access to a Haskell package on your local computer, with interdependencies
#
# This shell provides access to four Haskell packages that are on my hard drive.
# The fourth package depends on the first three to build.
#
with (import <nixpkgs> {});
let
  pandoc-linear-table = haskellPackages.callCabal2nix "pandoc-linear-table" /home/amy/github/pandoc-linear-table {};
  pandoc-logic-proof = haskellPackages.callCabal2nix "pandoc-logic-proof" /home/amy/github/pandoc-logic-proof {};
  pandoc-columns = haskellPackages.callCabal2nix "pandoc-columns" /home/amy/github/pandoc-columns {};
  pandoc-maths-web = haskellPackages.callCabal2nix "pandoc-maths-web" /home/amy/github/pandoc-maths-web
                       {
                         inherit pandoc-linear-table pandoc-logic-proof pandoc-columns;
                       };
in
mkShell {
  buildInputs = [
                  pandoc
                  pandoc-linear-table
                  pandoc-logic-proof
                  pandoc-columns
                  pandoc-maths-web
                ];
}
