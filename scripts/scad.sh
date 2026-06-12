# shellcheck shell=bash
# scad — OpenSCAD project tool for the CADastrophe repo.
#
# This file is the body of a flake `writeShellApplication`. The wrapper provides
# `set -euo pipefail`, a PATH containing openscad/python3/magick/montage/coreutils,
# and exports OPENSCADPATH (BOSL2 lib) and SCAD_LIB (this scripts directory).
# Run `scad help` for usage.

SCAD_LIB="${SCAD_LIB:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
REPORT_PY="$SCAD_LIB/geometry_report.py"
META_PY="$SCAD_LIB/project_meta.py"
FONT="DejaVu-Sans"
IMGSIZE="${SCAD_IMGSIZE:-900,900}"
SS_IMGSIZE="${SCAD_SS_IMGSIZE:-2700,2700}"   # 3× supersample source for the OpenSCAD assembly hero
COLORSCHEME="${SCAD_COLORSCHEME:-Tomorrow}"

die() { echo "scad: $*" >&2; exit 1; }

# Reject anything outside [a-z0-9-] (also forbids '/' and '.', so a name can
# never traverse out of projects/ or inject into a generated .scad).
validate_name() {
  case "$1" in
    "" | -* | *[!a-z0-9-]*) die "invalid project name '$1' (lowercase letters, digits, hyphens only)" ;;
  esac
}

# One temp dir per invocation, removed on ANY exit (normal, die, or set -e abort).
SCAD_TMP=""
cleanup_tmp() { [ -n "${SCAD_TMP:-}" ] && rm -rf "$SCAD_TMP"; return 0; }
trap cleanup_tmp EXIT
mktmp() { SCAD_TMP="$(mktemp -d)"; printf '%s\n' "$SCAD_TMP"; }

# Camera rotation triple (rx,ry,rz) for a named view; --viewall sets distance.
view_rot() {
  case "$1" in
    iso)    echo "55,0,25" ;;
    front)  echo "90,0,0" ;;
    back)   echo "90,0,180" ;;
    right)  echo "90,0,90" ;;
    left)   echo "90,0,270" ;;
    top)    echo "0,0,0" ;;
    bottom) echo "180,0,0" ;;
    *)      return 1 ;;
  esac
}

# Repo root: nearest ancestor holding both flake.nix and projects/ (else $PWD).
find_root() {
  local d="$PWD"
  while [ "$d" != "/" ]; do
    if [ -e "$d/flake.nix" ] && [ -d "$d/projects" ]; then
      printf '%s\n' "$d"; return 0
    fi
    d="$(dirname "$d")"
  done
  printf '%s\n' "$PWD"
}

ROOT="$(find_root)"

project_scad() {  # name -> path to main .scad (or die)
  validate_name "$1"
  local f="$ROOT/projects/$1/$1.scad"
  [ -f "$f" ] || die "no such project '$1' (expected $f)"
  printf '%s\n' "$f"
}

project_outdir() {  # name -> output dir (created)
  validate_name "$1"
  local d="$ROOT/projects/$1/output"
  mkdir -p "$d"
  printf '%s\n' "$d"
}

# -D name=value overrides collected from the command line (render/verify),
# passed to every openscad invocation as repeated `-D` flags. Lets a
# multi-part project select one body, e.g.:
#   scad render uniflag --tag bracket -D 'part="bracket"'
SCAD_DEFINES=()

# Output-filename tag (validated like project names) so per-variant artifacts
# don't overwrite the canonical ones: output/<name>_<tag>_<view>.png etc.
SCAD_TAG=""

validate_tag() {
  case "$1" in
    "" | -* | *[!a-z0-9-]*) die "invalid --tag '$1' (lowercase letters, digits, hyphens only)" ;;
  esac
}

# Headless binary-STL export (Manifold). Needs no GL/display.
build_stl() {  # scad out
  local defs=() d
  for d in "${SCAD_DEFINES[@]}"; do defs+=(-D "$d"); done
  env -u DISPLAY -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen \
    openscad --backend=Manifold --export-format=binstl "${defs[@]}" -o "$2" "$1"
}

# Headless 3MF export (format inferred from the .3mf extension).
build_3mf() {  # scad out
  local defs=() d
  for d in "${SCAD_DEFINES[@]}"; do defs+=(-D "$d"); done
  env -u DISPLAY -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen \
    openscad --backend=Manifold "${defs[@]}" -o "$2" "$1"
}

# Emit each [[parts]] entry from project.toml as "name<TAB>mode<TAB>define...",
# where mode is "build" (export STL/3MF + render) or "render" (render-only, e.g.
# an assembled view — no artifacts, kept out of the geometry gate). Empty output
# (and success) when there is no project.toml or no parts.
project_parts() {  # name
  python3 "$META_PY" "$ROOT/projects/$1" --parts
}

# Headless PNG render of one view. rot = "rx,ry,rz".
render_png() {  # scad out rot [extra openscad args...]
  local scad="$1" out="$2" rot="$3"; shift 3
  local defs=() d
  for d in "${SCAD_DEFINES[@]}"; do defs+=(-D "$d"); done
  env -u DISPLAY -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen \
    openscad --backend=Manifold --render \
      --camera="0,0,0,$rot,0" --viewall --autocenter \
      --projection=ortho --view=axes,scales \
      --colorscheme="$COLORSCHEME" --imgsize="$IMGSIZE" \
      "${defs[@]}" "$@" -o "$out" "$scad"
}

bbox_line() { python3 "$REPORT_PY" "$1" --bbox; }

# Burn the bbox extents into the bottom-left corner (DejaVu-Sans is the only font).
overlay_bbox() {  # png bboxtext
  magick "$1" -font "$FONT" -pointsize 20 -fill white \
    -undercolor '#000000aa' -gravity SouthWest \
    -annotate +10+10 "bbox  $2 mm" "$1"
}

# Headless, GPU-free STL→PNG via f3d (PBR + SSAO). Primary backend is EGL on
# Mesa's llvmpipe (no display, no Xvfb); fallback is GLX inside a virtual X
# server. __EGL_VENDOR_LIBRARY_FILENAMES (F3D_EGL_VENDOR, exported by the flake)
# is the load-bearing var that makes a GPU-less CI runner pick llvmpipe.
f3d_headless() {  # model out [extra f3d args...]
  local model="$1" out="$2"; shift 2
  local opts=(
    "$model" --output "$out" --resolution "$IMGSIZE" --up=+Z
    --ambient-occlusion --tone-mapping --anti-aliasing=ssaa
    --grid --grid-unit=10 --grid-color="#d5d9de" --background-color="#eef0f2"
    "$@"
  )
  if env __EGL_VENDOR_LIBRARY_FILENAMES="${F3D_EGL_VENDOR:-}" \
         LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe \
         f3d --rendering-backend=egl "${opts[@]}" >/dev/null 2>&1; then
    return 0
  fi
  echo "scad: f3d EGL render failed, retrying under Xvfb+GLX" >&2
  env LIBGL_ALWAYS_SOFTWARE=1 __GLX_VENDOR_LIBRARY_NAME=mesa \
    xvfb-run -a -s "-screen 0 1024x1024x24" \
      f3d --rendering-backend=glx "${opts[@]}"
}

# One gallery view from an STL. iso is the perspective hero angle; the
# orthographic faces (front/top/right) match the OpenSCAD view_rot conventions.
f3d_png() {  # stl out view
  local stl="$1" out="$2" view="$3"
  case "$view" in
    iso)   f3d_headless "$stl" "$out" --camera-direction=-1,1,-0.7 ;;
    front) f3d_headless "$stl" "$out" --camera-orthographic --camera-direction=0,1,0 ;;
    top)   f3d_headless "$stl" "$out" --camera-orthographic --camera-direction=0,0,-1 ;;
    right) f3d_headless "$stl" "$out" --camera-orthographic --camera-direction=-1,0,0 ;;
    *)     die "f3d_png: unknown view '$view'" ;;
  esac
}

# Supersampled OpenSCAD render for render-only views that have no STL (the
# assembly hero): render at SS_IMGSIZE and downscale to IMGSIZE for clean edges.
# iso is perspective to match the f3d hero; no axis/scale overlay — a context shot.
render_png_ss() {  # scad out view
  local scad="$1" out="$2" view="$3" rot proj=ortho ss
  rot="$(view_rot "$view")" || die "render_png_ss: unknown view '$view'"
  [ "$view" = iso ] && proj=perspective
  ss="${out%.png}.ss.png"
  local defs=() d
  for d in "${SCAD_DEFINES[@]}"; do defs+=(-D "$d"); done
  env -u DISPLAY -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen \
    openscad --backend=Manifold --render \
      --camera="0,0,0,$rot,0" --viewall --autocenter \
      --projection="$proj" --colorscheme="$COLORSCHEME" --imgsize="$SS_IMGSIZE" \
      "${defs[@]}" -o "$ss" "$scad"
  magick "$ss" -filter Lanczos -resize "${IMGSIZE/,/x}" "$out"
  rm -f "$ss"
}

cmd_new() {
  local name="${1:-}"
  [ -n "$name" ] || die "usage: scad new <name>"
  validate_name "$name"
  local dir="$ROOT/projects/$name"
  [ -e "$dir" ] && die "project '$name' already exists at $dir"
  local modname="${name//-/_}"
  mkdir -p "$dir/output"
  {
    cat <<'SCAD_HEAD'
include <BOSL2/std.scad>
$fa = 2; $fs = 0.5;   // curve resolution: Manifold makes fine curves cheap

// --- parameters (mm) ---
size   = 30;
wall   = 2;
fillet = 3;

SCAD_HEAD
    printf 'module %s() {\n' "$modname"
    cat <<'SCAD_BODY'
    // A hollow rounded box — replace with your part.
    // edges="Z" rounds only the vertical edges so the bbox stays at the nominal size.
    diff()
        cuboid([size, size, size], rounding=fillet, edges="Z")
            position(TOP) up(0.01) tag("remove")   // +0.01 avoids a coincident face
                cuboid([size - 2 * wall, size - 2 * wall, size - wall], anchor=TOP);
}

SCAD_BODY
    printf '%s();\n' "$modname"
  } > "$dir/$name.scad"
  {
    printf '# %s\n\n' "$name"
    printf 'One-line description of the part and what it is for.\n\n'
    printf '**Key params:** size=30, wall=2, fillet=3 (mm)\n\n'
    printf '**Print:** orientation / 0.2 mm layers / supports? \n'
  } > "$dir/README.md"
  {
    printf '# Metadata for the gallery site and release pipeline. All keys are\n'
    # shellcheck disable=SC2016  # backticks are literal markdown in the emitted file
    printf '# optional — delete what does not apply. `scad validate %s` checks it.\n\n' "$name"
    printf '[project]\ntitle = "%s"\ndescription = ""\nstatus = "wip"              # wip | released\nprinted = false             # set true ONLY after a real test print\ntags = []\n\n' "$name"
    cat <<'TOML_TAIL'
# Multi-part projects: one [[parts]] block per body. Each adds
# <name>-<part>.stl/.3mf artifacts next to the full <name>.stl.
# [[parts]]
# name = "bracket"
# defines = ['part="bracket"']

# render_only = true marks a view, not a printable body: the gallery renders
# its PNGs (e.g. an assembled view) but builds no STL/3MF and skips the gate.
# [[parts]]
# name = "assembly"
# defines = ['part="assembly"']
# render_only = true

# [print]
# material = "PLA"
# layer_height_mm = 0.2
# infill = "20%"
# walls = 3
# supports = false
# orientation = ""
# notes = ""

# [[bom]]
# name = "M4x10 socket head"
# qty = 4
# spec = ""
# link = ""

# [[links]]
# label = ""
# url = ""
TOML_TAIL
  } > "$dir/project.toml"
  echo "Created projects/$name/"
  echo "Next: edit projects/$name/$name.scad and project.toml, then run: scad render $name && scad verify $name"
}

# Build a temp section/cutaway .scad (OpenSCAD does the float math) and render it.
render_cut() {  # name scad outdir stl bbox section cutaway
  local name="$1" outdir="$3" stl="$4" bbox="$5" section="$6" cutaway="$7"
  local centre; centre="$(python3 "$REPORT_PY" "$stl" --center)"
  local cx cy cz; read -r cx cy cz <<<"$centre"
  local tmp; tmp="$(mktmp)"
  local cutscad="$tmp/cut.scad" out
  if [ "$cutaway" = 1 ]; then
    out="$outdir/${name}_cutaway.png"
    {
      printf 'big = 1000; cx = %s; cy = %s; cz = %s;\n' "$cx" "$cy" "$cz"
      printf 'difference() {\n  import("%s");\n' "$stl"
      printf '  translate([cx, cy, cz]) cube(big);   // remove the +x+y+z corner\n}\n'
    } > "$cutscad"
  else
    out="$outdir/${name}_section_${section}.png"
    local off
    case "$section" in
      x) off="[cx - big, cy - big/2, cz - big/2]" ;;
      y) off="[cx - big/2, cy - big, cz - big/2]" ;;
      z) off="[cx - big/2, cy - big/2, cz - big]" ;;
      *) die "section axis must be x, y, or z" ;;
    esac
    {
      printf 'big = 1000; cx = %s; cy = %s; cz = %s;\n' "$cx" "$cy" "$cz"
      printf 'intersection() {\n  import("%s");\n' "$stl"
      printf '  translate(%s) cube(big);\n}\n' "$off"
    } > "$cutscad"
  fi
  render_png "$cutscad" "$out" "$(view_rot iso)"
  overlay_bbox "$out" "$bbox"
  echo "$out"
}

cmd_render() {
  local name="" view="iso" do_all=0 section="" cutaway=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --all)       do_all=1; shift ;;
      --cutaway)   cutaway=1; shift ;;
      --view)      [ $# -ge 2 ] || die "render: --view needs a value"; view="$2"; shift 2 ;;
      --view=*)    view="${1#*=}"; shift ;;
      --section)   [ $# -ge 2 ] || die "render: --section needs a value"; section="$2"; shift 2 ;;
      --section=*) section="${1#*=}"; shift ;;
      --size)      [ $# -ge 2 ] || die "render: --size needs a value"; IMGSIZE="$2"; shift 2 ;;
      --size=*)    IMGSIZE="${1#*=}"; shift ;;
      -D)          [ $# -ge 2 ] || die "render: -D needs name=value"; SCAD_DEFINES+=("$2"); shift 2 ;;
      -D*)         SCAD_DEFINES+=("${1#-D}"); shift ;;
      --tag)       [ $# -ge 2 ] || die "render: --tag needs a value"; SCAD_TAG="$2"; shift 2 ;;
      --tag=*)     SCAD_TAG="${1#*=}"; shift ;;
      -*)          die "render: unknown option '$1'" ;;
      *)           [ -z "$name" ] || die "render: unexpected extra argument '$1'"; name="$1"; shift ;;
    esac
  done
  [ -n "$name" ] || die "usage: scad render <name> [--view V] [--all] [--section x|y|z] [--cutaway] [--size WxH] [-D name=value]... [--tag t]"
  [ -z "$SCAD_TAG" ] || validate_tag "$SCAD_TAG"

  # Validate everything cheap BEFORE the expensive build.
  IMGSIZE="${IMGSIZE//[xX]/,}"
  [[ "$IMGSIZE" =~ ^[0-9]+,[0-9]+$ ]] || die "render: --size must be WxH, e.g. 900x900"
  local rot=""
  if [ "$cutaway" = 1 ] || [ -n "$section" ]; then
    [ -z "$section" ] || case "$section" in x|y|z) ;; *) die "render: --section axis must be x, y, or z" ;; esac
  else
    rot="$(view_rot "$view")" || die "render: unknown view '$view' (iso|front|top|right|left|back|bottom)"
  fi

  local scad outdir stl bbox base
  scad="$(project_scad "$name")"
  outdir="$(project_outdir "$name")"
  base="${name}${SCAD_TAG:+_$SCAD_TAG}"
  stl="$outdir/$base.stl"
  build_stl "$scad" "$stl"
  bbox="$(bbox_line "$stl")"

  if [ "$cutaway" = 1 ] || [ -n "$section" ]; then
    render_cut "$base" "$scad" "$outdir" "$stl" "$bbox" "$section" "$cutaway"
    return
  fi

  if [ "$do_all" = 1 ]; then
    local tmp; tmp="$(mktmp)"
    local v
    for v in iso front top right; do
      render_png "$scad" "$tmp/$v.png" "$(view_rot "$v")"
    done
    local grid="$outdir/${base}_views.png"
    montage -font "$FONT" -pointsize 16 -background white \
      -tile 2x2 -geometry +6+6 -border 1 -bordercolor '#888888' \
      -label 'ISO' "$tmp/iso.png" -label 'FRONT' "$tmp/front.png" \
      -label 'TOP' "$tmp/top.png" -label 'RIGHT' "$tmp/right.png" \
      "$grid"
    overlay_bbox "$grid" "$bbox"
    echo "$grid"
    return
  fi

  local out="$outdir/${base}_${view}.png"
  render_png "$scad" "$out" "$rot"
  overlay_bbox "$out" "$bbox"
  echo "$out"
}

cmd_verify() {
  local name=""
  while [ $# -gt 0 ]; do
    case "$1" in
      -D)      [ $# -ge 2 ] || die "verify: -D needs name=value"; SCAD_DEFINES+=("$2"); shift 2 ;;
      -D*)     SCAD_DEFINES+=("${1#-D}"); shift ;;
      --tag)   [ $# -ge 2 ] || die "verify: --tag needs a value"; SCAD_TAG="$2"; shift 2 ;;
      --tag=*) SCAD_TAG="${1#*=}"; shift ;;
      -*)      die "verify: unknown option '$1'" ;;
      *)       [ -z "$name" ] || die "verify: unexpected extra argument '$1'"; name="$1"; shift ;;
    esac
  done
  [ -n "$name" ] || die "usage: scad verify <name> [-D name=value]... [--tag t]"
  [ -z "$SCAD_TAG" ] || validate_tag "$SCAD_TAG"
  local scad outdir stl
  scad="$(project_scad "$name")"
  outdir="$(project_outdir "$name")"
  stl="$outdir/${name}${SCAD_TAG:+_$SCAD_TAG}.stl"
  build_stl "$scad" "$stl"
  python3 "$REPORT_PY" "$stl"
}

build_one() {
  local name="$1" scad outdir
  scad="$(project_scad "$name")" || return 1
  outdir="$(project_outdir "$name")" || return 1
  build_stl "$scad" "$outdir/$name.stl" || return 1
  build_3mf "$scad" "$outdir/$name.3mf" || return 1
  echo "built $outdir/$name.stl and $outdir/$name.3mf"
  # Per-part artifacts from project.toml [[parts]]. Hyphenated names match the
  # flake's derivations, so local builds and release assets stay identical.
  local parts_out
  parts_out="$(project_parts "$name")" || return 1
  local line fields saved=("${SCAD_DEFINES[@]}") rc=0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    IFS=$'\t' read -r -a fields <<<"$line"
    validate_tag "${fields[0]}"
    [ "${fields[1]}" = render ] && continue   # render-only parts have no STL/3MF
    SCAD_DEFINES=("${fields[@]:2}")
    if build_stl "$scad" "$outdir/$name-${fields[0]}.stl" \
       && build_3mf "$scad" "$outdir/$name-${fields[0]}.3mf"; then
      echo "built $outdir/$name-${fields[0]}.stl and .3mf"
    else
      rc=1; break
    fi
  done <<<"$parts_out"
  SCAD_DEFINES=("${saved[@]}")
  return "$rc"
}

cmd_build() {
  local target="${1:-}"
  [ -n "$target" ] || die "usage: scad build <name|--all>"
  if [ "$target" = "--all" ]; then
    local d name rc=0
    for d in "$ROOT"/projects/*/; do
      name="$(basename "$d")"
      [ -f "$d$name.scad" ] || continue
      if ! build_one "$name"; then echo "scad: FAILED to build '$name'" >&2; rc=1; fi
    done
    return "$rc"
  fi
  build_one "$target"
}

cmd_validate() {
  local target="${1:-}"
  [ -n "$target" ] || die "usage: scad validate <name|--all>"
  if [ "$target" = "--all" ]; then
    local d name rc=0
    for d in "$ROOT"/projects/*/; do
      name="$(basename "$d")"
      [ -f "$d$name.scad" ] || continue
      python3 "$META_PY" "$d" --check || rc=1
    done
    return "$rc"
  fi
  validate_name "$target"
  [ -d "$ROOT/projects/$target" ] || die "no such project '$target'"
  python3 "$META_PY" "$ROOT/projects/$target" --check
}

# The four gallery views the site uses. A printable body ($4 = its STL) renders
# prettily with f3d (PBR + SSAO) and gets a bbox overlay; a render-only view
# (assembly) has no STL, so it falls back to a supersampled OpenSCAD render of
# the source with no overlay — its bbox spans ghost geometry, not meaningful.
site_views() {  # scad outdir base [stl]
  local scad="$1" outdir="$2" base="$3" stl="${4:-}" bbox v out
  [ -n "$stl" ] && bbox="$(bbox_line "$stl")"
  for v in iso front top right; do
    out="$outdir/${base}_${v}.png"
    if [ -n "$stl" ]; then
      f3d_png "$stl" "$out" "$v"
      overlay_bbox "$out" "$bbox"
    else
      render_png_ss "$scad" "$out" "$v"
    fi
    echo "$out"
  done
}

# Everything site_gen.py consumes for one project: STL/3MF artifacts (default
# body + each [[parts]] entry) and the four view PNGs per artifact.
site_assets() {  # name
  local name="$1" scad outdir
  scad="$(project_scad "$name")" || return 1
  outdir="$(project_outdir "$name")" || return 1
  build_one "$name" || return 1
  site_views "$scad" "$outdir" "$name" "$outdir/$name.stl" || return 1
  local parts_out
  parts_out="$(project_parts "$name")" || return 1
  local line fields saved=("${SCAD_DEFINES[@]}") rc=0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    IFS=$'\t' read -r -a fields <<<"$line"
    validate_tag "${fields[0]}"
    SCAD_DEFINES=("${fields[@]:2}")
    if [ "${fields[1]}" = render ]; then
      site_views "$scad" "$outdir" "$name-${fields[0]}" || { rc=1; break; }
    else
      site_views "$scad" "$outdir" "$name-${fields[0]}" "$outdir/$name-${fields[0]}.stl" \
        || { rc=1; break; }
    fi
  done <<<"$parts_out"
  SCAD_DEFINES=("${saved[@]}")
  return "$rc"
}

cmd_site() {
  local serve=0 skip_render=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --serve)       serve=1; shift ;;
      --skip-render) skip_render=1; shift ;;
      *)             die "site: unknown option '$1' (usage: scad site [--serve] [--skip-render])" ;;
    esac
  done
  local d name
  if [ "$skip_render" = 0 ]; then
    for d in "$ROOT"/projects/*/; do
      name="$(basename "$d")"
      [ -f "$d$name.scad" ] || continue
      site_assets "$name" || die "site: failed to build assets for '$name'"
    done
  fi
  # owner/repo for download/source links; SCAD_REPO overrides (CI sets it).
  local repo="${SCAD_REPO:-}" url
  if [ -z "$repo" ] && command -v git >/dev/null; then
    url="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
    url="${url%.git}"
    case "$url" in
      git@github.com:*)     repo="${url#git@github.com:}" ;;
      https://github.com/*) repo="${url#https://github.com/}" ;;
    esac
  fi
  local gen_args=(--root "$ROOT" --out "$ROOT/_site")
  [ -z "$repo" ] || gen_args+=(--repo "$repo")
  python3 "$SCAD_LIB/site_gen.py" "${gen_args[@]}"
  if [ "$serve" = 1 ]; then
    echo "serving http://localhost:8000 (Ctrl-C to stop)"
    python3 -m http.server -d "$ROOT/_site" 8000
  fi
}

cmd_list() {
  local d name found=0
  for d in "$ROOT"/projects/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    [ -f "$d$name.scad" ] || continue
    printf '%s\n' "$name"
    found=1
  done
  [ "$found" = 1 ] || echo "(no projects yet — create one with: scad new <name>)"
}

cmd_help() {
  cat <<'EOF'
scad — OpenSCAD project tool for CADastrophe

Usage:
  scad new <name>            scaffold projects/<name>/ from a BOSL2 starter
  scad render <name> [opts]  render PNG view(s) with bbox overlay -> output/
      --view iso|front|top|right|left|back|bottom   (default: iso)
      --all                  2x2 montage of iso/front/top/right
      --section x|y|z        flat cross-section through the centre
      --cutaway              remove a corner octant to expose the interior
      --size WxH             image size (default 900x900)
      -D name=value          OpenSCAD variable override (repeatable); strings
                             need quoted quotes: -D 'part="bracket"'
      --tag <t>              suffix output files: <name>_<t>_<view>.png
  scad verify <name> [-D ...] [--tag t]
                             build STL and print the geometry report
  scad build <name|--all>    export STL + 3MF to output/ (plus per-part
                             <name>-<part>.* for project.toml [[parts]])
  scad validate <name|--all> check project.toml against the metadata schema
  scad site [--serve] [--skip-render]
                             build the static gallery site into _site/
                             (--serve: preview on :8000; --skip-render: reuse
                             existing output/ renders and artifacts)
  scad list                  list projects
  scad help                  this help

Iterate loop:  edit -> scad render <name> -> scad verify <name> -> fix -> repeat.
Note: `nix build .#<name>` only sees git-tracked projects; commit before building with Nix.
EOF
}

main() {
  local cmd="${1:-help}"
  shift || true
  case "$cmd" in
    new)            cmd_new "$@" ;;
    render)         cmd_render "$@" ;;
    verify)         cmd_verify "$@" ;;
    build)          cmd_build "$@" ;;
    validate)       cmd_validate "$@" ;;
    site)           cmd_site "$@" ;;
    list|ls)        cmd_list "$@" ;;
    help|-h|--help) cmd_help ;;
    *)              die "unknown command '$cmd' (try: scad help)" ;;
  esac
}

main "$@"
