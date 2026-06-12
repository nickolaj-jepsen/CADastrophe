# Rig interface — GT Omega PRIME Lite, right wheel-deck upright

Facts about the rig side of the mount. Sources: the ebrake-bracket project
(same rail system, interface verified by a printed test fit) and the owner's
answers in the design interview (2026-06-10).

## The profile

| Feature | Value | Source |
|---|---|---|
| Rig | GT Omega PRIME Lite | owner |
| Profile | 8040 (80 × 40), 40-series aluminium extrusion | ebrake SPEC, verified |
| T-slot | 8 mm | ebrake SPEC, verified |
| Fasteners | M8 T-nuts (slide-in, ~20 mm long along the slot) | ebrake SPEC, verified |
| Slot spacing on the 80 mm face | two slots, centres at 20 / 60 across the face (40 mm pitch) | ebrake SPEC, verified against the rail |

## The mounting location

- **Right wheel-deck upright**, oriented with the **80 mm dimension fore-aft**:
  the outboard (right-facing) face is the wide one with **two vertical T-slots**.
- That outboard face is **clean** — no corner gussets or bolt heads below the
  wheel-deck beam junction, so the bracket can sit anywhere along the slots.
- T-slots run vertically → **mount height is freely adjustable** by sliding the
  T-nuts; height is a fit-time tuning knob, not a committed dimension.

## The panel placement (owner's sketch, driver's-eye front view)

- Panel fully **outboard of the upright**, screen facing the driver.
- Small gap between the upright and the panel's left edge (sketch scale
  ~20–40 mm; **final `gap` = 42 mm**, driven by the measured 30 mm USB boot +
  bend room).
- Panel **top edge ≈ underside of the wheel-deck beam** (just below wheel-hub
  height).
- **Fixed 25° yaw toward the seat** (exposed as a parameter, default `yaw=25`).

## Environment / decisions from the interview

- Wheel base: **direct drive, ≤10 Nm** — noticeable frame buzz. Bracket gets
  generous gussets, ≥4 walls, short cantilever.
- Panel **lives on the rig permanently** — plain bolted interfaces, no
  quick-release.
- Data + power arrive over **one USB cable from the PC** — the bracket needs a
  cable path + strain relief near the panel's USB port; no separate slot cable
  clips wanted.
- Printer: Bambu A1 (256 × 256 bed). Materials on hand per the ebrake project:
  PETG/ASA.
