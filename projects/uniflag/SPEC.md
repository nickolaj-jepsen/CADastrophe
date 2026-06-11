# uniflag — design spec

Mount a Pimoroni Cosmic Unicorn (32×32 RGB matrix, the owner's
[uniflag firmware](https://github.com/nickolaj-jepsen/uniflag), SimHub over
USB CDC) on the **outboard face of the right wheel-deck upright** of a GT Omega
PRIME Lite, screen facing the driver. All units mm. Status: **design rev 3 —
modelled and geometry-verified** (all three bodies watertight, single-shell,
asserts green, strict board/plug collision test renders empty), **not yet
printed**. Reference data: [docs/](docs/) (DXF-exact board geometry,
cross-checked); all five photo-uncertain dimensions caliper-verified below.

## Rev 3 (2026-06-11) — chirality fix + fit corrections

- **Mirror bug**: rev 2's model space (front-view x/y, +z toward the rig) was
  left-handed — every part rendered mirrored. Model space is now +z toward
  the driver and the bracket wall sits at the seat-side plate end; each part
  verified as the exact mirror of its rev-2 counterpart (equal volumes,
  boolean-XOR residue ≤ 1e-5 %) **before** the fit corrections below.
- **Yaw raised 15° → 25°** (`yaw=25`): the panel now aims more squarely at the
  seat. The wall is still self-supporting at this lean; the wall foot's outer
  corner and the gusset toes now sink below the bed, so `bracket()` clips the
  leaned wall back to the bed plane (z=0). Bracket envelope grows to
  99×210×51.
- **First-layer relief reworked**: the elephant-foot rebate left an overhanging
  ledge, so it is now a three-step 45° staircase on every bed-face perimeter
  (`foot_relief`), plus a squish countersink on the frame's rear M5 rims so the
  wall-contact face seats flat.
- Caliper second pass: **USB centre 17** (was 23 — mis-measured): window
  y 11–23, M5 row 1 → board-y 30, just **above** the tunnel (below it the
  counterbore reaches the bottom-left ear's nut pocket — now asserted).
  **Light sensor on the front-view LEFT edge** (x ≈ 4, y ≈ 116): the rev-2
  "right edge" record was read in the mirrored convention.
- Ring: full four-edge lip, sensor window y 108–124 in the left lip; button
  notches deleted (plungers actuate behind the board — the frame reach-ins
  cover them); **USB cut skirt-deep only** (the boot tops out at the board's
  front face, tested) so the face ring runs unbroken.
- M4 sandwich: **5 bolts** — the mid-bottom ear sat on the Qw/ST cluster and
  its keep-out breached the bore; rear-lip keep-outs now stop at the board
  clearance line, keeping ≥1.1 mm walls on the bottom corner bores.
- Bracket wall spans only the plate's straight edge (pl_r short per end) —
  its ends meet the plate edge at the corner-arc tangents; no overhang past
  the rounding, all joints planar.

## Rev 2 (superseded — printability rework, 2026-06-11)

Rev 1 verified geometrically but printed badly: its frame carried a back
rib floating 8 mm over the open window (a 198 mm supported span) plus
24 mm M5 boss columns, and its bracket needed a 100 mm wall + arm to reach
them. Rev 2 replaces all of that with a **flat bolt flange**: the frame is
a uniform 12 mm deep ring whose left band extends railward, and the wall's
driver face bolts directly against the frame's back plane.

- Fasteners: 4× M8×14 (rail), **4× M5×30** in a 2×2 grid through the flange
  (columns 5.5/19.5 outside the board's left edge, rows at board-y 8/186
  straddling the USB tunnel; socket heads sink into 5.5 mm front
  counterbores — the 6.5 mm floor bears the preload in pure compression
  against the wall face — washers + nuts on the wall's monitor side, 10.5 mm
  thread proud), 6× M4×14 (ring sandwich, captive nuts in back-opening
  pockets, unchanged).
- Out-of-plane ("door-hinge") stiffness comes from the 14 mm column couple
  plus the full flange-on-wall contact patch — rev 1's rib bolts are gone.
  Static moment is ~0.3 Nm; the preloaded contact gaps at >7 Nm per bolt.
- The board floats in a fixed 2.35 channel (`pcb 2.0 + chan_slack 0.35`) and
  never sees bolt preload.
- Bracket: 80×210×8 rail plate (corner r6 for warp relief), M8 rows at
  25/185, wall leaning 15° — now only ~40 mm up the lean (top of part
  ≈ 50 mm), three weak-axis gussets, zip-tie slots through the wall foot
  below the flange edge.
- **Print orientation is load-bearing for the frame:** it prints back-face
  down, so the finger windows / USB tunnel are front-opening notches whose
  3 mm continuous backing strip prints flat on the bed. (Front-face down,
  that strip is an unsupported bridge — and cutting the notches full-depth
  instead severs the band: the left and right windows overlap over board-y
  43–73, which split the ring in two. Both were tried.)
- No supports, no bridges, on any part.
- Envelopes: bracket 90×210×50, frame 239×221×12, ring 221×221×5.35 — each
  fits the A1 bed (asserted).

## Decisions (owner interview, 2026-06-10)

| Decision | Choice | Why |
|---|---|---|
| Upright orientation | 80 mm fore-aft → outboard face is 80 mm wide, two vertical T-slots at 20/60 | owner confirmed; matches ebrake-verified slot geometry |
| Bracket face | Outboard face, gusseted L-bracket | two slot columns → 4-bolt pattern beats the rear face's single slot |
| Rail fasteners | 4× M8×14 + slide-in T-nuts, 2 columns × 40 mm, row spread free | owner's bin; same interface the ebrake bracket verified |
| Panel aim | **25° yaw toward the seat** (started at 15°, tuned up at rev 3); exposed as a parameter | owner prefers the panel "looking at" the seat; re-print to tune |
| Vertical position | Panel top ≈ wheel-deck beam underside; **slides freely** (vertical slots) | height is a fit-time knob, not committed geometry |
| Junction clearance | None needed — outboard face is clean below the beam | owner checked |
| Data/power | One permanent USB cable from the PC (SimHub → USB CDC) | owner's setup; firmware repo confirms |
| USB exit | Board as-shipped: **micro-B through the left edge toward the upright**, straight plug, **gap = 42 mm** | off-the-shelf cable; measured 30 mm boot + bend room; cable drops straight down the slot region |
| Removability | Permanent — plain bolted joints everywhere | owner: lives on the rig |
| Vibration | Direct drive ≤10 Nm: generous gussets, ≥4 walls, short cantilever | owner's base |
| Cable clips | Not wanted; bracket carries a strain-relief anchor near the port | owner manages cables |
| Board fixing | **Perimeter picture-frame — zero M2 hardware.** Front ring laps ≤5 mm onto the front border; M4 + captive hex nuts clamp ring → board → rear frame | M2 annoying to source (owner); kills the rear-standoff risk; leaves the back open for the speaker |
| Fitted extras | Bare board; metal legs come off; **speaker in use** → back stays open | owner |
| Frame ↔ bracket joint | Bolt flange, M5 through-bolts + nuts (rev 2: counterbored heads, nuts behind the wall) | owner has M4/M5 nuts |
| Repo layout | **One project, multi-body STL**: `uniflag.scad` lays the three parts out flat; slicer splits objects. `part = "plate"|"bracket"|"frame"|"ring"` customizer | no tooling changes; shared dims in one file |

## Owner's hardware bin

M4×14, M4×30, M5×14, M5×30, M6×18, M6×40, M8×14; M4/M5 hex nuts; M8 T-nuts.
Design uses **M8×14** (rail), **M5** (flange), **M4** (frame sandwich) only.

## The three printed parts

1. **Bracket** — plate on the upright (4× M8 clearance, 2×40 mm columns, rows
   spread for pitch stiffness) + a short gusseted wall carrying the 25° yaw;
   the frame's flange bolts flat against its driver face. Prints rail-face
   down (ebrake recipe: elephant-foot chamfer, countersunk bore rims,
   teardropped horizontal bores), zip-tie slots through the foot.
2. **Rear frame** — structural ring behind the board's perimeter (~213 sq
   outline) whose left band extends railward into a flat 2×2 M5 bolt flange
   (counterbored heads). M4 hex pockets for the sandwich. Touches the board
   only at the perimeter; rear lips segmented around the rear-edge keep-outs.
   Uniform 12 deep; prints back-face down.
3. **Front ring** — ≤5 mm lip over the board's ~6 mm dark border (LED packages
   start 7.25 mm in), clamps the board against the rear frame via M4s outside
   the board outline. Prints flat, face down.

## Board interface geometry (DXF-exact unless noted; origin front bottom-left)

- Outline **204.00 × 204.00**, corner r3, max depth 10.2 (at the JST connector).
- Edge cutouts the frame must provide:
  - left wall: **USB window** y ≈ 11–23 (port centre 17, caliper-confirmed
    2026-06-11 second pass), **A/B/C/D button window** y ≈ 40–86 (buttons at 44.6/56.8/68.8/80.8 ±1)
  - right wall: **button window** y ≈ 6–72 (Lux−/Lux+/Zzz/Vol−/Vol+ at 9.2/21.1/~37/57.4/69.3 ±1)
  - buttons rear-mounted with **flush** plungers — nothing protrudes (caliper 2026-06-11)
- Rear-lip keep-outs (rear face, near edges): Pico x ≈ 1–53 / y ≈ 4–30
  (left-bottom), Qw/ST + RESET bottom-centre (x ≈ 75–107, y ≲ 25), JST at
  ~(119, 18). Top edge and right edge y > 72 are clean (±3, photo-derived).
- Top hanging slot x 94–110 — treat as keep-out, don't rely on it.
- Front lip: stay out of the speaker grille (x 134–152, y 30–42 — interior, a
  ≤5 lip never reaches it) and the **light sensor**: front face, **left-hand
  edge, x ≈ 4, y ≈ 116** (caliper; the earlier "right edge x ≈ 198–202" reads
  were taken in the rev-2 mirrored convention — 204 − 200 = 4) → the ring runs
  a full four-edge lip with a **sensor window at y 108–124 in the left lip**.
- Edge buttons (caliper 2026-06-11): rear-mounted, **flush** plungers, bodies
  ~5 in from the edge on the back — nothing protrudes, so the locating skirt
  may run at `bd_clr` along the button rows.

## Loads

Catalog weight 400 g incl. kit → design the cantilever for **500 g** at
~60 mm offset from the rail face plus DD buzz: trivial static moment (~0.3 Nm);
stiffness, not strength, drives the sections. Four preloaded M8s carry it the
same way the ebrake's do (its audited loads were ~40× higher).

## Caliper results (owner, 2026-06-11) — all five measured, model updated

Full provenance in [docs/verified-dimensions.md](docs/verified-dimensions.md).

| # | Measured | Model consequence |
|---|---|---|
| 1a | USB port centre **23** above the bottom edge (photos said ~17!) — **mis-measured; corrected to 17 on the second pass** (the photos were right) | `usb_cy=17`, window `usb_y=[11,23]`, M5 row 1 at board-y 30 (above the tunnel) |
| 1b | Plug boot **30** past the edge | `plug_len=30`, `gap` 40 → **42** to keep rail clearance |
| 2 | Border stack **~2.0** (not bare 1.6 PCB) | `pcb_t=2.0` → channel 2.35; ring now 5.35 thick; M4 stack re-checked by asserts |
| 3 | Buttons rear-mounted, **flush** plungers, bodies ~5 in from the edge | nothing protrudes → windows are fingertip reach-ins: `btn_nd` 6 → 9, left window [43,84]; rear keep-outs already covered the bodies |
| 4 | Rear component boxes confirmed roughly right | keep-outs unchanged |
| 5 | Light sensor at **y ≈ 116** on the right edge (x ≈ 200) — **edge corrected on the second pass: front-view LEFT, x ≈ 4** (the first read used the rev-2 mirrored convention) | four-edge lip with a sensor window y 108–124 in the left lip |

All three bodies re-verified watertight/single-shell and the strict collision
test (board + measured 30 mm boot ghost) renders empty. Rev 3: the boot tops
out at the board's front face (tested), so the ring's USB cut is skirt-deep
only and the face ring runs unbroken — no C-shaped rim.
