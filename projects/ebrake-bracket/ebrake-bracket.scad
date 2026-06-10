// =====================================================================
//  E-brake mount -> GT Omega PRIME Lite (8040 / 80x40 profile) sim rig.
//  Gusseted L-bracket, design rev 2: the leg bolts to the INNER VERTICAL
//  FACE of a fore/aft side rail (M8 T-nuts); the handbrake sits upright
//  on the shelf and pulls straight back (-Y). Symmetric in Y, not handed.
//
//  Rev 1 was printed and test-fitted (hole patterns verified, shelf flush
//  with the profile top) but its upper rail bolts at y=+/-44 sat directly
//  behind the handbrake's corner-bolt nuts (y=+/-43, hanging 7 mm below
//  the shelf) -- unreachable with the handbrake mounted. Rev 2 keeps every
//  verified interface and fixes that, plus print/strength/finish rework:
//   * UPPER rail bolts at y = +/-13, in the open channel between the
//     gussets (T-nuts slide along the slot, so any y is valid); the lower
//     pair stays wide at +/-44 for yaw stiffness.
//   * r5 cove fillet along the leg/shelf junction, with flat o15
//     spot-faced seats where the bolt heads land on the fillet.
//   * Gussets keep rev 1's proven 52x56 reach but get a concave-arc free
//     edge (lighter, classic cast-bracket look).
//   * Plate holes teardropped toward +X (they print as horizontal bores;
//     the truncated apex caps the bridge at ~2 mm).
//   * 0.6 mm elephant-foot chamfer around the bed/rail face perimeter,
//     plus countersunk bore rims and a window rim relief on the bed face
//     (first-layer squish must not bind bolts or lift the leg).
//   * Rounded shelf corners and leg edges.
//
//  Frame: origin at the bottom-rear corner of the leg, on the rail face.
//    X = inboard (cantilever) . Y = along the rail (-Y = pull) . Z = up.
//
//  Print with the RAIL FACE on the bed: support-free, and layers stack
//  inboard (X) so the pull (-Y) and the part's weight (-Z) load every layer
//  in-plane. PETG/ASA, >=4 walls, 40-50% infill.
// =====================================================================
include <BOSL2/std.scad>
$fa = 2; $fs = 0.5;

/* [Handbrake base plate - measured with calipers, 4 corner holes] */
bp_len       = 104;    // plate length, along the rail (Y)
bp_wid       = 52;     // plate width, inboard (X)
bp_pitch_len = 86;     // hole c-c along the length
bp_pitch_wid = 35;     // hole c-c along the width
bp_hole_d    = 8.5;    // M8 clearance (bolt + nut underneath)

/* [Shelf] */
plat_margin  = 6;      // material beyond the plate footprint
plat_th      = 8;
shelf_win_x  = 16;     // lightening window
shelf_win_y  = 40;
td_cap       = 0.9;    // teardrop apex truncation above the hole radius

/* [Leg - bolts to the rail inner face] */
leg_th       = 8;
leg_h        = 75;     // shelf height above the rail -> THE tuning knob (flush with the profile top; verified)
leg_win_y    = 40;     // lightening window
leg_win_z    = 37;     // shorter than rev 1: the relocated upper bolts need the room above
leg_win_zc   = 29.5;   // window centre height

/* [Rail bolts - 80 mm face, M8 T-nuts] */
rail_hole_d  = 8.5;
rail_pitch_z = 40;     // = the two T-slot centres at 20/60 on the 80 mm face (verified)
rail_z0      = 20;     // lower bolt row height
rail_low_y   = 88;     // lower-row spread along the rail (wide for yaw stiffness)
rail_top_y   = 26;     // upper-row spread: BETWEEN the gussets, clear of the handbrake bolts
spot_d       = 15;     // spot-face seat for the upper bolt heads (cuts through the fillet)
spot_seat    = 0.6;    // spot-face recess into the leg face

/* [Gussets] */
gusset_th    = 6;
gusset_run   = 52;     // reach along the shelf (X)
gusset_drop  = 56;     // reach down the leg (Z)
gusset_y     = 26;     // centreline offset from Y=0 - inboard of both bolt patterns
gusset_sag   = 11;     // concave free-edge sagitta (0 = straight hypotenuse)
gusset_land  = 3;      // straight lands at both arc ends (avoid feathered tips)

/* [Junction fillet] */
fillet_r     = 5;      // cove along the leg/shelf corner; <= washer keep-out (asserted)

/* [Style] */
win_r        = 6;      // window corner radius
corner_r_in  = 16;     // shelf plan corners, inboard (free) side
corner_r_rail= 3;      // shelf plan corners on the rail side + leg vertical edges
foot_ch      = 0.6;    // elephant-foot chamfer around the bed-face perimeter

/* [Hardware - only used by the clearance asserts] */
washer_od    = 17;     // M8 flat washer
head_d       = 13;     // M8 socket cap head
tnut_len     = 20;     // 40-series M8 slide-in T-nut, length along the slot

// --- derived (mm) ---
function plat_depth() = bp_wid + 2 * plat_margin;   // shelf reach inboard (X)
function plat_width() = bp_len + 2 * plat_margin;   // shelf and leg width (Y)
function shelf_z0()   = leg_h - plat_th;            // shelf underside height
function rail_z1()    = rail_z0 + rail_pitch_z;     // upper bolt row height

lap = 1;  // union overlap / cut over-extension; never rely on coincident faces

// Material between a plate hole (incl. teardrop apex) and the removed pocket of
// the big inboard corner rounding. The nearest pocket point is radial when the
// hole centre sits inside the corner quadrant, else a quadrant-arc endpoint.
function corner_hole_margin() =
    let (
        c  = [plat_depth() - corner_r_in, plat_width() / 2 - corner_r_in],
        h  = [plat_depth() / 2 + bp_pitch_wid / 2, bp_pitch_len / 2],
        re = bp_hole_d / 2 + td_cap,
        e1 = [plat_depth(), c.y],
        e2 = [c.x, plat_width() / 2]
    )
    h.x >= c.x && h.y >= c.y
        ? corner_r_in - norm(h - c) - re
        : min(norm(e1 - h), norm(e2 - h)) - re;

// Clearances; the rev 1 set, retuned for the rev 2 layout - fail loudly on a bad tweak.
assert(plat_depth() / 2 - bp_pitch_wid / 2 - bp_hole_d / 2 >= 10, "plate hole < 10 mm from shelf edge (X)");
assert(plat_width() / 2 - bp_pitch_len / 2 - bp_hole_d / 2 >= 10, "plate hole < 10 mm from shelf edge (Y)");
assert(plat_depth() - (plat_depth() / 2 + bp_pitch_wid / 2 + bp_hole_d / 2 + td_cap) >= 9, "teardrop apex < 9 mm from the shelf front edge");
assert(corner_hole_margin() >= 9, "shelf corner rounding cuts too close to a plate hole");
assert(bp_hole_d / 2 + td_cap <= washer_od / 2 - 2, "teardrop slot escapes the washer seat on the shelf top");
assert(bp_pitch_wid / 2 - bp_hole_d / 2 - td_cap - shelf_win_x / 2 >= 4, "shelf window too close to the plate-hole teardrops");
assert(gusset_y - gusset_th / 2 - shelf_win_y / 2 >= 3, "shelf window too close to the gussets");
assert(bp_pitch_len / 2 - washer_od / 2 - (gusset_y + gusset_th / 2) >= 5, "plate-bolt washer fouls the gussets");
assert(plat_depth() / 2 - bp_pitch_wid / 2 - washer_od / 2 - fillet_r >= 1, "plate-bolt washer lands on the junction fillet");
// THE rev 2 fix: a hex key driven along X into the upper bolts must clear the
// handbrake's corner-bolt hardware hanging below the shelf at y = +/-43.
assert(bp_pitch_len / 2 - washer_od / 2 - (rail_top_y / 2 + head_d / 2) >= 10, "upper rail bolt tool path fouls the handbrake bolts");
assert(gusset_y - gusset_th / 2 - (rail_top_y / 2 + spot_d / 2) >= 2, "upper-bolt spot face fouls the gussets");
assert(rail_top_y - spot_d >= 5, "the two upper spot faces merge");
assert(rail_top_y - tnut_len >= 4, "upper T-nuts butt in the slot");
assert(shelf_z0() - rail_z1() >= head_d / 2, "upper rail-bolt head fouls the shelf underside");
assert(plat_width() / 2 - rail_low_y / 2 - washer_od / 2 >= 5, "lower rail-bolt washer overhangs the leg edge (Y)");
assert(rail_low_y / 2 - washer_od / 2 - (gusset_y + gusset_th / 2) >= 5, "gusset fouls the lower rail bolts");
assert(rail_z0 - washer_od / 2 - foot_ch >= 2, "lower washer rides the foot chamfer");
assert(rail_z1() - spot_d / 2 - (leg_win_zc + leg_win_z / 2) >= 4, "leg window breaches the upper-bolt spot faces");
assert(rail_low_y / 2 - washer_od / 2 - leg_win_y / 2 >= 5, "leg window too close to the lower rail bolts");
assert(gusset_y - gusset_th / 2 - leg_win_y / 2 >= 3, "leg window too close to the gussets");
assert(leg_win_zc - leg_win_z / 2 >= 10, "leg window too close to the foot");
assert(shelf_z0() - gusset_drop >= 8, "gusset extends into the foot region");
assert(gusset_run + lap <= plat_depth(), "gusset top edge overruns the shelf");
assert(gusset_sag >= 0, "negative gusset sagitta");
assert(spot_d >= head_d + 1.5, "spot face too small for the bolt head");
assert(fillet_r <= plat_th, "fillet taller than the shelf is thick");
assert(max(leg_th + plat_depth(), plat_width(), leg_h) <= 256, "exceeds the Bambu A1 bed (256 x 256)");

echo(str("envelope (mm): ", leg_th + plat_depth(), " x ", plat_width(), " x ", leg_h));
echo(str("plate holes: x = ", plat_depth() / 2 - bp_pitch_wid / 2, " / ", plat_depth() / 2 + bp_pitch_wid / 2,
         ", y = +/-", bp_pitch_len / 2));
echo(str("rail bolts: lower y = +/-", rail_low_y / 2, " z = ", rail_z0,
         "; upper y = +/-", rail_top_y / 2, " z = ", rail_z1()));

// Circular arc through p1 -> p2 whose bulge passes through pm; endpoints included.
function arc3(p1, pm, p2, n = 24) =
    let (
        d  = 2 * (p1.x * (pm.y - p2.y) + pm.x * (p2.y - p1.y) + p2.x * (p1.y - pm.y)),
        cx = ((p1.x^2 + p1.y^2) * (pm.y - p2.y) + (pm.x^2 + pm.y^2) * (p2.y - p1.y) + (p2.x^2 + p2.y^2) * (p1.y - pm.y)) / d,
        cy = ((p1.x^2 + p1.y^2) * (p2.x - pm.x) + (pm.x^2 + pm.y^2) * (p1.x - p2.x) + (p2.x^2 + p2.y^2) * (pm.x - p1.x)) / d,
        r  = norm([p1.x - cx, p1.y - cy]),
        a1 = atan2(p1.y - cy, p1.x - cx),
        am = atan2(pm.y - cy, pm.x - cx),
        a2 = atan2(p2.y - cy, p2.x - cx),
        ccw  = posmod(a2 - a1, 360),
        ccwm = posmod(am - a1, 360),
        sweep = ccwm <= ccw ? ccw : ccw - 360
    )
    [for (i = [0:n]) [cx + r * cos(a1 + sweep * i / n), cy + r * sin(a1 + sweep * i / n)]];

// Gusset profile (X-Z): straight edges buried `lap` deep in the leg and shelf;
// the free edge is a concave arc with short straight lands at both tips so the
// part never feathers to a knife edge against the shelf or the leg face.
function gusset_profile() =
    let (
        zt = shelf_z0(),
        p_shelf = [gusset_run, zt - gusset_land],     // arc start, below the shelf tip
        p_leg   = [gusset_land, zt - gusset_drop],    // arc end, inboard of the leg foot
        mid  = (p_shelf + p_leg) / 2,
        v    = p_leg - p_shelf,
        nrm  = unit([v.y, -v.x]),                     // unit normal toward the corner
        bulge = mid + gusset_sag * nrm,
        // a degenerate sagitta would put the three arc points collinear (div/0)
        edge = gusset_sag < 0.01 ? [p_shelf, p_leg] : arc3(p_shelf, bulge, p_leg)
    )
    concat(
        [[-lap, zt + lap], [gusset_run, zt + lap]],
        edge,
        [[-lap, zt - gusset_drop]]
    );

module gusset(yc) {
    translate([0, yc + gusset_th / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = gusset_th)
                polygon(gusset_profile());
}

// Quarter-round cove along the leg/shelf interior corner, buried `lap` deep
// into both faces. Runs the full width minus the rounded leg edges.
module junction_fillet() {
    zt = shelf_z0();
    w  = plat_width() - 2 * corner_r_rail;
    profile = concat(
        [[-lap, zt + lap], [-lap, zt - fillet_r]],
        [for (a = [180:-6:90]) [fillet_r + fillet_r * cos(a), zt - fillet_r + fillet_r * sin(a)]],
        [[fillet_r, zt + lap]]
    );
    translate([0, w / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = w)
                polygon(profile);
}

// M8 clearance bore through the shelf, teardropped toward +X (print-up) with a
// truncated ~2 mm apex flat: prints as a clean horizontal bore, no sag.
module plate_hole(px, py) {
    r = bp_hole_d / 2;
    t = r / sqrt(2);            // 45-degree tangent points
    cap_x = r + td_cap;
    cap_w = r * sqrt(2) - cap_x;
    translate([px, py, shelf_z0() - lap])
        linear_extrude(plat_th + 2 * lap)
            union() {
                circle(d = bp_hole_d);
                polygon([[t, t], [cap_x, cap_w], [cap_x, -cap_w], [t, -t]]);
            }
}

// 45-degree wedge cuts around the bed-face (X = -leg_th) perimeter: elephant-foot
// relief so first-layer squish can't lift the rail face or scratch the flush top.
module bed_chamfer() {
    e = 0.3;
    x0 = -leg_th;
    w2 = plat_width() / 2;
    // The outer wedge vertices extend ALONG the 45-degree chamfer line (through
    // (x0+foot_ch, 0) and (x0, foot_ch)), not normal to it - shifting them off
    // the line would shrink the delivered chamfer by e.
    // bottom (z=0) and top (z=leg_h) edges, running along Y
    for (zs = [[0, 1], [leg_h, -1]]) {
        translate([0, w2 + e, zs[0]])
            rotate([90, 0, 0])
                linear_extrude(plat_width() + 2 * e)
                    polygon([[x0 + foot_ch + e, -zs[1] * e],
                             [x0 - e, zs[1] * (foot_ch + e)],
                             [x0 - e, -zs[1] * e]]);
    }
    // side (y = +/-w2) edges, running up Z
    for (s = [-1, 1])
        translate([0, 0, -e])
            linear_extrude(leg_h + 2 * e)
                polygon([[x0 + foot_ch + e, s * (w2 + e)],
                         [x0 - e, s * (w2 - foot_ch - e)],
                         [x0 - e, s * (w2 + e)]]);
}

module ebrake_bracket() {
    difference() {
        union() {
            // Leg: back face (x = -leg_th) sits flat on the rail; all four
            // vertical edges rounded to match the shelf's rail-side corners.
            cuboid([leg_th, plat_width(), leg_h], anchor = RIGHT + BOTTOM,
                   rounding = corner_r_rail, edges = "Z");
            // Shelf: runs back over the full leg thickness so the union overlaps.
            // Plan profile rounded: big radii on the free corners. The rail-side
            // corners use corner_r_rail+1 so the shelf's arc is buried strictly
            // inside the leg's rounded edge - equal radii would put two
            // tessellated cylinders face-on-face (degenerate slivers); the
            // visible corner is the leg's, continuous over the full height.
            translate([(plat_depth() - leg_th) / 2, 0, shelf_z0()])
                linear_extrude(plat_th)
                    rect([leg_th + plat_depth(), plat_width()],
                         rounding = [corner_r_in, corner_r_rail + 1, corner_r_rail + 1, corner_r_in]);
            for (yc = [-gusset_y, gusset_y]) gusset(yc);
            junction_fillet();
        }

        // Handbrake plate holes, teardropped, down through the shelf.
        for (dx = [-1, 1], dy = [-1, 1])
            plate_hole(plat_depth() / 2 + dx * bp_pitch_wid / 2, dy * bp_pitch_len / 2);

        // Rail-bolt holes through the leg: lower pair wide, upper pair between
        // the gussets (the rev 2 fix - reachable with the handbrake mounted).
        for (dy = [-1, 1], hole = [[rail_low_y, rail_z0], [rail_top_y, rail_z1()]]) {
            translate([-leg_th / 2, dy * hole[0] / 2, hole[1]])
                xcyl(d = rail_hole_d, l = leg_th + 2 * lap);
            // Countersink at the bed face: first-layer squish bulging into the
            // bore would bind the M8 (only 0.25/side nominal) and lift the leg
            // off the rail.
            translate([-leg_th + foot_ch - (foot_ch + lap) / 2, dy * hole[0] / 2, hole[1]])
                xcyl(l = foot_ch + lap, d1 = rail_hole_d + 2 * (foot_ch + lap), d2 = rail_hole_d);
        }
        // Spot faces: flat seats for the upper heads, carved through the fillet
        // and `spot_seat` into the leg face.
        for (dy = [-1, 1])
            translate([(spot_seat + fillet_r + lap) / 2 - spot_seat, dy * rail_top_y / 2, rail_z1()])
                xcyl(d = spot_d, l = spot_seat + fillet_r + lap);

        // Lightening windows: one through the shelf, one through the leg.
        translate([plat_depth() / 2, 0, leg_h - plat_th / 2])
            cuboid([shelf_win_x, shelf_win_y, plat_th + 2 * lap], rounding = win_r, edges = "Z");
        translate([-leg_th / 2, 0, leg_win_zc])
            cuboid([leg_th + 2 * lap, leg_win_y, leg_win_z], rounding = win_r, edges = "X");
        // Window rim relief on the bed face (same first-layer-squish concern as
        // the bores): step the rim back by foot_ch so no lip can hold the leg
        // off the rail.
        translate([-leg_th + (foot_ch - lap) / 2, 0, leg_win_zc])
            cuboid([foot_ch + lap, leg_win_y + 2 * foot_ch, leg_win_z + 2 * foot_ch],
                   rounding = win_r + foot_ch, edges = "X");

        bed_chamfer();
    }
}

ebrake_bracket();
