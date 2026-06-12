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

        # Python with the geometry-report deps (scipy/networkx are REQUIRED for
        # the disconnected-body count; trimesh alone cannot split meshes) plus
        # the site generator's jinja2 templates and README markdown rendering.
        pythonEnv = pkgs.python3.withPackages (p: [ p.trimesh p.scipy p.networkx p.jinja2 p.markdown ]);

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
          # The script contains non-ASCII (em-dashes) in help text. shellcheck
          # (GHC) derives its stdout encoding from the locale, and the Nix build
          # sandbox runs under C/POSIX, so emitting a warning that echoes such a
          # line aborts with "commitBuffer: invalid argument". Force UTF-8.
          derivationArgs.LC_ALL = "C.UTF-8";
          runtimeInputs = [
            pkgs.openscad-unstable
            pythonEnv
            pkgs.imagemagick
            pkgs.coreutils
            pkgs.f3d        # gallery thumbnails (PBR + SSAO) from the built STLs
            pkgs.mesa       # libEGL_mesa.so + llvmpipe: GPU-free EGL render in CI
            pkgs.xvfb-run   # GLX-under-Xvfb fallback when EGL is unavailable
          ];
          text = ''
            export OPENSCADPATH="${openscadLibs}"
            export SCAD_LIB="${./scripts}"
            # Pin glvnd to Mesa's software EGL vendor (absolute store path) so a
            # GPU-less CI runner renders via llvmpipe instead of a missing driver.
            export F3D_EGL_VENDOR="${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json"
          '' + builtins.readFile ./scripts/scad.sh;
        };

        # Each project's source is scoped to its own subtree, so a project's STL
        # only rebuilds when ITS files change (not when any repo file changes).
        projectSrc = name: ./projects + "/${name}";

        # Optional per-project metadata. [[parts]] entries add per-part
        # artifacts; everything else (BOM, print settings, ...) is consumed by
        # the site generator, not by the derivations.
        projectMeta = name:
          let f = ./projects + "/${name}/project.toml";
          in if builtins.pathExists f then builtins.fromTOML (builtins.readFile f) else { };

        # Per-project STL+3MF derivation (both exports are headless-safe — no
        # GL/display/xvfb; only PNG rendering needs a GL context, which the
        # build sandbox lacks, so the gallery SITE is built outside Nix by
        # `scad site`). Each [[parts]] entry in project.toml additionally
        # yields <name>-<part>.stl/.3mf built with that part's -D defines.
        mkProject = name:
          let
            # render_only parts (e.g. an assembled view) yield no STL/3MF: they
            # are gallery imagery only, never release assets, never gated.
            parts = builtins.filter (p: !(p.render_only or false))
              ((projectMeta name).parts or [ ]);
            # Part names are interpolated into the build script and into
            # release asset names — enforce the same charset as project names.
            partName = p:
              if builtins.match "[a-z0-9-]+" (p.name or "") != null then p.name
              else throw "project ${name}: invalid [[parts]] name '${p.name or "<missing>"}'";
            partDefines = p:
              lib.concatMapStringsSep " " (d: "-D ${lib.escapeShellArg d}")
                (p.defines or [ "part=\"${partName p}\"" ]);
            exportCmds = file: defines: ''
              openscad --backend=Manifold --export-format=binstl ${defines} \
                -o "$out/${file}.stl" ${projectSrc name}/${name}.scad
              openscad --backend=Manifold ${defines} \
                -o "$out/${file}.3mf" ${projectSrc name}/${name}.scad
            '';
          in
          pkgs.runCommand "scad-${name}"
            {
              nativeBuildInputs = [ pkgs.openscad-unstable ];
              OPENSCADPATH = openscadLibs;
            } ''
            export HOME="$TMPDIR"
            mkdir -p "$out"
            ${exportCmds name ""}
            ${lib.concatMapStringsSep "\n"
              (p: exportCmds "${name}-${partName p}" (partDefines p))
              parts}
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

        # All artifacts in one directory — `nix build` output, and the staging
        # area CI uploads to the rolling "latest" GitHub release.
        gallery = pkgs.runCommand "cadastrophe-gallery" { } ''
          mkdir -p "$out"
          ${lib.concatMapStringsSep "\n"
            (n: ''cp ${projectPackages.${n}}/*.stl ${projectPackages.${n}}/*.3mf "$out/"'')
            projectNames}
        '';
      in
      {
        packages = projectPackages // {
          default = gallery;
          inherit gallery scad;
        };

        # `nix flake check` = geometry gate: every project's STLs must be
        # watertight and winding-consistent. The checks reuse the package
        # derivations, so the expensive Manifold export happens once.
        checks = lib.mapAttrs'
          (name: drv: lib.nameValuePair "geometry-${name}"
            (pkgs.runCommand "check-${name}" { nativeBuildInputs = [ pythonEnv ]; } ''
              for f in ${drv}/*.stl; do
                python3 ${./scripts/geometry_report.py} "$f" --check
              done
              touch "$out"
            ''))
          projectPackages;

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
            echo "Tools: scad {new,render,verify,build,validate,site,list}  ·  openscad  ·  BOSL2 on OPENSCADPATH"
          '';
        };
      });
}
