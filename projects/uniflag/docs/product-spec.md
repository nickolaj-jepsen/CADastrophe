# Pimoroni Cosmic Unicorn — Physical/Mechanical Specification

## Product identity and revisions

| Revision | SKU | Status | MCU | Flash | Source |
|---|---|---|---|---|---|
| Cosmic Unicorn (Pico W Aboard) | PIM670 | retired (sold 2023 – late 2024) | RP2040 (Pico W aboard), dual M0+ @133 MHz, 264 kB SRAM | 2 MB QSPI | [archived product page](http://web.archive.org/web/20230603051615/https://shop.pimoroni.com/products/cosmic-unicorn) |
| Cosmic (32x32), "Pico 2 W Unicorn" | PIM735 | current (since mid-Dec 2024) | RP2350 (Pico 2 W aboard), dual M33 @150 MHz, 520 kB SRAM | 4 MB QSPI | [current product page](https://shop.pimoroni.com/products/space-unicorns) |

`https://shop.pimoroni.com/products/cosmic-unicorn` now lands on the merged "Pico 2 W Unicorn" page (`/products/space-unicorns`) covering Stellar/Galactic/Cosmic. **Board dimensions, mounting provisions, drawing/DXF links and the spec text are identical for both revisions** — the current page links the same PIM670-era dimensional drawing and DXFs.

## Official Features list (verbatim, current page; archived PIM670 page wording matches except MCU)

- "Raspberry Pi Pico 2 W Aboard" *(PIM670: "Raspberry Pi Pico W Aboard")*
- "Powered and programmable by USB micro-B" — **note: micro-B, not USB-C, on both revisions**
- "2.4GHz wireless"
- "1,024 RGB LEDs in a 32 x 32 grid" *(current page: "256/583/1024 RGB LEDs in a 16x16/53x11/32x32 grid")*
- "3.5mm LEDs with rounded square apertures"
- "6mm LED spacing"
- "Driven by 12 FM6047 constant current LED drivers"
- "MAX98357 3.2W I2S Mono Amplifier (with 30mm 1W speaker)"
- "Phototransistor for light sensing"
- "9 tactile user buttons"
- "Reset button"
- "2x Qw/ST (Qwiic/STEMMA QT) connectors"
- "JST-PH connector for attaching a battery (5.5V max)"
- "Fully assembled", "No soldering required"
- Display refresh "around 300 times per second (300fps!)" at 14-bit precision

Source: https://shop.pimoroni.com/products/space-unicorns and http://web.archive.org/web/20230603051615/https://shop.pimoroni.com/products/cosmic-unicorn

## Dimensions (official)

> "Measurements: 204mm x 204mm x 10.2 mm (L x H x D, max depth at battery connector)" — [archived PIM670 page](http://web.archive.org/web/20230603051615/https://shop.pimoroni.com/products/cosmic-unicorn); the current page's comparison table also lists Cosmic as "204 x 204 x 10.2 mm".

- The **board** is 204 x 204 mm; the user's remembered "~192 x 192 mm" is the **LED window**: 32 LEDs at 6 mm pitch = 186 mm between outer LED centres, ~189.5–192 mm visible LED area centred on the board (≈6 mm dark border all round). Pimoroni's matching acrylic diffuser is 204 x 204 mm.
- Board outline (from official DXF): 204.00 x 204.00 mm square with ~1.4 mm corner radius.
- 10.2 mm max depth is at the back-mounted JST-PH battery connector; the PCB front carries the 3.5 mm LEDs, the back carries the Pico module, speaker, and connectors.
- Weight: not officially specified. Shopify product data embeds shipping weight 400 g for PIM735 (current page) and 378 g for PIM670 (archived page) — kit weight including legs/cable/packaging, not bare board.

## Mounting provisions (official text + DXF-derived coordinates)

Official text (printables section, both pages): *"Cosmic's 7 mounting holes are M2, 3mm in from the edge, and equally spaced 99mm horizontally and vertically. The leg holes are M2.5 (we've added two sets so you can adjust the angle)."* — https://shop.pimoroni.com/products/space-unicorns

Exact coordinates parsed from the official DXF (`cosmic_unicorn_with_holes.dxf`), front view, origin at bottom-left corner of the board, x right / y up, in mm:

| Feature | Hole dia in DXF | Positions (x, y) |
|---|---|---|
| 7x mounting holes, M2 | 2.10 | (3, 3) · (102, 3) · (201, 3) · (3, 102) · (201, 102) · (3, 201) · (201, 201) — i.e. all four corners, mid-left, mid-bottom, mid-right. **No hole at mid-top or centre.** |
| 4x leg holes, M2.5 (two sets, for the included metal legs at two angles) | 2.55 | bottom pair: (60.0, 4.6) · (144.0, 4.6); side pair: (3.5, 31.0) · (200.5, 31.0) |
| 12x speaker grille holes | 2.00 | 4 cols x 3 rows, 6 mm pitch, x 134–152, y 30–42 (front view; speaker itself is on the back behind these) |
| Hanging slot, top centre | — | 16.0 mm wide (x 94.0–110.0), main slot y 198.4–201.4 (i.e. 2.6–5.6 mm below the top edge), with a small central keyhole bump reaching to 1.5 mm below the top edge |

No threaded inserts or standoffs — all holes are plain through-holes in the PCB (screws + nuts or your own standoffs needed). Sources: DXF https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf?v=1689940239 ; dimensional drawing https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535 (confirms 204.00 / 102.00 / 60.00 / 31.00 / 9.00 / 3.50 / 3.00 / M2 callouts).

## Connectors (all on the BACK of the board; positions from official product photos)

Viewed from the **back** (photo: https://shop.pimoroni.com/cdn/shop/products/cosmic-unicorn-5.jpg for PIM670; https://shop.pimoroni.com/cdn/shop/files/cosmic-unicorn-2_1500x1500_crop_center.jpg for PIM735):

- **USB micro-B** — the port of the Pico (2) W module itself, surface-mounted on the back at the bottom corner (back-view bottom-right = **front-view bottom-LEFT**, the same edge as the A/B/C/D buttons). The port faces sideways through the board's side edge, roughly flush with it (within ~1–2 mm), centred an estimated **~16 mm above the bottom edge** (between the corner mounting hole at y=3 and the side leg hole at y=31; estimated from photos — verify by measurement). A plugged-in micro-B cable boot (~11 mm wide) protrudes beyond the board outline on that edge — the mount must leave clearance there.
- **JST-PH 2-pin battery connector** ("BATTERY 5.5V MAX", polarity silkscreened) — back, near the bottom edge, left-of-centre (back view). This is the 10.2 mm max-depth point.
- **2x Qw/ST (JST-SH 4-pin, Qwiic/STEMMA QT)** — back, bottom centre, side by side, silkscreened "1 QW/ST 2" (I2C on GP4/SDA, GP5/SCL per schematic page 1).
- **Speaker** — 30 mm 1 W speaker on the back, bottom-left (back view), wired to a 2-pin connector; MAX98357 amp on board.
- No battery charging circuitry on board (official note).

## Buttons and switches

9 user buttons + reset (official count). Locations from the dimensional drawing silkscreen and product photos (front view orientation):

- **Left edge** (front view), in a column just below the mid-edge mounting hole (y=102), under a "PROGRAM" silk label: **A, B, C, D** — four side-actuated tactile buttons spaced ~10 mm apart, white plungers protruding slightly from the edge (approx. y 55–90 mm).
- **Right edge** (front view), top to bottom: **Vol + / Vol −** (just below the mid-edge hole), **Zzz (sleep/wake)**, **Lux + / Lux −** (brightness) — five side-actuated buttons.
- **Back**: **RESET** tactile button near the bottom centre, plus the **BOOTSEL** button on the Pico module itself. Bootloader entry: "holding down the BOOTSEL button on the Pico whilst tapping RESET" — https://github.com/pimoroni/unicorn
- Schematic switch roster (page 1): SWA/SWB/SWC/SWD, SW_INCREASE_VOLUME/SW_REDUCE_VOLUME, SW_INCREASE_BRIGHT/SW_REDUCE_BRIGHT, SW_STANDBY, SW_RESET. MicroPython GPIOs: A=0, B=1, C=3, D=6, SLEEP=27, VOL_UP=7, VOL_DOWN=8, BRIGHT_UP=21, BRIGHT_DOWN=26 — https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/cosmic_unicorn/README.md
- Also on board: phototransistor light sensor (PT19-21C/L41/TR8, schematic page 1).

## Kit contents (official)

- "Cosmic Unicorn (with speaker attached)"
- "2 x metal legs" (PIM670 page: "2 x (extra long) metal legs") — screw into the M2.5 leg holes; no other stand/feet, no booklet listed
- "USB A to micro-B cable"

Source: https://shop.pimoroni.com/products/space-unicorns (Kit includes), http://web.archive.org/web/20230603051615/https://shop.pimoroni.com/products/cosmic-unicorn

## Power (official)

- Powered at 5 V via USB micro-B, or battery via JST-PH (5.5 V max input).
- "We measured Galactic and Cosmic Unicorn as consuming just over 1A at maximum brightness, full white." LEDs need ≥3.6 V to look right; blue fades noticeably at ≤2.9 V. — https://shop.pimoroni.com/products/space-unicorns

## Official documentation links

- Product page (current, all Unicorns): https://shop.pimoroni.com/products/space-unicorns (redirect target of /products/cosmic-unicorn)
- Archived original PIM670 page: http://web.archive.org/web/20230603051615/https://shop.pimoroni.com/products/cosmic-unicorn
- Schematic PDF (PIM670, 4 pages, dated 24/02/2023; still the one linked from the current page): https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf?v=1677236038
- Dimensional drawing PNG: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535
- DXF, outline + all holes: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf?v=1689940239
- DXF, outline + corner mounting holes only: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_without_holes.dxf?v=1689940239
- Firmware/examples: https://github.com/pimoroni/unicorn ; MicroPython module docs: https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/cosmic_unicorn/README.md
- Learn guide (linked from page; returned HTTP 500 during research): https://learn.pimoroni.com/article/getting-started-with-galactic-unicorn

## Mount-design implications (derived)

- Bolt to the 7 M2 holes (99 mm grid, 3 mm inset) and/or the 16 mm hanging slot; the mid-top and centre have no holes.
- Keep both side edges clear for the 9 side-actuated buttons, and leave plug clearance on the front-view left edge near the bottom corner for the sideways-exiting micro-B cable.
- The back needs ≥10.2 mm standoff depth (battery connector; Pico module + speaker also on the back).

## Open questions (need physical measurement or user input)

- Which revision does the user own — PIM670 (Pico W) or PIM735 (Pico 2 W)? Mechanically Pimoroni publishes identical dimensions/DXFs for both, but the Pico module footprint position should be sanity-checked on the actual unit if cable routing is tight.
- Exact USB micro-B port position: estimated centre ~16 mm above the bottom edge on the front-view left edge, roughly flush with the edge — needs a physical measurement (affects the cable-exit cutout in the mount).
- Back-side component height map (Pico module + plug, speaker, Qw/ST connectors) — only the overall 10.2 mm max depth at the battery connector is published; measure if the mount has a back plate or standoffs shorter than ~11 mm.
- Bare-board weight — only Shopify shipping weights (378–400 g incl. legs/cable/packaging) found; weigh the unit if mass matters for the cantilevered mount.
- How far the white side-button plungers protrude past the board edges (need finger clearance in any frame that wraps the left/right edges) — not specified anywhere.
- Meaning of the 'PROGRAM' silkscreen label above the A–D button column (bootloader entry is officially BOOTSEL-on-Pico + RESET); mechanically irrelevant but undocumented.
- PCB bare thickness (presumably 1.6 mm) is not stated in the drawing/DXF — measure if the mount clamps the board edge.

## Sources

- [Pico 2 W Unicorn (current product page; redirect target of /products/cosmic-unicorn)](https://shop.pimoroni.com/products/space-unicorns)
- [Cosmic Unicorn (Pico W Aboard) PIM670 — archived product page, 2023-06-03](http://web.archive.org/web/20230603051615/https://shop.pimoroni.com/products/cosmic-unicorn)
- [Cosmic Unicorn schematic PDF (PIM670, 4 pages)](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf?v=1677236038)
- [Cosmic Unicorn dimensional drawing (PNG)](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535)
- [Cosmic Unicorn DXF — outline with all holes](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf?v=1689940239)
- [Cosmic Unicorn DXF — outline with corner mounting holes only](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_without_holes.dxf?v=1689940239)
- [Official back-side product photo (PIM670) — connector/Pico locations](https://shop.pimoroni.com/cdn/shop/products/cosmic-unicorn-5.jpg)
- [Official front product photo (PIM670) — edge button labels](https://shop.pimoroni.com/cdn/shop/products/cosmic-unicorn-3.jpg)
- [Official back-side photo (PIM735, Pico 2 W revision)](https://shop.pimoroni.com/cdn/shop/files/cosmic-unicorn-2_1500x1500_crop_center.jpg)
- [pimoroni/unicorn — firmware repo (bootloader procedure, micro-USB)](https://github.com/pimoroni/unicorn)
- [Cosmic Unicorn MicroPython module README (button GPIOs)](https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/cosmic_unicorn/README.md)
- [Core Electronics PIM670 listing (mirrors Pimoroni spec text)](https://core-electronics.com.au/cosmic-unicorn-pico-w-aboard.html)
