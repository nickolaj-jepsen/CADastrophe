# uniflag docs

Reference material for mounting a Pimoroni Cosmic Unicorn (32×32 RGB LED
matrix, used as a sim-racing "virtual flag") on the right wheel-deck upright of
a GT Omega PRIME Lite (8040 profile). Drawn from the official Pimoroni repos,
product pages, and the official DXF/dimensional drawing. The board interface
that the model actually cuts to lives in [../SPEC.md](../SPEC.md); these are the
upstream facts it was derived from.

## Contents

- [hardware-reference.md](hardware-reference.md) — the board reference: outline,
  mounting holes, LED grid, rear component map, edge buttons, peripherals, GPIO,
  light sensor, and the official CAD/DXF links.
- [rig-interface.md](rig-interface.md) — the GT Omega side: 8040 profile,
  T-slots, panel placement, and the owner-interview decisions.

Firmware: the panel runs the owner's own
[uniflag](https://github.com/nickolaj-jepsen/uniflag) firmware (Rust +
embassy-rs), fed by SimHub over USB CDC — a permanent data+power cable, which is
why the bracket carries a strain-relief anchor.

## The numbers the model cuts to

| Fact | Value |
|---|---|
| Board envelope | 204 × 204 × 10.2 mm (depth is max, at the JST battery connector) |
| Border stack thickness | ~2.0 mm |
| USB port | micro-B, front-view **left** edge, centre 17 mm above the bottom; boot 30 mm past the edge |
| Edge buttons | rear-mounted, **flush** plungers — nothing protrudes; left A/B/C/D, right Vol/Zzz/Lux |
| Light sensor | front face, **left** edge, x ≈ 4, y ≈ 116 |
| Mounting holes | 7× M2 (⌀2.1), 3 mm in, 99 mm pitch — **unused** (this mount grips the perimeter, no M2 hardware) |
</content>
