# Pimoroni Cosmic Unicorn — physical & mechanical reference

Researched from the official repos ([pimoroni/unicorn](https://github.com/pimoroni/unicorn), [pimoroni/pimoroni-pico](https://github.com/pimoroni/pimoroni-pico)) and the official product page / CAD files they link to. The shop link in the repos (`shop.pimoroni.com/products/cosmic-unicorn`) redirects to https://shop.pimoroni.com/products/space-unicorns?variant=40842626596947.

**Coordinate convention used below:** front (LED) face, origin at the bottom-left corner of the PCB, X right, Y up, in mm. Extracted from Pimoroni's official DXF (`cosmic_unicorn_with_holes.dxf`), whose outline measures exactly 204.00 x 204.00 mm.

## 1. Board overview

| Property | Value | Source |
|---|---|---|
| Display | 32 x 32 = 1024 RGB LEDs, gamma-corrected, 14-bit, ~300 fps refresh | [cosmic_unicorn module README](https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/cosmic_unicorn/README.md) |
| LED package / pitch | 3.5 mm LEDs with rounded square apertures, 6 mm spacing | [product page](https://shop.pimoroni.com/products/space-unicorns?variant=40842626596947) |
| LED drivers | FM6047 constant-current drivers + SN74HCS138 row decoders (decoders confirmed in schematic) | product page; [schematic PDF](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf?v=1677236038) |
| MCU | Raspberry Pi Pico W (original, board name `Raspberry Pi Pico W (Cosmic Unicorn)`); Pico 2 W on the current revision (`boards/pico2_w_cosmic`) | [mpconfigboard.h](https://github.com/pimoroni/unicorn/blob/main/boards/pico_w_cosmic/mpconfigboard.h); [boards tree](https://github.com/pimoroni/unicorn/tree/main/boards) |
| Wireless | 2.4 GHz Wi-Fi + Bluetooth (CYW43), default hostname `CosmicUnicorn` | [mpconfigboard.h](https://github.com/pimoroni/unicorn/blob/main/boards/pico_w_cosmic/mpconfigboard.h), [mpconfigboard.cmake](https://github.com/pimoroni/unicorn/blob/main/boards/pico_w_cosmic/mpconfigboard.cmake) |
| Power | USB micro-B (on the Pico) or JST-PH battery (5.5 V max, no charging circuit). Measured by Pimoroni at just over 1 A at max brightness full white; blues fade below ~3.6 V | product page |

### GPIO map (official, from [cosmic_unicorn.hpp](https://github.com/pimoroni/pimoroni-pico/blob/main/libraries/cosmic_unicorn/cosmic_unicorn.hpp))

| Function | GPIO |
|---|---|
| COLUMN_CLOCK / DATA / LATCH / BLANK | 13 / 14 / 15 / 16 |
| ROW_BIT_0..3 | 17, 18, 19, 20 |
| LIGHT_SENSOR (phototransistor, ADC, 0-4095) | 28 |
| MUTE (amp enable — software mute, no physical switch) | 22 |
| I2S DATA / BCLK / LRCLK (to MAX98357A) | 9 / 10 / 11 |
| I2C SDA / SCL (both Qw/ST connectors) | 4 / 5 |

## 2. Buttons (9 user buttons + Reset + Pico BOOTSEL)

GPIOs from [cosmic_unicorn.hpp](https://github.com/pimoroni/pimoroni-pico/blob/main/libraries/cosmic_unicorn/cosmic_unicorn.hpp) and the [module README](https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/cosmic_unicorn/README.md). All nine are edge-actuated right-angle tactile switches; brightness/volume/sleep are implemented in software so all are reusable as user inputs. Edge positions read from the official [dimensional drawing](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535) and product photos (approximate, +/-3 mm).

| Button | GPIO | Constant | Location (front view) |
|---|---|---|---|
| A | 0 | `SWITCH_A` | Left edge, ~y 83 (silkscreen "PROGRAM" sits above it, below the mid-left hole) |
| B | 1 | `SWITCH_B` | Left edge, ~y 71 |
| C | 3 | `SWITCH_C` | Left edge, ~y 60 |
| D | 6 | `SWITCH_D` | Left edge, ~y 52 |
| Vol + | 7 | `SWITCH_VOLUME_UP` | Right edge, ~y 72 |
| Vol - | 8 | `SWITCH_VOLUME_DOWN` | Right edge, ~y 62 |
| Zzz (sleep) | 27 | `SWITCH_SLEEP` | Right edge, between VOL and LUX clusters, ~y 44 |
| Lux + (brightness up) | 21 | `SWITCH_BRIGHTNESS_UP` | Right edge, ~y 26 |
| Lux - (brightness down) | 26 | `SWITCH_BRIGHTNESS_DOWN` | Right edge, ~y 14 |
| Reset | RUN pin | — | Back, near bottom centre |
| BOOTSEL | — | — | On the Pico module, back |

Examples confirm labels: "adjust the brightness with LUX + and -", VOL +/- for volume ([examples README](https://github.com/pimoroni/unicorn/blob/main/examples/cosmic_unicorn/README.md)).

**Mount implication: do not enclose the left or right PCB edges — all 9 buttons actuate from those edges.**

## 3. Onboard peripherals

| Peripheral | Detail | Source |
|---|---|---|
| Speaker/amp | MAX98357AETE+T 3.2 W I2S mono amp + 30 mm 1 W speaker, attached to the **back** (front-view lower-right area; tallest back component) | schematic PDF; product page; back product photo |
| Speaker grille | 12 thru-holes Ø2.0 mm, 4x3 grid, 6 mm pitch, x 134-152, y 30-42 | DXF (measured) |
| Light sensor | Phototransistor on GP28/ADC2, front face, `light()` returns 0-4095 | module README; product page |
| Battery connector | JST-PH 2-pin, silkscreened "BATTERY 5.5V MAX", back, bottom-centre-left; no charging hardware onboard | back photo; product page |
| Qw/ST | 2x JST-SH 4-pin (Qwiic/STEMMA QT), I2C on GP4/GP5, side by side on the back at the bottom edge ("1 QW/ST 2") | module README; back photo |
| Mute | No physical switch — GP22 drives the MAX98357A mute/enable in software | cosmic_unicorn.hpp; schematic |
| USB | Micro-B on the back-mounted Pico; **side-entry at the front-view LEFT edge, centred ~20 mm above the bottom edge** (Pico body spans roughly y 9-30 there). Plug enters parallel to the board plane | back product photos (measured from pixels) |

## 4. Physical dimensions & mounting (the load-bearing section)

Primary sources: official comparison chart on the product page, the [dimensional drawing PNG](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535) and the [DXF with holes](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf?v=1689940239) (circle centres extracted programmatically; outline bbox exactly 204.00 x 204.00).

- **Board: 204 x 204 x 10.2 mm** (L x W x D, official chart). Corners rounded ~r3 (inferred from DXF outline control points).
- **7 mounting holes, M2 (2.1 mm drill in CAD), centres 3.0 mm in from board edges, on a 99 mm pitch:**
  - (3, 3), (102, 3), (201, 3) — bottom row
  - (3, 102), (201, 102) — mid left/right (no mid-top hole; the hanging slot is there)
  - (3, 201), (201, 201) — top corners
  - Product page text agrees: "Cosmic's 7 mounting holes are M2, 3mm in from the edge, and equally spaced 99mm horizontally and vertically."
- **4 leg holes, M2.5 (2.55 mm drill in CAD):** (60, 4.6), (144, 4.6) on the bottom edge; (3.5, 31), (197.5, 31) on the sides ("two sets so you can adjust the angle" — for the included metal legs).
- **Hanging slot at top centre:** internal cutout x 94-110 (16 mm wide), y 198.35-201.35 (3 mm tall) with a small central keyhole notch up to y 202.54; ~2.6 mm of material remains above it (DXF, measured).
- **LED active area:** first LED centre at (9, 9), 6 mm pitch, 32x32 → last centre (195, 195); 186 x 186 mm centre-to-centre (dimensional drawing: 9.00 edge offset, 6.00 pitch).
- **Back-side keep-outs for a flush mount:** 30 mm speaker puck (front-view lower-right quadrant, behind the grille at x 134-152 / y 30-42), Pico module along the bottom-left, JST-PH + 2x Qw/ST + Reset along the bottom-centre, edge button bodies along left/right edges. Official overall depth is 10.2 mm; with ~1.6 mm PCB and ~2 mm front LEDs that implies roughly 6-7 mm of rear component height (speaker tallest) — standoffs of >= 8 mm are a safe starting point, verify physically.
- **Cable clearance:** micro-USB enters from the front-view left edge ~20 mm above the bottom corner; leave >= 30 mm lateral clearance for plug + bend. Battery/Qw/ST cables exit downward from the back bottom edge.
- Mechanically, the Pico W and Pico 2 W revisions share the same PCB CAD: the current product page still links the Feb-2023 schematic and Jul-2023 drawing/DXF for Cosmic.

## 5. Documentation links found in the repos

From [pimoroni/unicorn README](https://github.com/pimoroni/unicorn/blob/main/README.md):
- Firmware releases: https://github.com/pimoroni/unicorn/releases/latest (separate Pico W / Pico 2 W builds)
- Cosmic Unicorn function reference: https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/cosmic_unicorn/README.md
- PicoGraphics docs: https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/picographics/README.md
- Learn guide: https://learn.pimoroni.com/article/getting-started-with-pico
- Shop (Cosmic 32x32, Pico 2 W): https://shop.pimoroni.com/products/space-unicorns?variant=40842626596947

From the product page:
- Schematic: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf?v=1677236038
- Dimensional drawing: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535
- DXF outline with holes: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf?v=1689940239
- DXF outline without holes: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_without_holes.dxf?v=1689940239

Also in pimoroni-pico: C++ library at `libraries/cosmic_unicorn/` ([README](https://github.com/pimoroni/pimoroni-pico/blob/main/libraries/cosmic_unicorn/README.md), [cosmic_unicorn.hpp](https://github.com/pimoroni/pimoroni-pico/blob/main/libraries/cosmic_unicorn/cosmic_unicorn.hpp)); MicroPython examples in `pimoroni/unicorn` at [examples/cosmic_unicorn/](https://github.com/pimoroni/unicorn/tree/main/examples/cosmic_unicorn).

## Open questions (need physical measurement or user input)

- Exact rear component stack height above the PCB (speaker puck, Pico module, JST connectors) for standoff length — official depth is 10.2 mm overall with no breakdown; physically measure the speaker height before fixing standoff length (estimate 6-7 mm, suggest >= 8 mm standoffs)
- PCB thickness (assumed 1.6 mm, not published)
- How far the edge-button caps protrude beyond the PCB edge (looks ~1 mm in photos) — affects any side-rail or bezel clearance
- Exact recess of the micro-USB connector relative to the left board edge and minimum plug clearance — measure with the intended cable
- Which revision the user owns (original Pico W vs Pico 2 W, Dec-2024 onward) — mechanically identical per the shared CAD files on the product page, but worth confirming since firmware builds differ
- Exact location of the front-face phototransistor (light sensor) so the mount/bezel does not shade it — small orange parts visible in the drawing but not labelled
- Board weight (not published anywhere found)
- Whether the M2 mounting holes are plated/grounded (affects use of metal screws against an aluminium rig)

## Sources

- [pimoroni/unicorn README (firmware repo)](https://github.com/pimoroni/unicorn/blob/main/README.md)
- [pico_w_cosmic board definition (mpconfigboard.h, pins.csv, cmake)](https://github.com/pimoroni/unicorn/tree/main/boards/pico_w_cosmic)
- [Cosmic Unicorn MicroPython function reference (buttons, GPIO, peripherals)](https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/cosmic_unicorn/README.md)
- [cosmic_unicorn.hpp — official pin constants](https://github.com/pimoroni/pimoroni-pico/blob/main/libraries/cosmic_unicorn/cosmic_unicorn.hpp)
- [Cosmic Unicorn C++ library README](https://github.com/pimoroni/pimoroni-pico/blob/main/libraries/cosmic_unicorn/README.md)
- [Cosmic Unicorn MicroPython examples README (button labels in practice)](https://github.com/pimoroni/unicorn/blob/main/examples/cosmic_unicorn/README.md)
- [Product page (Space Unicorns — Cosmic 32x32 variant; redirect target of shop.pimoroni.com/products/cosmic-unicorn)](https://shop.pimoroni.com/products/space-unicorns?variant=40842626596947)
- [Cosmic Unicorn schematic PDF](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf?v=1677236038)
- [Cosmic Unicorn dimensional drawing](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535)
- [Cosmic Unicorn DXF outline with holes (exact hole coordinates)](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf?v=1689940239)
- [Cosmic Unicorn DXF outline without holes](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_without_holes.dxf?v=1689940239)
- [Back product photo (Pico/USB/speaker/connector locations)](https://shop.pimoroni.com/cdn/shop/files/cosmic-unicorn-2_1500x1500_crop_center.jpg?v=1740062334)
- [Unicorn firmware releases (Pico W vs Pico 2 W builds)](https://github.com/pimoroni/unicorn/releases/latest)
