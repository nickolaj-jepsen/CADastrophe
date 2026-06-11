# Verified dimensions — cross-checked claims

Every dimension claim from the four research agents, adversarially cross-checked
against the official DXF/product page by a fifth agent. Verdicts: **confirmed** =
multiple sources agree (safe to cut to), **conflicting** = sources disagreed (the
resolution and best value are given), **single-source** = treat with care.

## Board size (L x W x D)
**Verdict: confirmed**

Best value: **204.00 x 204.00 x 10.2 mm (DXF outline bbox exactly 204.0000 x 204.0000; depth is max, at battery connector)**

All four researchers agree. Independently re-verified: parsed official DXF (exact 204.0000 sq), current product page table ('204 x 204 x 10.2 mm'), archived PIM670 page ('204mm x 204mm x 10.2 mm (L x H x D, max depth at battery connector)'). Trust fully for the X/Y envelope; depth is a max, see must-measure for rear clearance.

## Mounting holes (7x M2)
**Verdict: confirmed**

Best value: **7x dia 2.10 mm at (3,3) (102,3) (201,3) (3,102) (201,102) (3,201) (201,201) mm from front-view bottom-left; 99 mm pitch, 3 mm in from edges, no top-centre hole**

Three researchers gave identical coordinates; re-verified by parsing the official DXF circles directly (exact match, r=1.050) and product page text ('7 mounting holes are M2, 3mm in from the edge, equally spaced 99mm'). Safe to cut to these numbers — design for M2 clearance with nut access on the back.

## Mounting hole pattern / corner span
**Verdict: confirmed**

Best value: **4 corners + mid-left + mid-right + mid-bottom; corner-to-corner span 198 mm; top centre has the hanging slot instead of a hole**

usage-prior-art claim, confirmed exactly by the DXF (201-3=198) and dimensional drawing. Trust.

## Leg holes (4x M2.5)
**Verdict: conflicting**

Best value: **dia 2.55 mm at (60.0, 4.6), (144.0, 4.6), (3.5, 31.0), (200.5, 31.0) mm**

firmware-repo's (197.5, 31) is wrong; product-page and mechanical's (200.5, 31) is correct — the DXF circle centre is at board x 200.5 (= 204-3.5, symmetric with the left one). Resolved definitively by parsing the DXF. Use 200.5.

## Hanging slot (top centre)
**Verdict: confirmed**

Best value: **16.0 mm wide, x 94.0-110.0; main slot y 198.35-201.35 (2.65-5.65 mm below top edge) with rounded ends r~1.5; central keyhole bump arcs up to y ~202.5 (~1.5 mm below top edge)**

All three slot claims agree once coordinate conventions are aligned; verified from DXF spline control points. The 202.54 figure is the Bezier control-point max — the true curve apex is a hair lower (~202.45-202.5). Irrelevant unless you hang from it; for a bolted mount treat it as a keep-out.

## LED grid / pitch / active area
**Verdict: confirmed**

Best value: **32x32 = 1024 LEDs, 6.0 mm pitch, 3.5 mm packages; first LED centre ~(9, 9), last ~(195, 195) -> 186 mm centre-to-centre; visible window ~192 x 192 mm (centre-to-centre + package); ~6 mm dark border to board edge**

The 186 mm (centre-to-centre) vs 192 mm (visible) claims are the same fact with different definitions, not a conflict. Pitch and 3.5 mm LED size verbatim on product page; first-row centres independently re-measured from the dimensional drawing at (8.8+/-0.3, 8.7+/-0.3) with 6.01 mm pitch. For a bezel aperture use >=193 mm square centred on the board, or leave the whole face open.

## Speaker grille (front)
**Verdict: confirmed**

Best value: **12x dia 2.00 mm holes, 4x3 grid, 6 mm pitch, x 134-152 / y 30-42 mm (centre 143, 36); 30 mm 1 W speaker behind on rear**

Both claims identical; verified exactly against DXF circles (translated centres 134.0-152.0 x, 30.0-42.0 y, dia 2.000). Don't cover with a solid front frame if audio matters.

## Corner radius
**Verdict: conflicting**

Best value: **3.0 mm**

firmware-repo's ~3 mm is correct; product-page's ~1.4 mm is a misread. The DXF corner is a cubic Bezier from (0,201) to (3,204) with control points offset 1.3431 = 3.0 x 0.5523 (the standard circular-arc kappa), i.e. a 3.0 mm radius fillet. The 1.4 figure is the control-point offset, not the radius. Use r=3 in any pocket that captures the board outline.

## USB port type and location
**Verdict: conflicting**

Best value: **Micro-B (on the Pico, port flush with front-view LEFT edge); metal shell spans y ~13.5-20.5 mm above bottom edge, centreline ~17 mm; plug boot protrudes past the board outline**

Type and edge are confirmed (product page: 'Powered and programmable by USB micro-B'; rear photo). Centreline estimates conflicted: mechanical ~15, product-page ~16, firmware ~20. Independent re-measurement of the official rear photo (scale calibrated to the 204 mm board edge) puts the shell at y 13.5-20.5, centre ~17. Photo-derived only — cut a generous slot (y 11-23 minimum) and caliper before committing.

## Left-edge buttons A/B/C/D (front view)
**Verdict: conflicting**

Best value: **A 80.8, B 68.8, C 56.8, D 44.6 mm above bottom edge; exactly 12.0 mm pitch; 'PROGRAM' silk above at ~y 88-100**

mechanical's values confirmed to +/-0.2 mm by an independent pixel measurement of the official dimensional drawing calibrated against 11 DXF-verified hole positions (4.157 px/mm). firmware-repo's 83/71/60/52 is refuted (wrong pitch, ~2-7 mm off). Keep the band y ~40-86 mm on the left edge unobstructed; still drawing-derived, so leave >=2 mm slack or measure.

## Right-edge buttons (front view)
**Verdict: conflicting**

Best value: **Vol+ 69.3, Vol- 57.4, Zzz ~36-39, Lux+ 21.1, Lux- 9.2 mm above bottom edge**

mechanical's values confirmed to ~0.1 mm by the same calibrated re-measurement (Zzz button itself not resolvable; its silk label sits at y 39.1). firmware-repo's 72/62/44/26/14 is systematically 3-5 mm high — refuted, likely a scale/origin error. Keep right edge y ~6-72 mm clear.

## Rear component height / standoff sizing
**Verdict: conflicting**

Best value: **Officially: max depth 10.2 mm occurs at the JST-PH battery connector (not the speaker). Rear clearance needed ~6 mm derived (10.2 - ~1.6 PCB - ~2.6-2.8 LEDs); standoffs >=7-8 mm are a safe but unverified margin**

firmware-repo's 'speaker is tallest' is contradicted by the archived official PIM670 page: '10.2 mm (L x H x D, max depth at battery connector)'. No per-component heights are published anywhere; everything beyond the 10.2 mm total is arithmetic. The single highest-risk number in the whole mount — measure with calipers.

## JST-PH battery connector (position/height)
**Verdict: single-source**

Best value: **Centre ~(117-121, 18) mm front-view coords; officially the deepest rear part (defines the 10.2 mm); height above rear face ~6 mm derived, not published**

Position is photo-derived only (mechanical researcher; my rough re-measure of the rear photo agrees within ~4 mm). The 'deepest part' status is official. Treat position as +/-4 mm and keep a generous rear pocket there.

## Connector cluster / Qw-ST / RESET (rear, bottom)
**Verdict: confirmed**

Best value: **2x JST-SH Qw/ST side-by-side at front-view x ~89-104, y ~14-25, openings facing the bottom edge; RESET at ~(75-76, 6); battery JST left of centre (rear view)**

product-page and mechanical agree; re-verified against the official 2160 px rear photo (RESET matched at (76,6) exactly, Qw/ST within ~3 mm). All photo-derived: +/-3 mm. Leave the bottom-centre rear region open for cables and reset access.

## Pico W footprint on rear
**Verdict: conflicting**

Best value: **Green PCB measured at front-view x ~1.3-52.8 (51.5 mm = Pico length, sanity check passes), y ~6.5-27; budget keep-out y 4-30 to cover headers/solder**

mechanical said y 4-27, firmware said y 9-30 — both pixel-derived, ~4 mm apart. My re-measurement of the rear photo splits the difference. If a rear boss or rib lands in the bottom-left quadrant, measure first.

## Hole type: plain through-holes, not threaded
**Verdict: confirmed**

Best value: **Plain 2.1 mm PCB drills; secure with M2 screws + nuts (official diffuser kit: M2x12 screws front-to-back, M2x4 standoffs, M2 nuts on the back of the board)**

Verified directly from the diffuser kit page ('Secure everything in place by adding the nuts to the back of the board', Cosmic kit = 4x M2x12 + 4x M2x4 standoffs + 4x M2 nuts). Design the mount with nut pockets or heat-set inserts; do not assume threads in the PCB.

## Diffuser kit hardware
**Verdict: confirmed**

Best value: **Cosmic: 204 x 204 mm acrylic + 4x M2x12 screws + 4x M2x4 standoffs + 4x M2 nuts, occupying the 4 corner holes**

Verified verbatim from shop.pimoroni.com/products/unicorn-diffuser-kit. Relevant if the user stacks the diffuser: the mount then needs longer screws (M2x16+) or must use the 3 non-corner holes.

## Power draw / battery input
**Verdict: confirmed**

Best value: **'Just over 1A' at 5 V, max brightness full white (official measurement); JST-PH battery input 5.5 V max, no onboard charging**

Verified verbatim on the current product page ('We measured Galactic and Cosmic Unicorn as consuming just over 1A at maximum brightness, full white'; 'JST-PH connector for attaching a battery (5.5V max)'; no-charging note present). product-page's extra '3.6-5.5 V recommended / blue fades below 2.9 V' detail was not found on the Cosmic page — treat that fragment as unverified. Irrelevant to geometry; route a USB cable rated >=1.5 A.

## Weight
**Verdict: single-source**

Best value: **Shopify catalog weight 400 g for the Cosmic variant (Pico 2 W listing); net bare-board mass not published anywhere**

Verified the 400 g in the live Shopify variant JSON (Cosmic 32x32 -> weight:400; Galactic 253 g, Stellar 220 g). This is catalog/shipping weight and likely includes legs/cable/box, so the two researchers don't actually conflict — one reported catalog weight, the other correctly noted net mass is unpublished. Design the cantilever for ~500 g and it's covered.

## Pico 2 W variant mechanical parity
**Verdict: confirmed**

Best value: **Same 204 x 204 x 10.2 mm, same 7x M2 / 99 mm hole spec, still USB micro-B**

The current space-unicorns page IS the Pico 2 W listing and carries identical dimensions, hole text, and 'Powered and programmable by USB micro-B'; archived PIM670 (Pico W) page states the same. A mount fits both generations.

## Prior-art board fastening (Skadis mount, M2x6 screws)
**Verdict: single-source**

Best value: **Community design uses 4x M2x6 screws into the board holes with a button-access gap**

Single community source (Printables), not re-verified, and it's for the Galactic not Cosmic. Note the holes are unthreaded — an M2x6 machine screw only works if it threads into the printed plastic or a nut behind; don't copy the screw length blindly. Screw length must be: mount wall + 1.6 mm PCB + nut.

## SimHub serial update rate (free)
**Verdict: confirmed**

Best value: **Free SimHub limits custom serial devices to 10 Hz max**

Verified verbatim from the SimHub wiki ('Free SimHub version is limited to 10Hz'). Plenty for flag-state updates; not a mechanical constraint.

## Must measure with calipers before printing

- Rear standoff clearance: tallest rear components (JST-PH battery connector, 30 mm speaker, Pico + headers) — official only says 10.2 mm max depth at battery connector; the ~6 mm rear stack and >=7-8 mm standoff advice are derived, never measured
- USB micro-B port: centreline height above bottom edge (photo says ~17 mm, claims ranged 15-20) and how far a plugged cable boot protrudes past the front-view left board edge — size the cutout y ~11-23 mm minimum and leave >=10 mm side clearance until measured
- PCB thickness (assumed 1.6 mm standard; not published anywhere) — affects M2 screw length through mount + board + nut
- Edge button heights and protrusion past the board edge if the mount frame wraps either side edge (left A/B/C/D at y 80.8/68.8/56.8/44.6; right cluster y 9.2-69.3, all +/-1 mm from drawing, not calipers)
- Pico W rear footprint extent (PCB measured ~x 1-53, y 6.5-27 front-view; claims disagreed by up to 5 mm) if any rear rib or boss lands in the bottom-left region
- Actual board mass: Shopify lists 400 g for the Cosmic variant but that is catalog/shipping weight (incl. legs, cable, box); net board mass is unpublished — matters for cantilever moment on the 8040 upright

## Light sensor (front face) — follow-up research

**Verdict: position partially confirmed**

Best value: **front face, right-hand edge, x ≈ 198–202 mm (centre ~200); y UNKNOWN**

Two independent text sources agree on "right-hand edge of the front"
([Raspberry Pi Official Magazine review](https://magazine.raspberrypi.com/articles/cosmic-unicorn-pico-w-aboard-review),
[drjonea.co.uk review](https://drjonea.co.uk/2024/04/10/pimoroni-cosmic-unicorn-review-setup-32x32-rgb-leds-powered-by-pi-pico-w/));
x derived from the 7.2 mm dark border geometry. The y-position could not be
measured from any image source this session. Mount consequence: no continuous
front lip on the right edge (corner tabs only) until measured.

## Edge button protrusion — follow-up research

**Verdict: single-source (component-class inference)**

Best value: **~1.0–1.5 mm past the board outline (1.5 nominal), ~0.2–0.3 mm travel**

No published figure; inferred from the side-actuated SMD tactile switch class
(C&K PTS815 / Alps SKRT). Design side walls with ≥2.5–3 mm inner offset from
the PCB edge along button rows. Photo-unverified — caliper it.

## Owner caliper pass (2026-06-11) — definitive values

These supersede every photo-derived estimate above:

- **USB port centre: 23 mm** above the bottom edge (photo estimates said
  ~15–20 — all were wrong by 3–6 mm). Plug boot **30 mm** past the board
  edge with the owner's cable.
- **Border stack: ~2.0 mm** (not the assumed bare 1.6 PCB).
- **Edge buttons: rear-mounted, flush plungers** — nothing protrudes past
  the board outline; switch bodies sit ~5 mm in from the edge on the back.
  The "1–1.5 mm stick-out" inference above is wrong.
- **Rear component map: confirmed** roughly as drawn (±3 mm boxes hold).
- **Light sensor: y ≈ 116 mm** above the bottom edge, on the right-edge
  front border (x ≈ 200) — the previously unknown coordinate.

### Second pass (2026-06-11, after the rev-3 chirality fix) — two corrections

- **USB port centre: 17 mm** above the bottom edge, not 23 — the first pass
  mis-measured; the photo estimate (~17, shell y 13.5–20.5) was right after
  all. Window moved to y 11–23.
- **Light sensor: front-view LEFT edge (x ≈ 4), y ≈ 116** — same side as the
  USB/Pico. The first pass's "right edge (x ≈ 200)" was read against the
  rev-2 model, which was mirrored left-right (see the uniflag.scad header);
  204 − 200 = 4. The y value stands.
