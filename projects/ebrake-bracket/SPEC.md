# E-brake bracket — design spec

Measured interfaces and design rationale for `ebrake-bracket.scad` (the source
of truth). All units millimetres. Status: **printed and test-fitted** — holes
line up on both the handbrake and the rail; `leg_h=75` kept.

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
cable pass-through is required in the bracket.

### Rig rail — GT Omega PRIME Lite
| Feature | Value | Notes |
|---|---|---|
| Profile | 8040 (80 × 40) | 40-series aluminium extrusion |
| T-slot | 8 mm | standard for 40-series |
| Fasteners | M8 T-nuts | |
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

## Resulting positions (echoed by the model at render time)

- Envelope: 72 (X) × 116 (Y) × 75 (Z).
- Plate holes (through the shelf, Z axis): X = {14.5, 49.5}, Y = {−43, +43}.
- Rail bolts (through the leg, X axis): Y = {−44, +44}, Z = {20, 60}.
- Volume ≈ 124 cm³ → ≈ 87 g in PETG at ~50 % infill+walls.

## Verified clearances (encoded as asserts in the model)

- Plate holes: ≥ 10 to the shelf edges; ≥ 5 material to the shelf window.
- M8 nut/washer (17 OD) under the corner bolts clears the gussets by ~5.5.
- Gussets sit ~10.8 clear of the rail-bolt holes.
- Rail bolt + washer has ~5.5 edge margin on the leg (Y); the **upper bolt row
  is only 7 below the shelf underside** — 13 mm socket heads fit (asserted),
  16 mm-OD washers do not.
- Fits the Bambu A1 bed (256 × 256) in any orientation.

Every bullet above is enforced by an `assert` in the model, so retuning the
advertised knobs (`leg_h`, `rail_pitch_y`, …) fails loudly instead of silently
carving a hole into the shelf or out the side of the leg.

## Provenance

Imported 2026-06-09 from a verified proof-of-concept (`/tmp/ebrake/`, CadQuery +
plain-OpenSCAD prototype). The port preserves the PoC's exposed geometry exactly
(volume delta 0.006 %, tessellation noise) while adding BOSL2 conventions,
`$fa/$fs` resolution, buried union overlaps for manifold safety, and the
clearance asserts above.
