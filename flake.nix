{
  description = "Discord API wrapper for OCaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    atacama = {
      url = "github:suri-framework/atacama";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.riot.follows = "riot";
      inputs.telemetry.follows = "telemetry";
    };

    minttea = {
      url = "github:leostera/minttea";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rio = {
      # Pinned temporarily until Riot catches up with Rio changes :(
      url = "github:riot-ml/rio?rev=e7ee9006d96fd91248599fa26c1982364375dd9e";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    riot = {
      url = "github:riot-ml/riot";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.minttea.follows = "minttea";
      inputs.rio.follows = "rio";
      inputs.telemetry.follows = "telemetry";
    };

    serde = {
      url = "github:serde-ml/serde";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.minttea.follows = "minttea";
      inputs.rio.follows = "rio";
    };

    telemetry = {
      url = "github:leostera/telemetry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
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
            propagatedBuildInputs = [
              self'.packages.trail
              inputs'.riot.packages.default
            ];
            src = ./.;
          };

          http = buildDunePackage {
            version = "v6.0.0_beta2";
            pname = "http";
            src = builtins.fetchGit {
              url = "git@github.com:mirage/ocaml-cohttp.git";
              rev = "5da40ec181f8afb2ba6788d20c4d35bc8736c649";
              ref = "refs/tags/v6.0.0_beta2";
            };
          };

          trail = buildDunePackage {
            version = "0.0.1-dev";
            pname = "trail";
            propagatedBuildInputs = with ocamlPackages; [
              inputs'.atacama.packages.default
              bitstring
              self'.packages.http
              (mdx.override {
                inherit logs;
              })
              ppx_bitstring
              qcheck
              magic-mime
              inputs'.riot.packages.default
              uuidm
            ];
            src = builtins.fetchGit {
              url = "git@github.com:suri-framework/trail.git";
              rev = "f4dd977b8103f15697a39e4fe21cc4e14a690f30";
            };
          };
        };
      };
    };
}
