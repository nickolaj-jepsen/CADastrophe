# uniflag — design spec

Mount a Pimoroni Cosmic Unicorn (32×32 RGB matrix, the owner's
[uniflag firmware](https://github.com/nickolaj-jepsen/uniflag), SimHub over
USB CDC) on the **outboard face of the right wheel-deck upright** of a GT Omega
PRIME Lite, screen facing the driver. All units mm. Status: **modelled and
geometry-verified** (all three bodies watertight, single-shell, asserts green,
strict board/plug collision test renders empty), **not yet printed**. Board
geometry in [docs/](docs/).

## Design

The board is held in a perimeter picture-frame and the frame bolts to the rig
through a flat flange — no M2 hardware, nothing in the board's mounting holes,
the back left open for the speaker.

- **Flat bolt flange.** The frame is a uniform 12 mm deep ring whose left band
  extends railward into a 2×2 M5 grid, and the bracket wall's driver face bolts
  directly against the frame's back plane. No standoffs, no boss columns, no
  reach-over arm.
- **Fasteners:** 4× M8×14 (rail), **4× M5×30** in the flange grid (columns
  5.5/19.5 outside the board's left edge, rows at board-y 30/186 straddling the
  USB tunnel; socket heads sink into 5.5 mm front counterbores — the 6.5 mm
  floor bears the preload in pure compression against the wall face — washers +
  nuts on the wall's monitor side, 10.5 mm thread proud), **5× M4×14** (ring
  sandwich, captive nuts in back-opening pockets).
- **Stiffness.** Out-of-plane ("door-hinge") stiffness comes from the 14 mm
  column couple plus the full flange-on-wall contact patch. Static moment is
  ~0.3 Nm; the preloaded contact gaps only above 7 Nm per bolt.
- **Channel.** The board floats in a fixed 2.35 channel (`pcb 2.0 +
  chan_slack 0.35`) and never sees bolt preload.
- **Bracket:** 80×210×8 rail plate (corner r6 for warp relief), M8 rows at
  25/185, wall leaning 25° (~40 mm up the lean, top of part ≈ 50 mm), three
  weak-axis gussets, zip-tie slots through the wall foot below the flange edge.

### Print orientation is load-bearing for the frame

It prints back-face down, so the finger windows / USB tunnel are front-opening
notches whose 3 mm continuous backing strip prints flat on the bed. Front-face
down, that strip is an unsupported bridge; cutting the notches full-depth
instead severs the band, since the left and right windows overlap over board-y
43–73 and split the ring in two. No supports, no bridges, on any part. The
bed-face perimeters get a three-step 45° staircase relief (`foot_relief`) for
first-layer squish, and the frame's rear M5 rims get a squish countersink so
the wall-contact face seats flat.

Envelopes: bracket 99×210×51, frame 239×221×12, ring 221×221×5.35 — each fits
the A1 bed (asserted).

## Model space

Model space is +z toward the driver, with x/y as in the board's front view;
the bracket wall sits at the seat-side plate end. +z must point at the viewer
of the front view: with x right and y up, a rigward +z makes the space
left-handed and silently models the mirror image.

## Decisions (owner interview)

| Decision | Choice | Why |
|---|---|---|
| Upright orientation | 80 mm fore-aft → outboard face is 80 mm wide, two vertical T-slots at 20/60 | owner confirmed; matches ebrake-verified slot geometry |
| Bracket face | Outboard face, gusseted L-bracket | two slot columns → 4-bolt pattern beats the rear face's single slot |
| Rail fasteners | 4× M8×14 + slide-in T-nuts, 2 columns × 40 mm, row spread free | owner's bin; same interface the ebrake bracket verified |
| Panel aim | **25° yaw toward the seat**; exposed as a parameter | owner prefers the panel "looking at" the seat; re-print to tune |
| Vertical position | Panel top ≈ wheel-deck beam underside; **slides freely** (vertical slots) | height is a fit-time knob, not committed geometry |
| Junction clearance | None needed — outboard face is clean below the beam | owner checked |
| Data/power | One permanent USB cable from the PC (SimHub → USB CDC) | owner's setup; firmware repo confirms |
| USB exit | Board as-shipped: **micro-B through the left edge toward the upright**, straight plug, **gap = 42 mm** | off-the-shelf cable; 30 mm boot + bend room; cable drops straight down the slot region |
| Removability | Permanent — plain bolted joints everywhere | owner: lives on the rig |
| Vibration | Direct drive ≤10 Nm: generous gussets, ≥4 walls, short cantilever | owner's base |
| Cable clips | Not wanted; bracket carries a strain-relief anchor near the port | owner manages cables |
| Board fixing | **Perimeter picture-frame — zero M2 hardware.** Front ring laps ≤5 mm onto the front border; M4 + captive hex nuts clamp ring → board → rear frame | M2 annoying to source (owner); kills the rear-standoff risk; leaves the back open for the speaker |
| Fitted extras | Bare board; metal legs come off; **speaker in use** → back stays open | owner |
| Frame ↔ bracket joint | Bolt flange, M5 through-bolts with counterbored heads, nuts behind the wall | owner has M4/M5 nuts |
| Repo layout | **One project, multi-body STL**: `uniflag.scad` lays the three parts out flat; slicer splits objects. `part = "plate"\|"bracket"\|"frame"\|"ring"` customizer | no tooling changes; shared dims in one file |

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

## Board interface geometry (origin front bottom-left)

- Outline **204.00 × 204.00**, corner r3, max depth 10.2 (at the JST connector).
- Edge cutouts the frame provides:
  - left wall: **USB window** y 11–23 (port centre 17), **A/B/C/D button
    window** y 40–86 (buttons at 44.6/56.8/68.8/80.8 ±1)
  - right wall: **button window** y 6–72 (Lux−/Lux+/Zzz/Vol−/Vol+ at
    9.2/21.1/~37/57.4/69.3 ±1)
  - buttons are rear-mounted with **flush** plungers — nothing protrudes
- Rear-lip keep-outs (rear face, near edges): Pico x 1–53 / y 4–30
  (left-bottom), Qw/ST + RESET bottom-centre (x 75–107, y ≲ 25), JST at
  ~(119, 18). Top edge and right edge y > 72 are clean (±3).
- Top hanging slot x 94–110 — treat as keep-out, don't rely on it.
- Front lip: stay out of the speaker grille (x 134–152, y 30–42 — interior, a
  ≤5 lip never reaches it) and the **light sensor** (front face, left-hand
  edge, x ≈ 4, y ≈ 116) → the ring runs a full four-edge lip with a **sensor
  window at y 108–124 in the left lip**.
- Edge buttons: rear-mounted, **flush** plungers, bodies ~5 in from the edge on
  the back — nothing protrudes, so the locating skirt may run at `bd_clr` along
  the button rows.

## Loads

Catalog weight 400 g incl. kit → design the cantilever for **500 g** at
~60 mm offset from the rail face plus DD buzz: trivial static moment (~0.3 Nm);
stiffness, not strength, drives the sections. Four preloaded M8s carry it the
same way the ebrake's do (its audited loads were ~40× higher).
</content>
