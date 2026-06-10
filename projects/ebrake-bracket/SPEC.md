# E-brake bracket — design spec

Measured interfaces and design rationale for `ebrake-bracket.scad` (the source
of truth). All units millimetres. Status: **design rev 2** — rev 1 was printed
and test-fitted (holes line up on both the handbrake and the rail; `leg_h=75`
kept); rev 2 keeps every verified interface, is geometry-verified (watertight,
bbox, 28 clearance asserts) and audited (assembly access, printability, code,
design review), but is not yet printed.

## Why rev 2

Rev 1 bolted up to both the handbrake and the rail, and the shelf sits flush
with the profile top — all kept. But rev 1's **upper rail bolts (y = ±44,
z = 60) are unreachable with the handbrake mounted**: the handbrake's
corner-bolt nuts hang at y = ±43 just below the shelf, directly in the
hex-key path. The two fasteners interlock the assembly order and make on-rig
adjustment impossible.

**The fix:** the upper rail-bolt pair moves inboard to **y = ±13** — into the
open 46 mm channel between the gussets. T-nuts slide along the slot, so any y
is valid; the lower pair stays wide at y = ±44. The hex-key path to the upper
bolts clears the nearest handbrake hardware by 15 mm, the gussets by 3.5 mm,
and the shelf underside by 4 mm — verified numerically in the audit.

## Interfacing hardware

### Handbrake base plate — measured with calipers
| Feature | Value | Notes |
|---|---|---|
| Plate length | 104 | long axis → runs along the rail / pull axis |
| Plate width | 52 | short axis → runs inboard |
| Corner-hole pattern (length) | **86** c-c | hole centre-to-centre |
| Corner-hole pattern (width) | **35** c-c | hole centre-to-centre |
| Corner-hole diameter | ~8 (M8) | bracket holes modelled at 8.5 clearance |
| Body fixing | 2 central oval slots | NOT used by this bracket |

Generic red-anodized USB hall-effect handbrake (vertical pull), bought as
["Laroal 64 Bit USB Handbrake" on Amazon.de](https://www.amazon.de/-/en/dp/B0F17VZ6LT).
It is a commodity whitelabel sold under dozens of one-off Amazon brands; no
true original manufacturer is verifiable, but every unit's firmware enumerates
as "ODDOR-handbrake" and the bundled manual is ODDOR's, so the
[ODDOR AliExpress store](https://www.aliexpress.com/store/1103335664) is the
canonical source. Earliest known listing of the design:
[COLOR TREE on Amazon.com, Nov 2018](https://www.amazon.com/dp/B07K8JWHRV),
then labelled "14 bit" — the advertised bit count (14 → 16 → 64) is marketing
on identical spring + hall-sensor hardware. USB lead exits the underside; no
cable pass-through is required in the bracket (route it outboard of the
gussets — the centre channel is the service path to the upper bolts).

### Rig rail — GT Omega PRIME Lite
| Feature | Value | Notes |
|---|---|---|
| Profile | 8040 (80 × 40) | 40-series aluminium extrusion |
| T-slot | 8 mm | standard for 40-series |
| Fasteners | M8 T-nuts | ~20 long → upper pair at 26 pitch has ~6 slack |
| Mounting face | 80 mm inner vertical face | leg bolts flat to it |
| T-slot centres | 20 / 60 above leg bottom | verified against the rail |

## Coordinate frame

Origin at the **bottom-rear corner** of the leg (where the leg meets the rail
face, at the bottom).

- **X** = inboard — the cantilever direction (normal of the rail inner face).
  Leg occupies X ∈ [−leg_th, 0]; the shelf cantilevers into +X.
- **Y** = along the rail (fore/aft). **−Y = rearward = the pull direction.**
  The part is symmetric in Y, so it is not handed.
- **Z** = up. Leg rises from 0 to `leg_h`; the shelf is at the top.

## What changed, rev 1 → rev 2

| Area | Rev 1 | Rev 2 | Why |
|---|---|---|---|
| Upper rail bolts | y ±44, z 60 | **y ±13, z 60** | reachable with handbrake mounted |
| Upper bolt seats | flat leg face | ⌀15 spot-faces, 0.6 deep | flat seat through the new fillet |
| Leg–shelf junction | sharp corner | r5 cove fillet, full width | stress riser removed |
| Gusset free edge | straight | concave arc, sagitta 11, 3 mm end lands | lighter, no feathered tips |
| Plate holes | plain bores | teardrop +X, 0.9 truncated apex | they print as horizontal bores |
| Bed-face perimeter | sharp | 0.6 elephant-foot chamfer (45° wedges) | rail-face flatness, flush top edge |
| Bed-face bore rims | sharp | 0.6 countersinks + window rim relief | first-layer squish would bind bolts / lift the leg |
| Shelf plan corners | sharp | R16 inboard / R4 rail-side (buried) | looks; rail-side corner shows the leg's R3 |
| Leg vertical edges | sharp | R3, all four | continuous corner over the full height |
| Leg window | 40 × 44 (z 14–58) | 40 × 37 (z 11–48) | relocated bolts need z 52.5+ |

## Resulting positions (echoed by the model at render time)

- Envelope: 72 (X) × 116 (Y) × 75 (Z) — unchanged from rev 1.
- Plate holes (through the shelf, Z axis): X = {14.5, 49.5}, Y = ±43 — unchanged.
- Rail bolts (through the leg, X axis): lower y = ±44 @ z = 20, upper **y = ±13** @ z = 60.
- Volume ≈ 120.4 cm³ (rev 1: 124.1) → ≈ 76 g in PETG at ~50 % infill+walls.

## Accepted structural tradeoff (audited)

Narrowing the upper bolt row shrinks the bolt group: Σr² about the pattern
centroid drops 38 % and the yaw Σy² drops 46 % vs rev 1. At the design loads
(~200 N pull at ~200 mm lever height → worst-bolt in-plane load rises from
~290 N to ~440 N, hole bearing ~6.5 MPa) this is comfortably inconsequential —
rail-face friction from four preloaded M8s carries most of it, and pitch/prying
resistance (upper-row tension at z = 60) is unchanged. Re-check if the loads
ever grow materially. In exchange, rev 1's upper row was effectively unusable,
so in practice rev 2 is *stiffer than the rev 1 that could actually be
assembled*.

## Verified clearances (encoded as asserts in the model)

- Upper-bolt tool path: 15 to the handbrake bolt washers (asserted ≥ 10).
- Upper spot-faces: 2.5 to the gussets, 11 apart, T-nuts 6 mm slack in the slot.
- Upper bolt heads (⌀13, no washer — the row is only 7 below the shelf
  underside, so 17 mm washers don't fit, same as rev 1): seat in ⌀15
  spot-faces, head top 0.5 below the shelf underside.
- Junction fillet (r5) stops 1 mm short of the handbrake washer footprint.
- Plate holes ≥ 10 from shelf edges; teardrop apexes ≥ 9 from the front edge
  and ≥ 9 from the R16 corner pocket (`corner_hole_margin()`); teardrop slot
  stays ≥ 2 inside the washer seat on the shelf top.
- Handbrake washers clear the gussets by 5.5; lower rail washers clear the
  gussets by 6.5 and the leg edge by 5.5.
- Leg window ≥ 4.5 below the spot-faces, ≥ 3 from the gussets, ≥ 11 off the foot.
- Fits the Bambu A1 bed (256 × 256) in print orientation.

Every bullet above is enforced by an `assert` in the model, so retuning the
advertised knobs (`leg_h`, `rail_top_y`, `corner_r_in`, …) fails loudly instead
of silently carving a hole into the shelf or out the side of the leg.

## Considered and rejected (rev 2 alternatives)

- **Tongue over the rail top, bolting into the top T-slot** — mechanically
  attractive (vertical bolts, supported shelf) but sits proud of the profile
  top, violating the verified flush requirement.
- **Shifting the handbrake hole pattern along Y** — clears the rev 1 bolt
  positions but makes the part asymmetric and needs a wider shelf.
- **Captive hex-nut pockets under the shelf** — one-tool assembly, but adds
  bosses/material and printing fiddliness for a problem the relocated bolts
  already solve.

## Provenance

Rev 1 imported 2026-06-09 from a verified proof-of-concept (`/tmp/ebrake/`,
CadQuery + plain-OpenSCAD prototype), printed and test-fitted the same day.
Rev 2 designed 2026-06-10; audited by four independent review passes
(assembly/tool access, printability, code/manifold, design critique). The
audit caught and fixed: a halved elephant-foot chamfer (over-extension shifted
the wedge hypotenuse), coincident curved faces at the shelf/leg rear corners
(degenerate shells), a teardrop-blind window-margin assert, a `gusset_sag=0`
division-by-zero, and missing guards now in the assert set.
