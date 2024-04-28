{
  description = "Discord API wrapper for OCaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    ocaml-overlay.url = "github:nix-ocaml/nix-overlays";
    ocaml-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        system,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [inputs.ocaml-overlay.overlays.default];
        };
        inherit (pkgs) ocamlPackages mkShell;
        inherit (ocamlPackages) buildDunePackage;
        version = "0.0.1";
      in {
        devShells = {
          default = mkShell {
            inputsFrom = [
              self'.packages.default
            ];
            buildInputs = with ocamlPackages; [
              dune_3
              ocaml
              utop
              ocamlformat
            ];
            packages = builtins.attrValues {
              inherit (pkgs) clang_17 clang-tools_17 pkg-config;
              inherit (ocamlPackages) ocaml-lsp ocamlformat-rpc-lib;
            };
          };
        };

        packages = {
          default = buildDunePackage {
            inherit version;
            pname = "okitten";
            propagatedBuildInputs = with ocamlPackages; [
              dream
              lwt_ppx
              ppx_deriving_yojson
              mirage-crypto
              iso8601
            ];
            src = ./.;
          };
        };
      };
    };
}
