# uniflag docs

Reference material for mounting a Pimoroni Cosmic Unicorn (32×32 RGB LED
matrix, used as a sim-racing "virtual flag") on the right wheel-deck upright of
a GT Omega PRIME Lite (8040 profile). Compiled 2026-06-10 from the official
Pimoroni repos, product pages, and the official DXF/dimensional drawing; every
dimension claim was cross-checked by an independent pass
(see [verified-dimensions.md](verified-dimensions.md)).

## Contents

- [must-measure.svg](must-measure.svg) — **the pre-print checklist as a
  picture**: the five caliper measurements drawn on the board, with the
  model parameter each one feeds.
- [verified-dimensions.md](verified-dimensions.md) — every dimension with a
  confirmed/conflicting/single-source verdict, plus the must-measure list
  in prose.
- [mechanical.md](mechanical.md) — mounting holes, board outline, rear
  component map, edge buttons. The load-bearing doc for the mount design.
- [hardware-reference.md](hardware-reference.md) — board overview from the
  official repos: GPIO map, buttons, peripherals, CAD links.
- [product-spec.md](product-spec.md) — official product spec: features,
  connectors, power, what ships in the box.
- [sim-racing-usage.md](sim-racing-usage.md) — SimHub integration, power in
  practice, prior-art mounts, reported gotchas.
- [rig-interface.md](rig-interface.md) — the GT Omega side: profile, slots,
  placement, and the design decisions from the owner interview.

Firmware: the panel runs the owner's own
[uniflag](https://github.com/nickolaj-jepsen/uniflag) firmware (Rust +
embassy-rs), fed by SimHub over USB CDC — see the firmware section in
[sim-racing-usage.md](sim-racing-usage.md).

## The five numbers that matter most

| Fact | Value | Confidence |
|---|---|---|
| Board envelope | 204 × 204 × 10.2 mm (depth is max, at the JST battery connector) | official, DXF-exact |
| Mounting holes | 7× M2 (⌀2.1), 3 mm in from edges, 99 mm pitch — corners (3,3)(201,3)(3,201)(201,201) + mid-left/right/bottom; plain holes, **not threaded** | official, DXF-exact |
| USB port | **micro-B** (on the rear Pico), side-entry through the front-view **left** edge, centre ~17 mm above the bottom edge | official type; photo-derived position — measure |
| Edge buttons | left edge A/B/C/D y≈45–81; right edge Vol/Zzz/Lux y≈9–69 — both side edges must stay actuator-accessible | drawing-derived ±1 mm |
| Rear clearance | ~6 mm component stack (derived); standoffs ≥8 mm advised — **the highest-risk number, measure it** | derived, unverified |
