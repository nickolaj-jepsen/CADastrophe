{
  description = "CADastrophe — a gallery of parametric OpenSCAD projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bosl2 = {
      url = "github:BelfrySCAD/BOSL2";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, bosl2 }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Python with the geometry-report deps. scipy/networkx are REQUIRED for
        # the disconnected-body count; trimesh alone cannot split meshes.
        pythonEnv = pkgs.python3.withPackages (p: [ p.trimesh p.scipy p.networkx ]);

        # Symlink farm so OpenSCAD's `include <BOSL2/std.scad>` resolves: it
        # needs OPENSCADPATH to point at a dir CONTAINING a folder named BOSL2.
        openscadLibs = pkgs.runCommand "openscad-libs" { } ''
          mkdir -p "$out"
          ln -s ${bosl2} "$out/BOSL2"
        '';

        # The `scad` CLI: a writeShellApplication (shellcheck-checked at build
        # time) wrapping scripts/scad.sh, with all runtime tools on PATH.
        scad = pkgs.writeShellApplication {
          name = "scad";
          runtimeInputs = [
            pkgs.openscad-unstable
            pythonEnv
            pkgs.imagemagick
            pkgs.coreutils
          ];
          text = ''
            export OPENSCADPATH="${openscadLibs}"
            export SCAD_LIB="${./scripts}"
          '' + builtins.readFile ./scripts/scad.sh;
        };

        # Each project's source is scoped to its own subtree, so a project's STL
        # only rebuilds when ITS files change (not when any repo file changes).
        projectSrc = name: ./projects + "/${name}";

        # Per-project STL derivation. STL export needs only a writable HOME — no
        # GL/display/xvfb (only PNG rendering needs a GL context, which the
        # build sandbox lacks, so derivations are STL-only).
        mkProject = name:
          pkgs.runCommand "scad-${name}"
            {
              nativeBuildInputs = [ pkgs.openscad-unstable ];
              OPENSCADPATH = openscadLibs;
            } ''
            export HOME="$TMPDIR"
            mkdir -p "$out"
            openscad --backend=Manifold --export-format=binstl \
              -o "$out/${name}.stl" ${projectSrc name}/${name}.scad
          '';

        # Auto-discover projects/<name>/ that contain <name>/<name>.scad. The
        # name charset filter mirrors the `scad` CLI and keeps unvalidated names
        # out of the gallery's interpolated build script.
        projectNames =
          if builtins.pathExists ./projects then
            builtins.attrNames (lib.filterAttrs
              (n: t: t == "directory"
                && builtins.match "[a-z0-9-]+" n != null
                && builtins.pathExists (./projects + "/${n}/${n}.scad"))
              (builtins.readDir ./projects))
          else [ ];

        projectPackages = lib.genAttrs projectNames mkProject;

        gallery = pkgs.runCommand "cadastrophe-gallery" { } ''
          mkdir -p "$out"
          ${lib.concatMapStringsSep "\n"
            (n: ''cp ${projectPackages.${n}}/${n}.stl "$out/${n}.stl"'')
            projectNames}
        '';
      in
      {
        packages = projectPackages // {
          default = gallery;
          inherit gallery scad;
        };

        apps.default = {
          type = "app";
          program = "${scad}/bin/scad";
          meta.description = "scad CLI for CADastrophe";
        };

        formatter = pkgs.nixfmt;

        devShells.default = pkgs.mkShell {
          packages = [ scad pkgs.openscad-unstable pythonEnv pkgs.imagemagick ];
          OPENSCADPATH = openscadLibs;
          shellHook = ''
            echo "CADastrophe dev shell — OpenSCAD $(openscad --version 2>&1 | head -1)"
            echo "Tools: scad {new,render,verify,build,preview,list}  ·  openscad  ·  BOSL2 on OPENSCADPATH"
          '';
        };
      });
}
