// =====================================================================
//  uniflag — Pimoroni Cosmic Unicorn mount for the GT Omega PRIME Lite
//  (8040 rig). Three printed parts in one multi-body project:
//
//   * bracket — bolts flat to the outboard 80 mm face of the right
//     wheel-deck upright (4x M8x14 + T-nuts, two slot columns 40 mm
//     apart) and carries a short wall parallel to the panel plane,
//     yawed `yaw` deg toward the seat. The frame bolts to that wall.
//   * frame   — rear picture-frame ring the board drops into, extended
//     railward into a flat bolt FLANGE (a 2x2 M5 grid outside the
//     board's left edge). Uniform fr_d deep: the whole part prints
//     back-face down with no supports. Touches the board only at
//     segmented rear lips that dodge the Pico, the bottom connector
//     cluster and the edge-button bodies — the back (incl. the
//     speaker) stays open.
//   * ring    — front clamp ring: a 5 mm lip over the board's dark
//     border on all four edges — windowed over the light sensor at
//     board (4, 116) — plus a perimeter skirt that locates the board
//     in-plane. M4x14 + captive nuts clamp ring -> frame; the board
//     floats in a fixed-height channel and never sees bolt preload.
//
//  Fasteners (owner's bin only): 4x M8x14, 4x M5x30 + nuts/washers,
//  5x M4x14 + nuts. M5 socket heads sink into flange counterbores from
//  the front; nuts + washers go on the wall's monitor side. The 6.5 mm
//  counterbore floor bears the preload in pure compression against the
//  wall face — no captive M5 pockets, no thin floors.
//
//  Board geometry is DXF-exact (see docs/ + SPEC.md). Board-edge
//  coordinates below are mm from the board's front-view bottom-left
//  corner; frame/ring model space is centred on the board with x/y as
//  in that front view and +z = from the board's back toward the DRIVER
//  (the wall sits at -z). +z must point at the viewer of the front
//  view: with x right and y up, a rigward +z makes the space
//  left-handed and silently models the mirror image.
//
//  Print (Bambu A1, open frame -> PETG over ASA): all three parts flat
//  as laid out (part="plate"), >=4 walls, brim on frame + ring. No
//  supports and no bridges beyond trivial spans (nut-pocket floors,
//  zip-slot ceilings): the wall leans `yaw` deg (self-supporting), the
//  M5 wall bores are teardropped, and the frame prints back-face down
//  so its notches open upward.
// =====================================================================
include <BOSL2/std.scad>
$fa = 2; $fs = 0.5;

part = "plate"; // [plate, bracket, frame, ring, assembly, collide]

/* [Board — Pimoroni Cosmic Unicorn, DXF-exact + measured] */
bd        = 204;    // square board edge
bd_r      = 3;      // board corner radius
pcb_t     = 2.0;    // border stack thickness (measured ~2.0 — NOT the bare 1.6)

/* [Fit] */
bd_clr     = 0.4;   // in-plane clearance around the board outline
chan_slack = 0.35;  // board float in the grip channel (zero = rattle-free but risks bowing)

/* [Front ring] */
lip       = 5;      // front lip, all four edges
sens_y    = [108, 124]; // light-sensor window in the LEFT lip (sensor at (4, 116))
ring_t    = 3;      // ring plate thickness
foot_ch   = 0.6;    // elephant-foot chamfer on bed-face perimeters

/* [Rear frame] */
rear_lip  = 4;      // rear lip depth onto the board's back border
band_w    = 4;      // structural band thickness outside the board
fr_d      = 12;     // frame depth — uniform; the back face IS the wall contact plane

/* [Edge windows — board-edge mm, y from board bottom / x from board left] */
usb_cy    = 17;         // port centreline above the bottom edge
usb_y     = [11, 23];   usb_nd = 9;   // USB tunnel depth (boot reaches 8 behind the board)
// Buttons are rear-mounted with flush plungers (bodies ~5 in from the edge,
// nothing protrudes) — the windows are fingertip reach-ins. Their depth
// stops 3 short of fr_d: that continuous back strip keeps both side bands
// (and the row-1 flange tab) connected, and because the frame prints
// BACK-face down it is a floor on the bed, not a bridge.
btnl_y    = [43, 84];   btn_nd = 9;   // A/B/C/D finger window
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

/* [M5 bracket joint — 2x2 grid through the flange] */
m5_off    = 5.5;    // inner bolt column outside the board's left edge
col_sp    = 14;     // column spacing (door-hinge couple arm)
m5_rows   = [30, 186]; // bolt rows: row 1 sits just ABOVE the USB tunnel — below
                       // it, the counterbore reaches the corner ear's nut pocket
m5_hole   = 5.5;
m5_len    = 30;
cb_d      = 9.8;    // socket-head counterbore (head sinks below the ring plane)
cb_dep    = 5.5;
m5_nut_t  = 4.0;
m5_wash_t = 1.0;
fl_marg   = 7;      // flange extent past the outer column
fl_round  = 4;      // flange outer-corner rounding

/* [Bracket — rail plate + leaning wall] */
pl_w      = 80;     // rail plate width  = the 80 mm profile face
pl_h      = 210;    // rail plate height along the slots
pl_t      = 8;
pl_r      = 6;      // plate corner rounding (generous: corner-warp relief)
m8_hole   = 8.5;
m8_x      = 20;     // slot columns at +/-20 from the face centre (verified)
m8_y      = [25, 185];
wall_t    = 8;
wall_x0   = 32;     // wall foot inner face (washer keep-out asserted)
yaw       = 25;     // panel yaw toward the seat
gap       = 42;     // rail face -> board left edge (measured 30 boot + bend room)
board_y0  = 4;      // board bottom edge above the plate bottom
wall_marg = 6;      // wall extent beyond the inner bolt column
zt_slot   = [4, 8]; // zip-tie slot w x h (strain relief, through the wall foot)

/* [Hardware facts — only used by asserts] */
m8_washer = 17;
m8_head_d = 13;
m4_head_d = 7;
m5_head_d = 8.7;
m5_head_h = 5;
plug_len  = 30;     // micro-B boot past the board edge (measured, owner's cable)
led_inset = 7.25;   // first LED package edge from the board edge (DXF)

// --- derived (mm) ---
chan_t   = pcb_t + chan_slack;            // grip channel height (skirt depth)
ring_stk = ring_t + chan_t;               // ring front face -> frame front face
half     = bd / 2;
out_half = half + bd_clr + band_w;        // frame/ring outer half-size (sans ears)
m4_c     = half + m4_off;                 // M4 bolt lines from board centre
fl_edge  = half + m5_off + col_sp + fl_marg;  // flange extent left of centre
function bx(v) = v - half;                // board-edge mm -> centred model mm
function by(v) = v - half;
// 5 bolts: corners + mid-top. No mid-bottom ear — it would sit right on
// the Qw/ST cluster, whose keep-out would breach the bore.
m4_pts   = [for (sx = [-1, 1], sy = [-1, 1]) [sx * m4_c, sy * m4_c],
            [0, m4_c]];
m5_cols  = [-(half + m5_off), -(half + m5_off + col_sp)];
m5_pts   = [for (cx = m5_cols, ry = m5_rows) [cx, by(ry)]];

// M4: head on the ring front; nut dropped into a back-opening pocket and
// pulled against its floor (toward the head) — floor depth is the load path.
m4_tip   = m4_len - ring_stk;             // thread reach into the frame
m4_nut_z = m4_tip - (m4_nut_t + nut_clr); // pocket floor (nut bears here)

// M5: socket head sunk cb_dep into the flange front; shank through the
// remaining flange + the wall; washer + nut on the wall's monitor side.
m5_proud = m5_len - (fr_d - cb_dep) - wall_t - m5_wash_t - m5_nut_t;

lap = 1;     // cut over-extension; eps for unions
eps = 0.02;

// wall geometry: xi = distance up the wall from its foot pivot (plate top,
// x = wall mid-plane). The frame's BACK plane (z = -fr_d) lands directly on
// the wall's driver face — a frame point at model x sits at xi_bl + x + half.
wall_n   = [-cos(yaw), 0, -sin(yaw)];          // wall normal, toward the driver
xi_bl    = (gap - pl_t + (wall_t / 2 + fr_d) * sin(yaw)) / cos(yaw);
function xi_of(x) = xi_bl + x + half;          // frame model x -> xi up the wall
xi_strip = xi_of(m5_cols[0]) + wall_marg;      // wall top covers the inner column
pivot    = [-(wall_x0 + wall_t / 2), 0, pl_t];

echo(str("channel: ", chan_t, "  ring stack: ", ring_stk));
echo(str("M4 tip ", m4_tip, " into frame, nut floor ", m4_nut_z, " behind the board"));
echo(str("M5 thread proud past the nut: ", m5_proud));
echo(str("wall xi: board edge ", xi_bl, ", cols ", xi_of(m5_cols[0]), "/",
         xi_of(m5_cols[1]), ", flange edge ", xi_of(-fl_edge)));
echo(str("frame envelope: ", fl_edge + m4_c + m4_boss / 2, " x ", 2 * (m4_c + m4_boss / 2)));

// Clearances and reach — fail loudly instead of printing scrap.
assert(lip <= led_inset - 0.5, "front lip would shade the first LED row");
assert(m4_c - m4_hole / 2 - half >= 0.4, "M4 bolt line cuts the board outline");
assert(norm([m4_c - (half - bd_r), m4_c - (half - bd_r)]) - bd_r - m4_hole / 2 >= 1,
       "M4 corner bolt too close to the board corner arc");
assert(m4_nut_z >= 3.5, "M4 nut floor too thin to carry the clamp preload");
assert(m4_tip <= fr_d - 0.5, "M4 pokes out of the frame band");
assert(m4_tip - (m4_nut_z + m4_nut_t) >= 0.3, "M4 too short to fill its nut");
assert(cb_d >= m5_head_d + 0.8, "M5 head won't drop into its counterbore");
assert(cb_dep >= m5_head_h + 0.3, "M5 head stands proud of the flange front");
assert(fr_d - cb_dep >= 4, "counterbore floor too thin for the M5 preload");
assert(m5_proud >= 1.5, "M5 too short to fill washer + nut behind the wall");
assert(m5_rows[0] - cb_d / 2 >= usb_y[1] + 1, "row 1 crowds the USB tunnel");
assert(m5_rows[0] + cb_d / 2 <= btnl_y[0] - 1, "row 1 crowds the finger window");
assert(m5_rows[1] - cb_d / 2 >= btnl_y[1] + 1, "row 2 crowds the finger window");
assert(min([for (p = m5_pts, sy = [-1, 1]) norm(p - [-m4_c, sy * m4_c])])
       >= (m4_nut_w + 2 * nut_clr) / sqrt(3) + cb_d / 2 + 0.8,
       "M5 counterbore bites an M4 nut pocket");
assert(by(m5_rows[0]) - cb_d / 2 >= -out_half + 2, "row 1 falls off the flange");
assert(by(m5_rows[1]) + cb_d / 2 <= out_half - 2, "row 2 falls off the flange");
assert(fl_marg >= cb_d / 2 + 1, "outer-column counterbore breaks the flange edge");
assert(usb_y[0] >= m4_boss / 2 - m4_off + 1, "USB notch eats the corner ear");
assert(usb_y[0] <= usb_cy - 5.5 && usb_y[1] >= usb_cy + 5.5,
       "USB window does not cover the measured port centre +/- boot radius");
assert(plug_len >= fl_edge - half - 2, "boot buried deep in the tunnel: no bend room");
assert(wall_x0 - (m8_x + m8_washer / 2) >= 3, "wall foot rides the M8 washers");
assert(gap - plug_len * cos(yaw) >= pl_t + 4, "USB plug boot reaches the rail plate");
assert(xi_of(-fl_edge) * cos(yaw) - (wall_t / 2) * sin(yaw) >= 6,
       "flange lower edge rides the rail plate");
assert(xi_of(-fl_edge) > zt_slot[1] + 3 + 1, "zip-tie slots run under the flange");
assert(board_y0 + m5_rows[0] - pl_r >= 6 && pl_h - pl_r - (board_y0 + m5_rows[1]) >= 6,
       "M5 rows overrun the wall ends");
assert(max(fl_edge + m4_c + m4_boss / 2, pl_h, pl_t + xi_strip * cos(yaw) + 10) <= 256,
       "exceeds the Bambu A1 bed (256 sq)");

// ---------------------------------------------------------------------
// 2D building blocks (frame/ring space: board-centred, +y up, front view)
// ---------------------------------------------------------------------
module board2d() { rect([bd, bd], rounding = bd_r); }

// Shared outer profile (frame and ring rims sit flush): rounded square
// band + the M4 ear bumps. The frame alone adds the M5 flange.
module outline2d() {
    union() {
        rect([2 * out_half, 2 * out_half], rounding = bd_r + bd_clr + band_w);
        for (p = m4_pts) translate(p) circle(d = m4_boss);
    }
}

// Bolt flange: a flat railward extension of the left band carrying the
// 2x2 M5 grid. Overlaps the band by 10 so the union never kisses.
module flange2d() {
    translate([(-fl_edge - (out_half - 10)) / 2, 0])
        rect([fl_edge - out_half + 10, 2 * out_half],
             rounding = [0, fl_round, fl_round, 0]);
}

module frame_base2d() { union() { outline2d(); flange2d(); } }

// The frame's open middle: board minus the rear lips, plus full-width
// relief strips where the rear face must stay untouched (lip keep-outs).
module frame_window2d() {
    union() {
        rect([bd - 2 * rear_lip, bd - 2 * rear_lip], rounding = 2);
        // keep-outs reach bd_clr past the board edge and lap past the lip
        // line inboard — never farther out: the bottom M4 bosses sit close,
        // and overshooting into the band breaches their bores
        translate([-half - bd_clr, by(keepl_y[0]) - bd_clr])
            square([bd_clr + rear_lip + lap, keepl_y[1] - keepl_y[0] + bd_clr]);
        translate([half - rear_lip - lap, by(keepr_y[0]) - bd_clr])
            square([bd_clr + rear_lip + lap, keepr_y[1] - keepr_y[0] + bd_clr]);
        translate([bx(keepb_x[0]) - bd_clr, -half - bd_clr])
            square([keepb_x[1] - keepb_x[0] + bd_clr, bd_clr + rear_lip + lap]);
    }
}

// Finger/plug openings cut through the left/right edge from outside in.
// The inner extent (90) ends inside the already-open window — harmless.
module edge_notch(side, y0, y1, z0, depth) {  // side: -1 left, +1 right
    xo = side < 0 ? -(fl_edge + lap) : 90;
    translate([xo, by(y0), z0])
        cube([(side < 0 ? fl_edge : out_half) + lap - 90, y1 - y0, depth]);
}

// First-layer squish relief: a 45-deg staircase rim cut on the bed face of
// the 2D outline passed as children. A straight rebate leaves a foot_ch
// ledge overhanging after the first layers; OpenSCAD can't taper-extrude an
// arbitrary outline, but three one-layer steps slice exactly like a 45-deg
// chamfer at 0.2 mm layers.
module foot_relief() {
    steps = 3;
    for (i = [0:steps - 1])
        translate([0, 0, -eps + i * foot_ch / steps])
            linear_extrude(foot_ch / steps + 2 * eps)
                difference() {
                    offset(delta = lap) children();
                    offset(delta = -foot_ch * (steps - i) / steps) children();
                }
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
// frame — occupies z [-fr_d, 0]; the back face z = -fr_d is the wall
// contact plane and prints on the bed, so every front-opening notch
// leaves a printable floor, never a bridge
// ---------------------------------------------------------------------
module frame() {
    diff() {
        down(fr_d) linear_extrude(fr_d)
            difference() { frame_base2d(); frame_window2d(); }

        // edge windows, cut from the front; the 3 mm strip behind them keeps
        // the bands continuous (and prints first, flat on the bed)
        tag("remove") edge_notch(-1, usb_y[0], usb_y[1], -usb_nd, usb_nd + lap);
        tag("remove") edge_notch(-1, btnl_y[0], btnl_y[1], -btn_nd, btn_nd + lap);
        tag("remove") edge_notch(1, btnr_y[0], btnr_y[1], -btn_nd, btn_nd + lap);

        // M4: clearance bore + back-opening pocket (nut bears on the floor)
        for (p = m4_pts) tag("remove") translate(p) {
            translate([0, 0, -fr_d - lap]) cylinder(d = m4_hole, h = fr_d + 2 * lap);
            // slot toward the outside so squeeze-out can't lock the nut
            nut_pocket(m4_nut_w + 2 * nut_clr, fr_d - m4_nut_z + lap, -fr_d - lap,
                       unit(p == [0, m4_c] ? [0, 1] : p),
                       m4_boss);
        }

        // M5 grid: through-bore + front counterbore. The head sinks below
        // the ring plane; the 6.5 floor bears on the wall in compression.
        // The back rim gets a squish countersink so first-layer flare can't
        // hold the contact face off the wall.
        for (p = m5_pts) tag("remove") translate(p) {
            translate([0, 0, -fr_d - lap]) cylinder(d = m5_hole, h = fr_d + 2 * lap);
            translate([0, 0, -cb_dep]) cylinder(d = cb_d, h = cb_dep + lap);
            translate([0, 0, -fr_d - eps])
                cylinder(d1 = m5_hole + 2 * (foot_ch + eps), d2 = m5_hole,
                         h = foot_ch + eps);
        }

        // bed-face squish relief on the outer rim of the BACK face
        tag("remove") translate([0, 0, -fr_d]) foot_relief() frame_base2d();
    }
}

// ---------------------------------------------------------------------
// ring — occupies z [0, ring_stk]; z = 0 lands on the frame band, the
// visible front face is z = ring_stk (flipped front-face down to print)
// ---------------------------------------------------------------------
module ring() {
    diff() {
        union() {
            // rim + skirt: one full-depth body from the outer profile down to
            // the board clearance line — its back lands on the frame band
            linear_extrude(ring_t + chan_t)
                difference() {
                    outline2d();
                    offset(r = bd_clr) board2d();
                }
            // lip field: the part of the face over the board itself — lips
            // on all four edges, the left one windowed over the light
            // sensor. Reaches 1 past the clearance line into the rim body:
            // a volumetric overlap, never a coincident face.
            up(chan_t) linear_extrude(ring_t)
                difference() {
                    offset(r = bd_clr + 1) board2d();
                    rect([bd - 2 * lip, bd - 2 * lip], rounding = 2);
                    translate([-half - bd_clr - 1 - lap, by(sens_y[0])])
                        square([bd_clr + 1 + lip + 2 * lap, sens_y[1] - sens_y[0]]);
                }
        }
        // no button openings: the plungers actuate behind the board, the
        // frame's reach-in windows alone cover them
        // USB: skirt-deep only — the boot tops out at the board's FRONT
        // face, so the face ring runs unbroken over it
        tag("remove") edge_notch(-1, usb_y[0], usb_y[1], -lap, chan_t + lap);
        // M4 through-bores (the M5 heads stop inside the frame flange and
        // never reach the ring)
        for (p = m4_pts) tag("remove") translate(p)
            translate([0, 0, -lap]) cylinder(d = m4_hole, h = ring_t + chan_t + 2 * lap);
        // bed-face squish relief on the visible front rim
        tag("remove") translate([0, 0, ring_stk]) zflip() foot_relief() outline2d();
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
        // the slab spans only the plate's straight edge (pl_r short of each
        // end): its ends meet the edge exactly at the corner-arc tangents,
        // so nothing pokes past the rounding and every joint stays planar
        translate([-wall_x0 - ws, pl_r, 0])
            cube([ws, pl_h - 2 * pl_r, pl_t + xi_strip]);
        // M5 bores, teardropped (they print as near-horizontal bores; the
        // teardrop profile lives in XZ extruded along Y, so zrot turns the
        // length through the wall while the apex keeps pointing print-up)
        for (cx = m5_cols, ry = m5_rows) tag("remove")
            translate([-wall_x0 - ws / 2, board_y0 + ry, pl_t + xi_of(cx)])
                zrot(90) teardrop(d = m5_hole, l = ws + 2 * lap,
                                  cap_h = m5_hole / 2 + 0.6, anchor = CENTER);
        // zip-tie slots through the wall foot, below the flange edge, for
        // the USB strain relief (the cable drops past the foot here)
        for (y = [board_y0 + 10, board_y0 + 30]) tag("remove")
            translate([-wall_x0 - ws - lap, y, pl_t + 3])
                cube([ws + 2 * lap, zt_slot[0], zt_slot[1]]);
    }
    // Weak-axis gussets on the monitor side, stationed between the M8
    // washer rows and clear of the hex-key paths. They lean with the wall;
    // the base sits at local z=-4 so the rotation can't lift the toe off
    // the plate (the lean raises points right of the pivot, and sinks
    // points near it — bracket() clips everything back to the bed plane).
    for (y = [pl_h / 2, pl_h / 2 - 55, pl_h / 2 + 55])
        translate([0, y + 3, 0])
            rotate([90, 0, 0])
                linear_extrude(6)
                    polygon([[-wall_x0 - 1, -4], [-wall_x0 + 18, -4],
                             [-wall_x0 - 1, pl_t + 16]]);
}

module bracket() {
    diff() {
        union() {
            // rail plate
            cuboid([pl_w, pl_h, pl_t], rounding = pl_r, edges = "Z",
                   anchor = BOTTOM, orient = UP)
                ;
            // clip at the bed plane: the lean sinks the gusset bases and
            // the wall foot's outer corner below z=0
            translate([0, -pl_h / 2, 0]) intersection() {
                yrot(-yaw, cp = pivot) wall_unrot();
                translate([-200, -10, 0]) cube([400, pl_h + 20, 250]);
            }
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
        // elephant-foot relief around the plate's bed face
        tag("remove") foot_relief() rect([pl_w, pl_h], rounding = pl_r);
    }
}

// ---------------------------------------------------------------------
// composition
// ---------------------------------------------------------------------
module board_ghost() {
    color("seagreen", 0.5) linear_extrude(pcb_t) board2d();
}

// frame space -> bracket space: frame +x runs up the wall (xi direction),
// frame +z points off the wall toward the driver, and the frame's back
// plane (z = -fr_d) lands on the wall's driver-side face.
module place_on_wall() {
    t = [-sin(yaw), 0, cos(yaw)];   // up the leaning wall
    o = pivot + (wall_t / 2 + fr_d) * wall_n + (xi_bl + half) * t
        + [0, board_y0 + half - pl_h / 2, 0];
    translate(o) yrot(-90 - yaw) children();
}

// USB plug boot keep-out: straight micro-B inserted at the port (centre
// usb_cy above the bottom edge; boot dia ~10, topping out at the board's
// FRONT face), running toward the rail.
module plug_ghost() {
    color("crimson", 0.5)
        translate([-half - plug_len, by(usb_cy) - 5, -8])
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
            place_on_wall() translate([0, 0, 0.05])
                linear_extrude(pcb_t - 0.1) offset(delta = -0.05) board2d();
            place_on_wall() translate([-half - plug_len + 0.05, by(usb_cy) - 4.95, -7.95])
                cube([plug_len + 1 - 0.1, 9.9, 9.9]);
        }
        union() {
            bracket();
            place_on_wall() { frame(); ring(); }
        }
    }
}
else if (part == "assembly") {
    bracket();
    place_on_wall() {
        frame();
        ring();
        board_ghost();
    }
}
else {  // printable plate: three bodies print-side down, slicer splits objects
    translate([-190, 0, 0]) bracket();
    up(fr_d) frame();                                       // back-face down
    translate([245, 0, 0]) up(ring_stk) yrot(180) ring();   // front-face down
}
