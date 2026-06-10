# Pimoroni Cosmic Unicorn (PIM670 / Pico 2 W variant) — Mechanical Data for Mount Design

**Coordinate convention used throughout:** FRONT view (LED side facing you), origin at the **bottom-left corner of the PCB**, x to the right, y up, all values in mm. The official DXF was verified to be drawn in front view (the speaker grille at x 134–152 mirrors the rear speaker position in product photos).

## 1. Board outline and overall size (official)

| Property | Value | Source |
|---|---|---|
| Board outline | **204.0 x 204.0 mm** (exact, from DXF spline bbox) | [cosmic_unicorn_with_holes.dxf](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf?v=1689940239) |
| Overall thickness | **10.2 mm** max, "max depth at battery connector" | [Pimoroni product page](https://shop.pimoroni.com/products/cosmic-unicorn) |
| LED matrix | 32x32 = 1024 LEDs, **6 mm pitch**, 3.5 mm LEDs | [Pimoroni product page](https://shop.pimoroni.com/products/cosmic-unicorn) |
| LED active area | 186 x 186 mm; first/last LED centres at 9 mm and 195 mm (inferred: 31 x 6 mm + margins) | derived from 6 mm pitch + 204 mm board |
| Hanging slot (top edge) | Rounded slot **x 94.0–110.0, y 198.35–202.54** (16.0 mm wide x 4.19 mm, centred at x=102, top of slot 1.46 mm below top edge) | parsed from DXF spline |
| PCB thickness | not published; standard 1.6 mm assumed | inferred |
| Weight | **not published anywhere found** | — |

Pimoroni's official mechanical files (all fetched and verified):
- Dimensional drawing PNG: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535
- DXF with all holes: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf?v=1689940239
- DXF outline only: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_without_holes.dxf?v=1689940239
- Schematic PDF (4 pages): https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf?v=1677236038

## 2. Mounting holes (official, exact coordinates parsed from the DXF)

Official text: "The 7 mounting holes are M2, 3mm in from the edge, and equally spaced 99mm horizontally and vertically. The leg holes are M2.5 (we've added two sets so you can adjust the angle)." ([product page](https://shop.pimoroni.com/products/cosmic-unicorn))

**7x M2 mounting holes — drill diameter 2.10 mm in the DXF (M2 clearance). Plain PCB through-holes, NOT threaded** (the official [Unicorn Diffuser Kit](https://shop.pimoroni.com/en-us/products/unicorn-diffuser-kit) secures through them with M2x12 screws + M2 nuts + M2x4 standoffs, proving they are plain holes):

| Hole | x (mm) | y (mm) |
|---|---|---|
| bottom-left | 3.0 | 3.0 |
| bottom-centre | 102.0 | 3.0 |
| bottom-right | 201.0 | 3.0 |
| mid-left | 3.0 | 102.0 |
| mid-right | 201.0 | 102.0 |
| top-left | 3.0 | 201.0 |
| top-right | 201.0 | 201.0 |

There is **no top-centre hole** — the hanging slot (sec. 1) occupies that position. Hole pattern pitch: 99.0 mm; corner-to-corner 198.0 mm both axes.

**4x M2.5 leg holes — drill diameter 2.55 mm** (two sets for the bundled metal legs at two angles):

| Hole | x (mm) | y (mm) | Set |
|---|---|---|---|
| bottom pair | 60.0 / 144.0 | 4.6 | one angle |
| side pair | 3.5 (left) / 200.5 (right) | 31.0 | other angle |

**Speaker grille** (front face): 4x3 grid of 2.0 mm holes at 6 mm pitch, x 134.0–152.0, y 30.0–42.0, centre (143, 36) — lower-right of the front face. All from the parsed DXF.

## 3. Back side layout (measured from official product photo, +/-2 mm; front-view coordinates)

Source photo: [The Pi Hut product gallery, rear view](https://thepihut.com/cdn/shop/files/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels-pimoroni-pim670-40680799535299_1000x.webp), scaled against the known 204 mm board span.

**Everything tall lives in the bottom ~45 mm strip.** Above y ~ 45 the back carries only LED driver ICs (FM6047, SSOP, < ~2 mm tall) and silkscreen artwork — flat enough for a mount plate on short standoffs.

| Component | Front-view position (mm) | Notes |
|---|---|---|
| Raspberry Pi Pico W (soldered SMD module) | x 0–53, y 4–27 | Long axis horizontal, bottom-left corner region |
| **micro-USB port** (Pico's own; power + programming) | left edge, centre y ~ 15 | Face approx flush with board edge; **plug enters from the LEFT edge** (front view). Reserve >= 35 mm clearance left of the board for plug body + cable bend. BOOTSEL button on Pico face beside it. Official: "Powered and programmable by USB micro-B" ([product page](https://shop.pimoroni.com/products/cosmic-unicorn)) — there is **no USB-C** on either the Pico W or Pico 2 W variant ([current page](https://shop.pimoroni.com/en-us/products/cosmic-unicorn)) |
| Reset button (rear-face tactile, "RESET" silk) | (75, 6) | Pressed from behind |
| 2x Qw/ST (JST-SH 4-pin, side entry) | x 89–106.5, y ~ 19–25 | Cable openings face the bottom edge |
| JST-PH battery connector ("BATTERY 5.5V MAX") | (~121, ~18) | **Tallest component — defines the 10.2 mm max depth** |
| 30 mm speaker (1 W, wired, on rear) | centre (144, 36), dia ~30 | Directly behind the front grille; don't clamp it |
| Speaker JST connector + wires | (~164.5, ~21) | Red twisted pair runs across this zone |
| **No DIP/mute switch exists** | — | Schematic p.1/p.4: MUTE is a GPIO net into the MAX98357 amp's SD_MODE — software only ([schematic](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf?v=1677236038)) |

Rear clearance budget (inferred): 10.2 total − ~1.6 PCB − ~2.6 front LEDs => **tallest rear component ~ 6 mm** (battery connector); speaker ~5 mm, Pico+USB ~4 mm. A flat mount plate over the bottom strip needs >= 7 mm standoff or local pockets; over the top half >= 3 mm suffices. **These heights are estimates — verify with calipers.**

## 4. Edge features (measured from the official dimensional drawing, pixel-scaled, +/-1 mm)

Buttons are side-actuated tactile switches mounted on the rear face at the board edge, protruding ~1–2 mm beyond the edge. 9 user buttons + reset total (matches schematic switch list: SWA–SWD, vol +/-, lux +/-, standby, reset).

**Left edge (front view), y from bottom:** micro-USB ~15 · leg hole 31.0 · D 44.6 · C 56.8 · B 68.8 · A 80.8 (12.0 mm pitch) · "PROGRAM" silkscreen above A (~87–96) · M2 hole 102.

**Right edge (front view), y from bottom:** Lux− 9.1 · Lux+ 21.2 · leg hole 31.0 · Zzz/sleep ~36–40 · Vol− 57.4 · Vol+ 69.3 · M2 hole 102.

**Top edge:** clean except the 16 mm hanging slot at centre. **Bottom edge:** no protrusions; reset button and Qw/ST openings face it from the rear face.

Source: pixel measurement of [official dimensional drawing](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535) (scale validated against DXF hole positions to ~0.5 mm) cross-checked against the [rear product photo](https://thepihut.com/cdn/shop/files/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels-pimoroni-pim670-40680799535299_1000x.webp).

## 5. Mount-design implications

- Grip via the 7 plain M2 holes with screws + nuts or printed bosses; the official diffuser kit precedent is M2x12 screws with M2 nuts ([diffuser kit](https://shop.pimoroni.com/en-us/products/unicorn-diffuser-kit)). For a rear mount plate, M2 screws from the front into heat-set inserts or nuts captured in the plate work; a 1.9 mm printed pin locates in a hole.
- Strongest symmetric pattern for a side-of-upright mount: the two mid-edge holes (3,102) and (201,102) plus top/bottom corners on one side; any 3+ of the 7 at 99 mm pitch.
- Keep the left edge (front view) clear for the micro-USB plug, and don't enclose the right-edge buttons if brightness/volume access is wanted at the rig.
- The Pico 2 W refresh ("Cosmic 32x32") is mechanically identical: same 204 x 204 x 10.2 mm, same hole spec, still micro-B ([current product page](https://shop.pimoroni.com/en-us/products/cosmic-unicorn)).
- Community example: [Pinorami Cosmic Unicorn Frame on Printables](https://www.printables.com/model/800712-pinorami-cosmic-unicorn-frame) (OnShape source linked) — no extra measurements stated beyond the official ones.

## Open questions (need physical measurement or user input)

- Board weight is not published anywhere found - weigh the actual unit (matters little structurally; expect ~250-350 g).
- Exact rear component heights (battery JST ~6 mm derived, speaker ~5 mm, Pico+USB ~4 mm, edge buttons, driver ICs <2 mm) are estimates from standard part sizes and the 10.2 mm overall figure - verify with calipers before finalising standoff height (recommend designing for >= 7 mm rear clearance over the bottom 45 mm strip, or pocketing the plate).
- PCB thickness assumed 1.6 mm (standard) - not published; measure at an edge.
- Zzz/sleep button position on the right edge is the least certain edge measurement (~36-40 mm from bottom, +/-2 mm) - verify on the physical board if the mount comes near it.
- How far the side-actuated edge buttons protrude beyond the board edge (~1-2 mm estimated) - measure if the mount wraps the edges.
- Whether the micro-USB face is exactly flush or ~1 mm inset from the left board edge (photo perspective limits precision) - affects only tight-fitting USB cutouts.
- DXF hole drill sizes (2.10 / 2.55 mm) are the outline-file circle diameters; actual drilled PCB holes may differ by ~0.05 mm - non-critical for M2/M2.5 clearance.

## Sources

- [Pimoroni Cosmic Unicorn product page (PIM670 / Pico 2 W)](https://shop.pimoroni.com/products/cosmic-unicorn)
- [Pimoroni Space Unicorns combined page](https://shop.pimoroni.com/products/space-unicorns?variant=40842626596947)
- [Official dimensional drawing (PNG)](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png?v=1689940535)
- [Official DXF outline with all holes](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf?v=1689940239)
- [Official DXF outline without holes](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_without_holes.dxf?v=1689940239)
- [Official schematic PDF (PIM670, 4 pages)](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf?v=1677236038)
- [Unicorn Diffuser Kit (confirms M2 screw+nut mounting through plain holes)](https://shop.pimoroni.com/en-us/products/unicorn-diffuser-kit)
- [The Pi Hut product page (rear-view photo used for back-side layout)](https://thepihut.com/collections/pimoroni/products/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels)
- [Rear product photo (measured)](https://thepihut.com/cdn/shop/files/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels-pimoroni-pim670-40680799535299_1000x.webp)
- [Core Electronics PIM670 spec mirror](https://core-electronics.com.au/cosmic-unicorn-pico-w-aboard.html)
- [pimoroni/unicorn firmware repository](https://github.com/pimoroni/unicorn)
- [Pinorami Cosmic Unicorn Frame (community mount example)](https://www.printables.com/model/800712-pinorami-cosmic-unicorn-frame)
