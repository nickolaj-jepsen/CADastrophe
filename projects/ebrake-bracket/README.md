# ebrake-bracket

Gusseted L-bracket that mounts a generic USB hall-effect handbrake
([bought as "Laroal 64 Bit"](https://www.amazon.de/-/en/dp/B0F17VZ6LT) —
canonically an [ODDOR handbrake](https://www.aliexpress.com/store/1103335664))
to the inner vertical face of a GT Omega PRIME Lite 8040 side rail — handbrake
upright on the shelf, lever pulling straight back toward the seat. Shelf top
flush with the profile top; symmetric in Y, so it fits either side of the rig.

This is **design rev 2**. Rev 1 was printed and test-fitted (both hole
patterns verified, `leg_h=75` kept) but its upper rail bolts (y ±44) sat
directly behind the handbrake's corner-bolt nuts — unreachable with the
handbrake mounted. They now live at **y ±13, between the gussets** (T-nuts
slide, so any y works); the lower pair stays wide at ±44. Handbrake and
bracket can each be (un)mounted with the other in place.

Also in rev 2: r5 cove fillet along the leg–shelf junction with ⌀15
spot-faced bolt seats, concave-arc gussets, teardropped plate holes,
elephant-foot chamfer + hole countersinks on the bed face, rounded corners.
Envelope unchanged at 72 × 116 × 75, ≈ 120 cm³ (rev 1: 124).

**Key params (mm):** `leg_h=75` (shelf height — *the* tuning knob for shifter
clearance; flush with the profile top, verified) · plate holes `bp_hole_d=8.5`
(M8) @ 86×35 c-c, measured · rail bolts lower y=±44 z=20, upper y=±13 z=60
(the 80 mm face T-slots) · `plat_th=8`, `leg_th=8`, gussets 52×56×6 with
sagitta-11 concave edge · `fillet_r=5`, `spot_d=15`.

**Hardware:** 4× M8 + nut underneath (handbrake → shelf), 4× M8×16 + T-nut
(leg → rail). Upper rail bolts: bare socket heads in the spot-faces — washers
don't fit under the shelf. Upper T-nuts sit 26 mm apart in one slot (~6 mm
slack between 20 mm nuts).

**Assembly notes** (from the design audit):
- Upper rail bolts want a **long ball-end 6 mm key** (or a 1/4″ 6 mm bit
  socket + ≥100 mm extension) driven straight in along the channel between
  the gussets, from beyond the shelf edge.
- Handbrake nuts: torque the bolts from above, holding each nut with an
  open-end wrench from the side — a socket straight from below clips the
  lower rail-bolt heads on the rear pair.
- PETG creeps: ~3–4 N·m on the M8s, re-torque after a day. ASA shrugs.
- Route the USB lead outboard of the gussets, not through the centre channel —
  that's the service path to the upper bolts.

**Print:** rail face on the bed, for the fit-check *and* the final part — it's
support-free, and layers stack inboard (X) so the pull (−Y) and the part's
weight (−Z) load every layer in-plane rather than across the layer bond. Only
ceilings are the 8 mm-deep window rims and ~2 mm teardrop caps. No brim needed
(~70 cm² bed contact). Fit-check: 0.28 mm layers, 15 % gyroid. Load-bearing:
PETG/ASA, ≥4 walls, 40–50 % infill. FDM holes shrink — add ~0.1 mm X-Y hole
compensation if the M8 bolts bind; the bed-side bore countersinks already
guard against first-layer squish.

Measured interfaces, coordinate frame, rev 1 → rev 2 changes, and verified
clearances: [SPEC.md](SPEC.md).
