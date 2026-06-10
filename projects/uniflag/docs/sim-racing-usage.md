# Cosmic Unicorn — usage & mounting prior art (research for GT Omega 8040 rig mount)

## 1. Sim-racing "virtual flag" usage and how data reaches the board

**Negative finding:** repeated targeted searches (GitHub, Reddit, YouTube, Hackster/Hackaday, SimHub forum) found **no published project pairing a Cosmic/Galactic/Stellar Unicorn with SimHub or iRacing**. This mount + firmware combo would be novel; there is no drop-in profile to copy.

**What the sim community actually uses for flag matrices:** small 8x8 WS2812 matrices on an Arduino, driven by SimHub's built-in "Arduino RGB Matrix" feature ("use 8x8 RGB Matrix to show gears, flags, spotter", one matrix per Arduino; since SimHub 7.4.9 up to 4 matrix contents) — [SimHub wiki: Arduino RGB Matrix](https://github.com/SHWotever/SimHub/wiki/Arduino-RGB-Matrix). Commercial examples built on this stack: [RaceFlag (Racebox)](https://raceboxsimracing.com/products/race-flag-led-display), [LUMIRANK](https://dasimsimma.com/products/lumirank-race-flag-display-telemetry-data-for-most-racing-titles-simhub), [EPLAB Simflag](https://www.eplabsimracing.com/simflag), [iFlag](https://www.symprojects.com/iflag-for-iracing).

**Why SimHub can't drive the Cosmic Unicorn natively:** the Unicorn's LEDs are not WS2812 — they are driven by FM6047 constant-current drivers via the Pico W's PIO ([The Pi Hut product page](https://thepihut.com/products/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels)). It is also not a HUB75 panel. So SimHub's stock LED firmware is irrelevant; custom firmware on the Pico W must receive flag state and render it. (SimHub forum discusses RP2040/Pico support for its devices, but that targets SimHub's own sketches, not this board: [SimHub forum thread](https://www.simhubdash.com/community-2/simhub/added-support-for-rp-pico-and-rp2040/).)

**Realistic data paths (determines cable routing for the mount):**

| Path | Cable to board? | Evidence |
|---|---|---|
| SimHub **Custom serial devices**: ASCII messages built with NCalc/JavaScript, sent over a USB COM port at configurable baud; "changes only" option; free version capped at 10 Hz (ample for flags). Custom MicroPython/C firmware on the Pico parses and renders. | Yes — permanent USB micro-B data+power cable | [SimHub wiki: Custom serial devices](https://github.com/SHWotever/SimHub/wiki/Custom-serial-devices) |
| **WiFi (Pico W)**: custom receiver (UDP/MQTT/HTTP) on the board; Pimoroni's MicroPython firmware ships an `EzWiFi` module. SimHub side needs a small custom plugin or relay script. The [SimHub-WLED plugin](https://github.com/hxlcyxn/SimHub-WLED) shows the network-plugin pattern, but WLED itself does not run on this board and the plugin targets strips, not matrices. | No data cable, but a power cable is still required | [pimoroni/unicorn releases (EzWiFi)](https://github.com/pimoroni/unicorn/releases) |
| **USB-serial framebuffer streaming**: Gadgetoid's [gu-multiverse](https://github.com/Gadgetoid/gu-multiverse) turns a Galactic Unicorn into a USB-serial framebuffer; host Python streams full RGBx numpy frames, supports tiling multiple boards. Documented for Galactic (53x11) only, but proves full-frame USB-CDC streaming on this hardware family — a SimHub/Python flag renderer on the PC could stream rendered frames. | Yes — permanent USB cable | repo README |

**Design consequence:** in every practical PC-fed configuration a cable must be routed to the board permanently (USB for data+power, or USB/5V for power even when WiFi carries the data). The mount should include cable routing/strain relief regardless.

## 2. Power

- "Powered and programmable by **USB micro-B**" — *not USB-C* — and "We measured Galactic and Cosmic Unicorn as consuming **just over 1A at maximum brightness, full white**" (~5 W) — [Pimoroni shop](https://shop.pimoroni.com/en-us/products/space-unicorns), [Core Electronics PIM670](https://core-electronics.com.au/cosmic-unicorn-pico-w-aboard.html). A single cable from the PC (or any 5V/2A adapter) covers it; flag displays (mostly dark or single saturated colour, partial brightness) draw far less than the full-white worst case.
- **JST-PH battery connector (5.5 V max)**: no onboard charging ("so you can use either alkaline or LiPo batteries safely"); Pimoroni recommends "a chunky LiPo" + separate LiPo Amigo charger; LEDs want ≥3.6 V or blues fade (very noticeable below 2.9 V) — [Pi Hut page](https://thepihut.com/products/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels). **Not realistic for a fixed rig display** — it exists for portable/untethered use; on a rig it just adds a charging chore.
- The board ships with a USB A to micro-B cable ([Core Electronics](https://core-electronics.com.au/cosmic-unicorn-pico-w-aboard.html)).

## 3. Existing mounts (prior art)

No published mount targets aluminium extrusion, VESA, monitor arms, or sim rigs — for the Cosmic Unicorn or its siblings. What exists:

| Design | Board | Attachment approach | Source |
|---|---|---|---|
| Skadis pegboard mount | Galactic | **4x M2x6mm screws into the board's M2 mounting holes**; bracket hooks onto pegboard; designer left "a gap to allow access to the buttons"; prints lying on its side, no supports | [Printables 317905](https://www.printables.com/model/317905-pimoroni-galactic-unicorn-skadis-mount) |
| Screen mount with pivot stand (officially linked from Pimoroni's shop page) | Galactic | 4x tiny M2 self-tapping screws (4–6 mm) fix board to case from the reverse; pivot via M3x25 + heat-set insert | [Printables 486269](https://www.printables.com/model/486269-galactic-unicorn-pico-w-aboard-screen-mount-pivot-) |
| Pinorami Cosmic Unicorn Frame | Cosmic | Frame; details only in linked Onshape doc (page description is sparse) | [Printables 800712](https://www.printables.com/model/800712-pinorami-cosmic-unicorn-frame) |
| Cosmic Unicorn Grid | Cosmic | 4-part LED grid that sits **between board and a diffuser layer**, "useful if you want to frame it" | [Printables 704138](https://www.printables.com/model/704138-cosmic-unicorn-grid) |
| Stellar Unicorn Fireplace Case | Stellar | Printed case held together by the diffuser-kit bolts/nuts | [Thingiverse 6894780](https://www.thingiverse.com/thing:6894780) |
| Galactic diffuse cover grid | Galactic | Diffuser accessory | [Thingiverse 5901867](https://www.thingiverse.com/thing:5901867) |

**Pattern:** every design fastens through the board's M2 mounting holes from the back (or sandwiches the board with diffuser-kit hardware). Nobody grips the board edges — the user buttons live there (see §5). Pimoroni explicitly invites this: the board "has a selection of mounting holes if you'd prefer to do something else" and publishes DXF outlines for case/diffuser design ([shop page](https://shop.pimoroni.com/en-us/products/space-unicorns)).

**Official CAD/drawings for the Cosmic** (linked from the shop page — directly usable for the OpenSCAD model):
- Dimensional drawing (front view, PNG): https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png
- DXF outline with all holes: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf (and `cosmic_unicorn_without_holes.dxf`)
- Schematic PDF: https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf

From the dimensional drawing: board 204.00 x 204.00 mm; M2 holes with centres 3.00 mm from the edges; adjacent-hole spacing 99 mm — **7 holes: 4 corners + mid-left + mid-right + mid-bottom; there is no mid-top hole** (top centre has a small slot cutout instead). LED pitch 6.00 mm, LED aperture 3.50 mm (32 x 6 mm = 192 mm active area inside the 204 mm board).

## 4. Official accessories and how they attach

- **2x metal legs included** ("extra long" on the Cosmic), screwing into **M2.5 leg holes; two sets of holes so you can adjust the angle** — [Core Electronics](https://core-electronics.com.au/cosmic-unicorn-pico-w-aboard.html). Desk-stand only; not useful for the rig.
- **Unicorn Diffuser Kit** (Cosmic: 204 x 204 mm laser-cut acrylic, +£3.75): contains **4x M2x12 screws, 4x M2x4mm standoffs, 4x M2 nuts**; screws pass front-to-back through diffuser → standoff → corner mounting holes → nut on the rear; standoffs give "a couple of mm gap between the acrylic and the LEDs" — [Unicorn Diffuser Kit](https://shop.pimoroni.com/en-us/products/unicorn-diffuser-kit). **Mount-design consequence:** if a diffuser is fitted, the 4 corner holes are occupied by M2x12 through-screws — the mount can either share those screws (longer M2 + the mount as the "nut plate") or use the three free mid-edge holes.
- **Battery add-ons** sold alongside: LiPo packs (2200–8800 mAh), LiPo Amigo charger, JST-PH jumper cable — [shop page](https://shop.pimoroni.com/en-us/products/space-unicorns).
- No official wall/arm/extrusion mount exists.

## 5. Practical gotchas for the mount design

- **Buttons sit at the board edges.** The dimensional drawing's front view shows labels along the **left edge: PROGRAM (reset/boot), A, B, C, D** and along the **right edge: VOL +/-, Zzz (sleep), LUX +/- (brightness)** ([dimensional drawing](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png)). 9 user buttons + reset total ([Pi Hut](https://thepihut.com/products/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels)). An edge-grip or picture-frame mount blocks them; the Skadis-mount designer explicitly left a button-access gap. Note the brightness/sleep/volume buttons are software-defined, so they remain useful even with custom flag firmware ([cosmic_unicorn module README](https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/cosmic_unicorn/README.md)).
- **Rear clearance:** total depth is 10.2 mm "max depth at battery connector" ([Core Electronics](https://core-electronics.com.au/cosmic-unicorn-pico-w-aboard.html)); the Pico W, a pre-attached 30 mm speaker, the JST-PH and 2x Qw/ST connectors all live on the rear — a flat backplate needs standoffs, and shouldn't fully seal the speaker if audio alerts are wanted.
- **Glare/brightness:** Pimoroni's own pitch for the diffuser kit is "shield your eyes from your Space Unicorn's dazzling rays" ([diffuser kit](https://shop.pimoroni.com/en-us/products/unicorn-diffuser-kit)) — at cockpit distance a diffuser (official acrylic or printed grid + diffuser, [Printables 704138](https://www.printables.com/model/704138-cosmic-unicorn-grid)) is advisable for a flag display in peripheral vision.
- **Light sensor on the front** (phototransistor, [Pi Hut](https://thepihut.com/products/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels)) — don't occlude it if auto-dimming is wanted.
- **Heat:** no community reports of heat problems were found (searches of forums/Reddit/reviews); worst case is ~5 W spread over a 204 mm board, and flag content is far below full-white. Reviews instead emphasise the ~300 fps flicker-free refresh ([Raspberry Pi magazine review](https://magazine.raspberrypi.com/articles/cosmic-unicorn-pico-w-aboard-review)). Treat heat as a non-issue for PETG/PLA mount material at the standoff contact points.
- **Board flex:** no reports found; with 7 mounting points available, a 3- or 4-point mount on a 204 mm PCB has not drawn complaints in any reviewed design.
- **Cosmetic batch variation** ("squircle alert": LED aperture shape varies between batches; specs identical) — irrelevant mechanically ([Pi Hut](https://thepihut.com/products/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels)).
- **Product status:** the original Pico W Cosmic Unicorn (PIM670) is discontinued at some retailers, superseded by the **Pico 2 W Unicorn — Cosmic (PIM735)**; the published dimensions, hole pattern, micro-B USB and current draw are identical across both generations ([Pi Hut discontinued listing](https://thepihut.com/products/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels), [Pimoroni shop](https://shop.pimoroni.com/en-us/products/space-unicorns)) — but verify which generation is in hand before trusting rear-component positions.

## Open questions (need physical measurement or user input)

- Exact position and orientation of the USB micro-B port on the rear (the Pico W module sits on the back; the dimensional drawing is front-view only) — physically verify which edge the cable exits and how much clearance the plug overmold needs behind/above the board.
- Exact location of the JST-PH battery connector (it defines the 10.2 mm max depth) and of the 2x Qw/ST connectors, for backplate keep-out zones.
- Rear component height map (Pico W, 30 mm speaker, right-angle buttons, connectors) needed to size standoffs for a flat backplate — measure or extract from the schematic/board photos.
- Whether the three mid-edge M2 holes (mid-left, mid-right, mid-bottom) are clear of rear components for through-bolts and nut/screw-head seating.
- Purpose and exact size of the slot cutout at top centre of the PCB (visible in the dimensional drawing; possibly a hanging slot) — measure if it is to be used for cable routing or hanging.
- Which board generation the user owns (Pico W PIM670 vs Pico 2 W PIM735) — published mechanical specs match, but rear layout should be verified on the actual unit.
- Whether a diffuser will be fitted: the official kit occupies the 4 corner holes with front-to-back M2x12 screws, which changes the mount's fastening plan (share longer M2 screws vs use mid-edge holes only).
- Attachment details of the Pinorami Cosmic Unicorn Frame (documented only in its Onshape document, not inspected here).

## Sources

- [Pimoroni shop — Pico 2 W Unicorn (Space Unicorns: Stellar/Galactic/Cosmic specs, mounting holes, diffuser kit, DXF/drawing links)](https://shop.pimoroni.com/en-us/products/space-unicorns)
- [Core Electronics — Cosmic Unicorn (Pico W Aboard) PIM670 full specs](https://core-electronics.com.au/cosmic-unicorn-pico-w-aboard.html)
- [The Pi Hut — Pico W Smart LED Matrix Cosmic Unicorn (FM6047 drivers, battery notes, kit contents)](https://thepihut.com/collections/pimoroni/products/pico-w-smart-led-matrix-cosmic-unicorn-32x32-1024-pixels)
- [Official Cosmic Unicorn dimensional drawing (PNG)](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_dimensional_drawing.png)
- [Official Cosmic Unicorn board outline DXF (with holes)](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_with_holes.dxf)
- [Official Cosmic Unicorn schematic (PDF)](https://cdn.shopify.com/s/files/1/0174/1800/files/cosmic_unicorn_schematic.pdf)
- [Pimoroni — Unicorn Diffuser Kit (contents and fitting)](https://shop.pimoroni.com/en-us/products/unicorn-diffuser-kit)
- [SimHub wiki — Arduino RGB Matrix (8x8 matrix flag/gear support)](https://github.com/SHWotever/SimHub/wiki/Arduino-RGB-Matrix)
- [SimHub wiki — Custom serial devices](https://github.com/SHWotever/SimHub/wiki/Custom-serial-devices)
- [Gadgetoid/gu-multiverse — USB serial framebuffer for Galactic Unicorn](https://github.com/Gadgetoid/gu-multiverse)
- [pimoroni/unicorn — official MicroPython firmware and examples (EzWiFi)](https://github.com/pimoroni/unicorn)
- [pimoroni/unicorn releases](https://github.com/pimoroni/unicorn/releases)
- [pimoroni-pico cosmic_unicorn MicroPython module README (buttons are software-defined)](https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/cosmic_unicorn/README.md)
- [Printables — Pimoroni Galactic Unicorn Skadis Mount](https://www.printables.com/model/317905-pimoroni-galactic-unicorn-skadis-mount)
- [Printables — Galactic Unicorn Screen Mount with Pivot Stand (linked from Pimoroni shop)](https://www.printables.com/model/486269-galactic-unicorn-pico-w-aboard-screen-mount-pivot-)
- [Printables — Pinorami Cosmic Unicorn Frame](https://www.printables.com/model/800712-pinorami-cosmic-unicorn-frame)
- [Printables — Cosmic Unicorn Grid (diffuser grid)](https://www.printables.com/model/704138-cosmic-unicorn-grid)
- [Thingiverse — Pimoroni Stellar Unicorn Fireplace Case](https://www.thingiverse.com/thing:6894780)
- [Thingiverse — Galactic Unicorn Diffuse Cover Grid](https://www.thingiverse.com/thing:5901867)
- [Racebox RaceFlag Display (commercial 8x8 SimHub flag display prior art)](https://raceboxsimracing.com/products/race-flag-led-display)
- [LUMIRANK Race Flag Display (SimHub)](https://dasimsimma.com/products/lumirank-race-flag-display-telemetry-data-for-most-racing-titles-simhub)
- [EPLAB Simflag](https://www.eplabsimracing.com/simflag)
- [iFlag for iRacing (SYM Projects)](https://www.symprojects.com/iflag-for-iracing)
- [hxlcyxn/SimHub-WLED — SimHub to WLED network plugin](https://github.com/hxlcyxn/SimHub-WLED)
- [SimHub forum — Added support for RP Pico / RP2040 (discussion)](https://www.simhubdash.com/community-2/simhub/added-support-for-rp-pico-and-rp2040/)
- [Raspberry Pi Official Magazine — Cosmic Unicorn review (300 fps, legs, buttons)](https://magazine.raspberrypi.com/articles/cosmic-unicorn-pico-w-aboard-review)

## This rig's actual firmware: uniflag

The owner runs custom firmware — [nickolaj-jepsen/uniflag](https://github.com/nickolaj-jepsen/uniflag)
(Rust + embassy-rs on the RP2040, GPL-3.0):

- Flag data arrives from **SimHub over USB CDC** (repo ships a SimHub
  "Custom serial device" profile and a host-side simulator, `uniflag-sim`).
- A shared wire-protocol library (`proto/`) sits between firmware and host.
- Consequence for the mount: the USB cable is a **permanent data+power link**
  (not just power), so the strain-relief requirement is real — a flaky plug
  drops the flag feed mid-race.
- Display rotation is firmware-controlled and the owner owns the firmware, so
  panel orientation is free: the mount may rotate the board to put the USB
  port on whichever edge suits the cable path.
