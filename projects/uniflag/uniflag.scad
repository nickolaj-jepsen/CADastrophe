// =====================================================================
//  uniflag — Pimoroni Cosmic Unicorn mount for the GT Omega PRIME Lite
//  (8040 rig). Three printed parts in one multi-body project:
//
//   * bracket — bolts flat to the outboard 80 mm face of the right
//     wheel-deck upright (4x M8x14 + T-nuts, two slot columns 40 mm
//     apart) and carries a wall parallel to the panel plane, yawed
//     `yaw` deg toward the seat. The frame hangs on that wall.
//   * frame   — rear picture-frame ring the board drops into. Touches
//     the board only at segmented rear lips that dodge the Pico, the
//     bottom connector cluster and the edge-button switch bodies, so
//     the whole back (incl. the speaker) stays open.
//   * ring    — front clamp ring: a 5 mm lip over the board's dark
//     border on three edges (the right edge stays fully open — the
//     light sensor lives somewhere along it) plus a perimeter skirt
//     that locates the board in-plane. M4x14 + captive nuts clamp
//     ring -> frame; the board floats in a fixed-height channel and
//     never sees bolt preload.
//
//  Fasteners (owner's bin only): M8x14, M5x30, M4x14 + M4/M5 hex nuts.
//  M5x30 heads sit on the wall's monitor side; their nuts are captive
//  in frame pockets whose bearing floor is ~10 mm thick (the full bolt
//  preload lands there — an M5x14 would leave a 1.5 mm floor, refused).
//
//  Board geometry is DXF-exact (see docs/ + SPEC.md). Board-edge
//  coordinates below are mm from the board's front-view bottom-left
//  corner; frame/ring model space is centred on the board, +z = from
//  the board's back toward the rig (each part lies print-side down).
//
//  Print: all three parts flat as laid out (part="plate"), PETG/ASA,
//  >=4 walls. The bracket's wall leans `yaw` deg — self-supporting.
// =====================================================================
include <BOSL2/std.scad>
$fa = 2; $fs = 0.5;

part = "plate"; // [plate, bracket, frame, ring, assembly]

/* [Board — Pimoroni Cosmic Unicorn, DXF-exact + owner's calipers 2026-06-10] */
bd        = 204;    // square board edge
bd_r      = 3;      // board corner radius
pcb_t     = 2.0;    // border stack thickness (measured ~2.0 — NOT the bare 1.6)

/* [Fit] */
bd_clr     = 0.4;   // in-plane clearance around the board outline
chan_slack = 0.35;  // board float in the grip channel (zero = rattle-free but risks bowing)

/* [Front ring] */
lip       = 5;      // front lip on top/bottom/left (right edge open: light sensor)
ring_t    = 3;      // ring plate thickness
foot_ch   = 0.6;    // elephant-foot chamfer on bed-face perimeters

/* [Rear frame] */
rear_lip  = 4;      // rear lip depth onto the board's back border
band_w    = 4;      // structural band thickness outside the board
fr_d      = 12;     // frame band depth (front face to band back)
m5_col_d  = 24;     // M5 boss depth = the frame/wall contact plane offset

/* [Edge windows — board-edge mm, y from board bottom / x from board left] */
usb_cy    = 23;         // port centreline above the bottom edge (measured)
usb_y     = [17, 29];   usb_nd = 9;   // USB notch into the band (depth from front)
// Buttons are rear-mounted with flush plungers (bodies ~5 in from the edge,
// nothing protrudes) — the windows are for fingertip reach-in, hence deep.
btnl_y    = [43, 84];   btn_nd = 8;   // A/B/C/D finger window
btnr_y    = [5, 73];                  // Vol/Zzz/Lux finger window
keepl_y   = [0, 92];    // rear-lip keep-outs: Pico + left switch bodies
keepr_y   = [0, 78];    // right switch bodies
keepb_x   = [0, 112];   // Pico + reset + Qw/ST cluster

/* [M4 ring sandwich] */
m4_off    = 2.8;    // bolt line outside the board edge
m4_hole   = 4.5;
m4_boss   = 11;     // ear boss diameter
m4_len    = 14;
m4_nut_w  = 7.0;    // across flats
m4_nut_t  = 3.2;
nut_clr   = 0.35;   // pocket clearance per side (flats and thickness)

/* [M5 bracket joint] */
m5_off    = 5.5;    // ear bolt line outside the board's left edge
m5_hole   = 5.5;
m5_len    = 30;
m5_boss   = 12;
m5_nut_w  = 8.0;
m5_nut_t  = 4.0;
m5_ear_y  = [36, 110, 186];  // board-y of the ear bolts (#1 splits the USB/button windows)
rib_y     = [120, 140];      // back rib band (board-y) — rear face is clean here
rib_bolt_x = [25, 45];       // board-x of the two rib bolts
rib_z0    = 8;               // rib front face: clearance over rear components

/* [Bracket — rail plate + leaning wall] */
pl_w      = 80;     // rail plate width  = the 80 mm profile face
pl_h      = 210;    // rail plate height along the slots
pl_t      = 8;
m8_hole   = 8.5;
m8_x      = 20;     // slot columns at +/-20 from the face centre (verified)
m8_y      = [25, 185];
wall_t    = 8;
wall_x0   = 32;     // wall foot inner face (washer keep-out asserted)
yaw       = 15;     // panel yaw toward the seat
gap       = 42;     // rail face -> board left edge (measured 30 boot + bend room)
board_y0  = 4;      // board bottom edge above the plate bottom
arm_y     = [119, 149];  // wall arm band carrying the rib bolts
wall_marg = 6;      // wall extent beyond the outermost bolt line
zt_slot   = [4, 8]; // zip-tie slot w x h (strain relief, through the wall)

/* [Hardware facts — only used by asserts] */
m8_washer = 17;
m8_head_d = 13;
m4_head_d = 7;
m5_head_d = 8.7;
plug_len  = 30;     // micro-B boot past the board edge (measured, owner's cable)
led_inset = 7.25;   // first LED package edge from the board edge (DXF)

// --- derived (mm) ---
chan_t   = pcb_t + chan_slack;            // grip channel height (skirt depth)
ring_stk = ring_t + chan_t;               // ring front face -> frame front face
half     = bd / 2;
out_half = half + bd_clr + band_w;        // frame/ring outer half-size (sans ears)
m4_c     = half + m4_off;                 // M4 bolt lines from board centre
m5_x     = -(half + m5_off);              // M5 ear bolt line (centred x)
function bx(v) = v - half;                // board-edge mm -> centred model mm
function by(v) = v - half;
m4_pts   = [for (sx = [-1, 1], sy = [-1, 1]) [sx * m4_c, sy * m4_c],
            [0, m4_c], [0, -m4_c]];
m5_ear_pts = [for (y = m5_ear_y) [m5_x, by(y)]];
rib_pts    = [for (x = rib_bolt_x) [bx(x), by((rib_y[0] + rib_y[1]) / 2)]];

// M4: head on the ring front; nut dropped into a back-opening pocket and
// pulled against its floor (toward the head) — floor depth is the load path.
m4_tip   = m4_len - ring_stk;             // thread reach into the frame
m4_nut_z = m4_tip - (m4_nut_t + nut_clr); // pocket floor (nut bears here)

// M5: head + washer on the wall's monitor side, shank through wall_t and the
// m5_col_d boss; nut captive mid-boss, bearing toward the wall (thick floor).
m5_tip   = wall_t + m5_col_d - m5_len;    // z of the bolt tip in frame coords
m5_nut_z = [9, 9 + m5_nut_t + 2 * nut_clr]; // pocket void span (z)

lap = 1;     // cut over-extension; eps for unions
eps = 0.02;

// wall geometry: xi = distance up the wall from its foot pivot (plate top,
// x = wall mid-plane). The frame's back plane sits wall_t/2 + m5_col_d off
// the mid-plane; the board's left edge is m5_off + frame-x past the ear line.
wall_n   = [cos(yaw), 0, -sin(yaw)];           // wall normal, toward the driver
xi_bl    = (gap - pl_t + (wall_t / 2 + m5_col_d) * sin(yaw)) / cos(yaw);
xi_m5    = xi_bl - m5_off;                     // ear bolt line up the wall
xi_rib   = [for (x = rib_bolt_x) xi_bl + x];   // rib bolt lines up the wall
xi_strip = xi_m5 + wall_marg;                  // full-height strip extent
xi_top   = xi_rib[1] + wall_marg;              // arm extent
pivot    = [wall_x0 + wall_t / 2, 0, pl_t];

function ear_gy(i) = board_y0 + m5_ear_y[i];   // bolt heights in bracket coords
rib_gy   = board_y0 + (rib_y[0] + rib_y[1]) / 2;

echo(str("channel: ", chan_t, "  ring stack: ", ring_stk));
echo(str("M4 tip ", m4_tip, " into frame, nut floor at z=", m4_nut_z));
echo(str("M5 tip at frame z=", m5_tip, " (board rear at z=0)"));
echo(str("wall xi: board edge ", xi_bl, ", M5 ears ", xi_m5, ", rib ", xi_rib));
echo(str("frame/ring envelope: ", 2 * (m4_c + m4_boss / 2), " sq (+M5 ears to x ",
         -(half + m5_off + m5_boss / 2), ")"));

// Clearances and reach — fail loudly instead of printing scrap.
assert(lip <= led_inset - 0.5, "front lip would shade the first LED row");
assert(m4_c - m4_hole / 2 - half >= 0.4, "M4 bolt line cuts the board outline");
assert(norm([m4_c - (half - bd_r), m4_c - (half - bd_r)]) - bd_r - m4_hole / 2 >= 1,
       "M4 corner bolt too close to the board corner arc");
assert(m4_nut_z >= 3.5, "M4 nut floor too thin to carry the clamp preload");
assert(m4_tip <= fr_d - 0.5, "M4 pokes out of the frame band");
assert(m4_tip - (m4_nut_z + m4_nut_t) >= 0.3, "M4 too short to fill its nut");
assert(m5_tip >= 1.5, "M5 tip too close to the board's back face");
assert(m5_nut_z[1] + m5_nut_t <= m5_col_d - 4, "M5 nut floor thinner than 4");
assert(wall_t + m5_col_d - m5_nut_z[1] <= m5_len - m5_nut_t,
       "M5 too short to reach through its nut");
assert(usb_y[0] > m4_off + m4_boss / 2 - half + bd_r, "USB notch eats the corner ear");
assert(usb_y[0] <= usb_cy - 5.5 && usb_y[1] >= usb_cy + 5.5,
       "USB window does not cover the measured port centre +/- boot radius");
// 1.0 is deliberate: the port at y=23 squeezes ear #1 into a 14 mm gap, and
// nothing protrudes from the board edge (flush rear-mounted plungers)
assert(by(btnl_y[0]) - (by(m5_ear_y[0]) + m5_boss / 2) >= 1.0,
       "M5 ear #1 crowds the A/B/C/D finger window");
assert((by(m5_ear_y[0]) - m5_boss / 2) - by(usb_y[1]) >= 1.0,
       "M5 ear #1 crowds the USB notch");
assert(rib_y[0] >= 95, "back rib strays into the bottom-half component zone");
assert(wall_x0 - (m8_x + m8_washer / 2) >= 3, "wall foot rides the M8 washers");
assert(gap - plug_len * cos(yaw) >= pl_t + 4, "USB plug boot reaches the rail plate");
assert(xi_strip > xi_m5 && xi_top > xi_rib[1], "wall does not cover its bolt lines");
assert(ear_gy(0) > 10 && ear_gy(2) < pl_h - 10, "M5 ear line overruns the wall height");
assert(max(2 * (half + m5_off + m5_boss / 2), pl_h, pl_t + xi_top * cos(yaw) + 10) <= 256,
       "exceeds the Bambu A1 bed (256 sq)");

// ---------------------------------------------------------------------
// 2D building blocks (frame/ring space: board-centred, +y up, front view)
// ---------------------------------------------------------------------
module board2d() { rect([bd, bd], rounding = bd_r); }

// Common outer profile: rounded square band + the M4/M5 ear bumps, so the
// frame and ring rims sit flush with each other.
module outer2d() {
    union() {
        rect([2 * out_half, 2 * out_half], rounding = bd_r + bd_clr + band_w);
        for (p = m4_pts) translate(p) circle(d = m4_boss);
        // +1 vs the M5 boss columns: equal radii would put two tessellated
        // cylinders face-on-face (degenerate slivers, the ebrake lesson)
        for (p = m5_ear_pts) translate(p) circle(d = m5_boss + 1);
    }
}

// The frame's open middle: board minus the rear lips, plus full-width
// relief strips where the rear face must stay untouched (lip keep-outs).
module frame_window2d() {
    union() {
        rect([bd - 2 * rear_lip, bd - 2 * rear_lip], rounding = 2);
        // keep-outs run from outside the board (+lap) to past the lip line
        translate([-half - bd_clr - lap, by(keepl_y[0]) - lap])
            square([bd_clr + rear_lip + 2 * lap, keepl_y[1] - keepl_y[0] + lap]);
        translate([half - rear_lip - lap, by(keepr_y[0]) - lap])
            square([bd_clr + rear_lip + 2 * lap, keepr_y[1] - keepr_y[0] + lap]);
        translate([bx(keepb_x[0]) - lap, -half - bd_clr - lap])
            square([keepb_x[1] - keepb_x[0] + lap, bd_clr + rear_lip + 2 * lap]);
    }
}

// Finger/plug notches through the left/right band, cut from outside in.
module edge_notch(side, y0, y1, z0, depth) {  // side: -1 left, +1 right
    translate([side * (out_half + m5_boss) / 2 + side * lap, (by(y0) + by(y1)) / 2,
               z0 + depth / 2])
        cube([out_half + m5_boss + 4 * lap, y1 - y0, depth], center = true);
}

// Hex-nut pocket: nut void + an insertion slot swept toward `dir` (2D dir).
module nut_pocket(w, t, z0, dir, slot_l) {
    translate([0, 0, z0])
        linear_extrude(t)
            hull() {
                rot(30) hexagon(id = w);
                translate(dir * slot_l) rot(30) hexagon(id = w);
            }
}

// ---------------------------------------------------------------------
// frame — prints front-face down (z=0 is the board's back seat plane)
// ---------------------------------------------------------------------
module frame() {
    diff() {
        union() {
            linear_extrude(fr_d)
                difference() { outer2d(); frame_window2d(); }
            // M5 bosses rise to the wall contact plane. They overhang the
            // board outline by ~1 in plan, but only at z > 0 — the board
            // (z < 0) and the ring skirt never reach that depth.
            for (p = m5_ear_pts)
                translate(p) linear_extrude(m5_col_d) circle(d = m5_boss);
            // back rib: a chord across the clean upper-back zone, carrying
            // the two inboard M5s; buried 1 mm into both side lips.
            translate([0, by((rib_y[0] + rib_y[1]) / 2), (rib_z0 + m5_col_d) / 2])
                cube([bd - 2 * rear_lip + 2, rib_y[1] - rib_y[0], m5_col_d - rib_z0],
                     center = true);
        }

        // edge windows
        tag("remove") edge_notch(-1, usb_y[0], usb_y[1], -lap, usb_nd + lap);
        tag("remove") edge_notch(-1, btnl_y[0], btnl_y[1], -lap, btn_nd + lap);
        tag("remove") edge_notch(1, btnr_y[0], btnr_y[1], -lap, btn_nd + lap);

        // M4: clearance bore + back-opening pocket (nut bears on the floor)
        for (p = m4_pts) tag("remove") translate(p) {
            translate([0, 0, -lap]) cylinder(d = m4_hole, h = fr_d + 2 * lap);
            // slot toward the outside so squeeze-out can't lock the nut
            nut_pocket(m4_nut_w + 2 * nut_clr, fr_d - m4_nut_z + lap, m4_nut_z,
                       unit(p == [0, m4_c] ? [0, 1] : p == [0, -m4_c] ? [0, -1] : p),
                       m4_boss);
        }

        // M5 bores + captive-nut pockets (slot outward / downward)
        for (p = m5_ear_pts) tag("remove") translate(p) {
            translate([0, 0, -lap]) cylinder(d = m5_hole, h = m5_col_d + 2 * lap);
            nut_pocket(m5_nut_w + 2 * nut_clr, m5_nut_z[1] - m5_nut_z[0], m5_nut_z[0],
                       [-1, 0], m5_boss);
        }
        for (p = rib_pts) tag("remove") translate(p) {
            translate([0, 0, rib_z0 - lap])
                cylinder(d = m5_hole, h = m5_col_d - rib_z0 + 2 * lap);
            nut_pocket(m5_nut_w + 2 * nut_clr, m5_nut_z[1] - m5_nut_z[0],
                       max(m5_nut_z[0], rib_z0 + 1), [0, -1],
                       (rib_y[1] - rib_y[0]) / 2 + 2);
        }

        // bed-face squish relief: chamfer the outer rim of the front face
        tag("remove") translate([0, 0, -eps])
            linear_extrude(foot_ch + eps, scale = 1)
                difference() {
                    offset(delta = lap) outer2d();
                    offset(delta = -foot_ch) outer2d();
                }
    }
}

// ---------------------------------------------------------------------
// ring — prints front-face down (z=0 is the visible front; +z backward)
// ---------------------------------------------------------------------
module ring() {
    diff() {
        union() {
            // rim + skirt: one full-depth body from the outer profile down to
            // the board clearance line — its back lands on the frame band
            linear_extrude(ring_t + chan_t)
                difference() {
                    outer2d();
                    offset(r = bd_clr) board2d();
                }
            // lip field: the part of the face over the board itself — lips on
            // top/bottom/left, fully open right edge (the light sensor sits
            // somewhere along it). Reaches 1 past the clearance line into the
            // rim body: a volumetric overlap, never a coincident face.
            linear_extrude(ring_t)
                difference() {
                    offset(r = bd_clr + 1) board2d();
                    translate([(-half + lip + half + bd_clr + 1 + lap) / 2, 0])
                        rect([bd - lip + bd_clr + 1 + lap, bd - 2 * lip],
                             rounding = [0, 2, 2, 0]);
                }
        }
        // finger openings through the SKIRT only — the flush plungers sit
        // behind the board, so the face ring stays continuous over them
        for (w = [[-1, btnl_y], [1, btnr_y]])
            tag("remove") edge_notch(w[0], w[1][0], w[1][1], ring_t, chan_t + lap);
        // the USB cut goes through the FULL ring: the boot (centre ~2.5
        // behind the board's back, dia ~10) reaches past the board plane
        // into the rim zone. One full-depth cut leaves the rim connected
        // the long way round — still a single body.
        tag("remove") edge_notch(-1, usb_y[0], usb_y[1], -lap, ring_t + chan_t + 2 * lap);
        // M4 through-bores (the M5s never touch the ring — they enter from
        // the wall's back and stop inside the frame bosses)
        for (p = m4_pts) tag("remove") translate(p)
            translate([0, 0, -lap]) cylinder(d = m4_hole, h = ring_t + chan_t + 2 * lap);
        // bed-face squish relief on the visible front rim
        tag("remove") translate([0, 0, -eps])
            linear_extrude(foot_ch + eps)
                difference() {
                    offset(delta = lap) outer2d();
                    offset(delta = -foot_ch) outer2d();
                }
    }
}

// ---------------------------------------------------------------------
// bracket — prints rail-face down (z=0 on the bed = the rail face)
// ---------------------------------------------------------------------
module wall_unrot() {
    // modelled straight, then leaned `yaw` about the foot pivot; xi maps to
    // z = pl_t + xi. Holes/slots are bored along local x so they stay
    // normal to the wall after the lean. tag_scope: this diff must resolve
    // its own "remove" tags, not donate them to bracket()'s outer diff.
    ws = wall_t;
    tag_scope() diff() {
        union() {
            // full-height strip (buried into the plate) + the rib arm
            translate([wall_x0, 0, 0]) cube([ws, pl_h, pl_t + xi_strip]);
            translate([wall_x0, arm_y[0], pl_t + xi_strip - lap])
                cube([ws, arm_y[1] - arm_y[0], xi_top - xi_strip + lap]);
        }
        // M5 bores, teardropped (they print as near-horizontal bores; the
        // teardrop profile lives in XZ extruded along Y, so zrot turns the
        // length through the wall while the apex keeps pointing print-up)
        for (i = [0:2]) tag("remove")
            translate([wall_x0 + ws / 2, ear_gy(i), pl_t + xi_m5])
                zrot(90) teardrop(d = m5_hole, l = ws + 2 * lap,
                                  cap_h = m5_hole / 2 + 0.6, anchor = CENTER);
        for (x = xi_rib) tag("remove")
            translate([wall_x0 + ws / 2, rib_gy, pl_t + x])
                zrot(90) teardrop(d = m5_hole, l = ws + 2 * lap,
                                  cap_h = m5_hole / 2 + 0.6, anchor = CENTER);
        // zip-tie slots under the USB drop for the strain relief
        for (y = [board_y0 + 6, board_y0 + 26]) tag("remove")
            translate([wall_x0 - lap, y, pl_t + 10])
                cube([ws + 2 * lap, zt_slot[0], zt_slot[1]]);
    }
    // Weak-axis gussets on the monitor side, stationed between the M8
    // washer rows and clear of the hex-key paths. They lean with the wall;
    // the base sits at local z=-4 so the rotation can't lift the toe off
    // the plate (the lean raises points left of the pivot).
    for (y = [pl_h / 2, pl_h / 2 - 55, pl_h / 2 + 55])
        translate([0, y + 3, 0])
            rotate([90, 0, 0])
                linear_extrude(6)
                    polygon([[wall_x0 + 1, -4], [wall_x0 + 1, pl_t + 22],
                             [wall_x0 - 22, -4]]);
}

module bracket() {
    diff() {
        union() {
            // rail plate
            cuboid([pl_w, pl_h, pl_t], rounding = 3, edges = "Z",
                   anchor = BOTTOM, orient = UP)
                ;
            translate([0, -pl_h / 2, 0])
                yrot(yaw, cp = pivot) wall_unrot();
        }
        // M8 clearance bores, vertical in print — no teardrop needed
        for (sx = [-1, 1], y = m8_y) tag("remove")
            translate([sx * m8_x, y - pl_h / 2, -lap])
                cylinder(d = m8_hole, h = pl_t + 2 * lap);
        // countersink the bed rims so first-layer squish can't bind the M8s
        for (sx = [-1, 1], y = m8_y) tag("remove")
            translate([sx * m8_x, y - pl_h / 2, -eps])
                cylinder(d1 = m8_hole + 2 * (foot_ch + eps), d2 = m8_hole,
                         h = foot_ch + eps);
        // elephant-foot chamfer around the plate's bed face
        tag("remove") translate([0, 0, -eps])
            linear_extrude(foot_ch + eps)
                difference() {
                    rect([pl_w + 2 * lap, pl_h + 2 * lap]);
                    rect([pl_w - 2 * foot_ch, pl_h - 2 * foot_ch], rounding = 3);
                }
    }
}

// ---------------------------------------------------------------------
// composition
// ---------------------------------------------------------------------
module board_ghost() {
    color("seagreen", 0.5) translate([0, 0, -pcb_t])
        linear_extrude(pcb_t) board2d();
}

// frame space -> bracket space: frame +x runs up the wall (xi direction),
// frame +z points into the wall, and the frame's contact plane (z =
// m5_col_d) lands on the wall's driver-side face.
module place_on_wall() {
    t = [sin(yaw), 0, cos(yaw)];   // up the leaning wall
    o = pivot + (wall_t / 2 + m5_col_d) * wall_n + (xi_bl + half) * t
        + [0, board_y0 + half - pl_h / 2, 0];
    translate(o) yrot(yaw - 90) children();
}

// USB plug boot keep-out: straight micro-B inserted at the port (centre
// usb_cy above the bottom edge, ~2.5 behind the board's back, boot dia
// ~10 so it reaches past the board plane), running toward the rail.
module plug_ghost() {
    color("crimson", 0.5)
        translate([-half - plug_len, by(usb_cy) - 5, -2.5])
            cube([plug_len + 1, 10, 10]);
}

if (part == "bracket") bracket();
else if (part == "frame") frame();
else if (part == "ring") ring();
else if (part == "collide") {
    // must render EMPTY ("Current top level object is empty"): board + plug
    // vs all three printed parts. Ghosts shrunk 0.05/side so the intended
    // resting contact (board on the lips) doesn't register as a degenerate
    // zero-volume sheet.
    intersection() {
        union() {
            place_on_wall() translate([0, 0, -pcb_t + 0.05])
                linear_extrude(pcb_t - 0.1) offset(delta = -0.05) board2d();
            place_on_wall() translate([0.05, 0.05, 0.05]) scale([0.99, 0.99, 0.98])
                plug_ghost();
        }
        union() {
            bracket();
            place_on_wall() { frame(); translate([0, 0, -ring_stk]) ring(); }
        }
    }
}
else if (part == "assembly") {
    bracket();
    place_on_wall() {
        frame();
        translate([0, 0, -ring_stk]) ring();
        board_ghost();
    }
}
else {  // printable plate: three bodies, slicer splits objects
    translate([-200, 0, 0]) bracket();
    frame();
    translate([250, 0, 0]) ring();
}
