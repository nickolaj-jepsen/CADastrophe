# uniflag

Mount for a Pimoroni Cosmic Unicorn (32×32 LED matrix running
[uniflag](https://github.com/nickolaj-jepsen/uniflag) as a SimHub virtual
flag) on the outboard face of the right wheel-deck upright of a GT Omega
PRIME Lite (8040 profile). Screen faces the driver, yawed 15° toward the
seat. Three print bodies in one STL (`part="plate"` default — split objects
in the slicer); design rationale and DXF-exact board data in
[SPEC.md](SPEC.md) and [docs/](docs/).

**Parts:** `bracket` (rail plate + leaning wall), `frame` (rear ring the
board drops into), `ring` (front clamp ring; right edge open for the light
sensor). Render/verify one body with
`scad render uniflag --tag frame -D 'part="frame"'`; `part="assembly"` shows
the fit, `part="collide"` must render empty.

**Key params:** `gap=40` (rail → board edge, fits the micro-B plug),
`yaw=15`, `chan_slack=0.35` (board float), `bd_clr=0.4`, `usb_y`/`btnl_y`/
`btnr_y` (edge windows), `m8_y` rows, `board_y0`.

**Hardware:** 4× M8×14 + T-nuts (rail), 5× M5×30 + nuts (wall → frame;
heads on the monitor side, nuts captive in frame pockets), 6× M4×14 + nuts
(ring → frame; nuts drop into the back-opening pockets).

**Assembly:** M4 nuts into the frame's back pockets → board into the frame →
ring on, M4s from the front → M5 nuts into the ear/rib pockets → offer the
sandwich to the wall, M5×30s from the monitor side → bracket to the rail
with M8s, slide to height, tighten. Zip-tie the USB cable through the wall
slots below the plug.

**Print:** all bodies lie print-ready (bracket rail-face down — its wall
leans 15°, self-supporting). PETG/ASA, 0.2 mm layers, ≥4 walls, 40–50 %
infill, no supports.

**Before printing:** caliper the five must-measure items in SPEC.md (USB
port height, board edge stack, button protrusion, rear keep-outs, light
sensor) — the frame windows are cut to photo-derived numbers.

![preview](preview.png)
