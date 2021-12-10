{
  description = "a zig language server";

  inputs = {
    zig.url = "github:arqv/zig-overlay";
    zinput.url = "github:ziglibs/zinput/5e0d781";
    zinput.flake = false;
    known-folders.url = "github:ziglibs/known-folders/0c6c484";
    known-folders.flake = false;

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, zig, zinput, known-folders }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree {
          zls =
            nixpkgs.legacyPackages."x86_64-linux".pkgs.stdenvNoCC.mkDerivation {
              name = "zls";
              version = "master";
              src = ./.;
              nativeBuildInputs = [ zig.packages."x86_64-linux".master.latest ];
              dontConfigure = true;
              dontInstall = true;
              buildPhase = ''
                ln -s ${known-folders.outPath} src/known-folders
                ln -s ${zinput.outPath} src/zinput
                mkdir -p $out
                zig build install -Drelease-safe=true -Ddata_version=master --prefix $out
              '';
              XDG_CACHE_HOME = ".cache";
            };
        };
        defaultPackage = packages.zls;
      });
}
