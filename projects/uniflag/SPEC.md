# uniflag — design spec

Mount a Pimoroni Cosmic Unicorn (32×32 RGB matrix, the owner's
[uniflag firmware](https://github.com/nickolaj-jepsen/uniflag), SimHub over
USB CDC) on the **outboard face of the right wheel-deck upright** of a GT Omega
PRIME Lite, screen facing the driver. All units mm. Status: **design rev 2 —
modelled and geometry-verified** (all three bodies watertight, single-shell,
asserts green, strict board/plug collision test renders empty), **not yet
printed**. Reference data: [docs/](docs/) (DXF-exact board geometry,
cross-checked); all five photo-uncertain dimensions caliper-verified below.

## As built (rev 2 — printability rework, 2026-06-11)

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
| Panel aim | Fixed **15° yaw toward the seat**; yaw + pitch exposed as parameters | owner prefers the panel "looking at" the seat; re-print to tune |
| Vertical position | Panel top ≈ wheel-deck beam underside; **slides freely** (vertical slots) | height is a fit-time knob, not committed geometry |
| Junction clearance | None needed — outboard face is clean below the beam | owner checked |
| Data/power | One permanent USB cable from the PC (SimHub → USB CDC) | owner's setup; firmware repo confirms |
| USB exit | Board as-shipped: **micro-B through the left edge toward the upright**, straight plug, **gap ≈ 40 mm** | off-the-shelf cable; plug + bend fit the gap; cable drops straight down the slot region |
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
   spread for pitch stiffness) + a short gusseted wall carrying the 15° yaw;
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
  - left wall: **USB window** y ≈ 11–23 (port shell y 13.5–20.5, photo-derived —
    *measure*), **A/B/C/D button window** y ≈ 40–86 (buttons at 44.6/56.8/68.8/80.8 ±1)
  - right wall: **button window** y ≈ 6–72 (Lux−/Lux+/Zzz/Vol−/Vol+ at 9.2/21.1/~37/57.4/69.3 ±1)
  - buttons protrude ~1–2 past the outline (*estimate — measure*)
- Rear-lip keep-outs (rear face, near edges): Pico x ≈ 1–53 / y ≈ 4–30
  (left-bottom), Qw/ST + RESET bottom-centre (x ≈ 75–107, y ≲ 25), JST at
  ~(119, 18). Top edge and right edge y > 72 are clean (±3, photo-derived).
- Top hanging slot x 94–110 — treat as keep-out, don't rely on it.
- Front lip: stay out of the speaker grille (x 134–152, y 30–42 — interior, a
  ≤5 lip never reaches it) and the **light sensor**: front face, right-hand
  edge, x ≈ 198–202 (two independent reviews + border geometry), **y unknown**
  (no image source could be measured) → the ring runs **no continuous lip on
  the right edge — corner tabs only**, so the sensor stays exposed at any y.
- Edge buttons protrude ~1.5 nominal (side-actuated SMD tactile class, not
  published) → side walls keep ≥2.5 inner offset from the PCB edge along
  button rows.

## Loads

Catalog weight 400 g incl. kit → design the cantilever for **500 g** at
~60 mm offset from the rail face plus DD buzz: trivial static moment (~0.3 Nm);
stiffness, not strength, drives the sections. Four preloaded M8s carry it the
same way the ebrake's do (its audited loads were ~40× higher).

## Caliper results (owner, 2026-06-11) — all five measured, model updated

Visual guide: [docs/must-measure.svg](docs/must-measure.svg).

| # | Measured | Model consequence |
|---|---|---|
| 1a | USB port centre **23** above the bottom edge (photos said ~17!) | `usb_cy=23`, window `usb_y=[17,29]`; M5 ear #1 moved to y 36 with 1.0 clearances (asserted) |
| 1b | Plug boot **30** past the edge | `plug_len=30`, `gap` 40 → **42** to keep rail clearance |
| 2 | Border stack **~2.0** (not bare 1.6 PCB) | `pcb_t=2.0` → channel 2.35; ring now 5.35 thick; M4 stack re-checked by asserts |
| 3 | Buttons rear-mounted, **flush** plungers, bodies ~5 in from the edge | nothing protrudes → windows are fingertip reach-ins: `btn_nd` 6 → 8, left window [43,84]; rear keep-outs already covered the bodies |
| 4 | Rear component boxes confirmed roughly right | keep-outs unchanged |
| 5 | Light sensor at **y ≈ 116** on the right edge (x ≈ 200) | inside the fully-open right edge — no change; recorded for any future right-lip revision |

All three bodies re-verified watertight/single-shell and the strict collision
test (board + measured 30 mm boot ghost reaching 2.5 behind the board plane)
renders empty. The USB cut now goes through the full ring depth — the boot
crosses the board plane, so the rim is C-shaped there (still one body).

## Superseded: original must-measure list

1. USB port: shell centre height above the bottom edge + plug-boot protrusion
   past the board edge (sizes the left-wall window and the 40 mm gap check).
2. Board edge thickness where the frame channel grips (PCB + front LED panel
   stack — the sandwich channel height; nominal 1.6 PCB + ~2.6 LED).
3. Edge-button protrusion (side-wall offset).
4. Rear-edge component positions vs the segmented rear lips (±3 photo-derived).
5. Light sensor y-position on the right front border (x ≈ 198–202 confirmed;
   the corner-tab ring design tolerates any y, so this only matters if the
   right-edge tabs are ever widened).
