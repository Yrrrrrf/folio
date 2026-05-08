{
  description = "folio — Typst package for publication-grade project documents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "folio";

          packages = with pkgs; [
            typst # document compiler
            just # task runner
            fd # fast file finder (used in justfile)
            sd # find-and-replace (used in justfile)
          ];

          shellHook = ''
            echo "    $(typst --version)"
            echo "    $(just --version)"
            echo "    $(fd --version)"
            echo "    $(sd --version)"
          '';
        };
      }
    );
}
