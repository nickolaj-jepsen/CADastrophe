// =====================================================================
//  E-brake mount -> GT Omega PRIME Lite (8040 / 80x40 profile) sim rig.
//  Gusseted L-bracket: the leg bolts to the INNER VERTICAL FACE of a
//  fore/aft side rail (M8 T-nuts); the handbrake sits upright on the
//  shelf and pulls straight back (-Y). Symmetric in Y, so not handed.
//
//  Frame: origin at the bottom-rear corner of the leg, on the rail face.
//    X = inboard (cantilever) . Y = along the rail (-Y = pull) . Z = up.
//
//  Print with the RAIL FACE on the bed: support-free, and layers stack
//  inboard (X) so the pull (-Y) and the part's weight (-Z) load every layer
//  in-plane. PETG/ASA, >=4 walls, 40-50% infill. PoC printed and fits.
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

/* [Leg - bolts to the rail inner face] */
leg_th       = 8;
leg_h        = 75;     // shelf height above the rail -> THE tuning knob (shifter clearance)
leg_win_y    = 40;     // lightening window
leg_win_z    = 44;
leg_win_zc   = 36;     // window centre height

/* [Rail bolts - 80 mm face, M8 T-nuts] */
rail_hole_d  = 8.5;
rail_pitch_y = 88;     // spread along the rail (T-nuts slide to suit)
rail_pitch_z = 40;     // = the two T-slot centres at 20/60 on the 80 mm face (verified)
rail_z0      = 20;     // lower bolt row height

/* [Gussets] */
gusset_th    = 6;
gusset_run   = 52;     // reach along the shelf (X)
gusset_drop  = 56;     // reach down the leg (Z)
gusset_y     = 26;     // centreline offset from Y=0 - inboard of both bolt patterns

/* [Style] */
win_r        = 6;      // window corner radius

/* [Hardware - only used by the clearance asserts] */
washer_od    = 17;     // M8 flat washer
head_d       = 13;     // M8 socket cap head

// --- derived (mm) ---
function plat_depth() = bp_wid + 2 * plat_margin;   // shelf reach inboard (X)
function plat_width() = bp_len + 2 * plat_margin;   // shelf and leg width (Y)
function shelf_z0()   = leg_h - plat_th;            // shelf underside height

lap = 1;  // union overlap / cut over-extension; never rely on coincident faces

// Clearances verified on the printed PoC - fail loudly if a tweak breaks one.
assert(plat_depth() / 2 - bp_pitch_wid / 2 - bp_hole_d / 2 >= 10, "plate hole < 10 mm from shelf edge (X)");
assert(plat_width() / 2 - bp_pitch_len / 2 - bp_hole_d / 2 >= 10, "plate hole < 10 mm from shelf edge (Y)");
assert(bp_pitch_wid / 2 - bp_hole_d / 2 - shelf_win_x / 2 >= 5, "shelf window too close to the plate holes");
assert(rail_pitch_y / 2 - rail_hole_d / 2 - (gusset_y + gusset_th / 2) >= 5, "gusset fouls the rail-bolt holes");
assert(rail_pitch_y / 2 - rail_hole_d / 2 - leg_win_y / 2 >= 5, "leg window too close to the rail-bolt holes");
assert(leg_win_zc + leg_win_z / 2 <= shelf_z0() - 2, "leg window breaches the shelf underside");
assert(shelf_z0() - gusset_drop >= 0, "gusset extends below the leg bottom");
assert(bp_pitch_len / 2 - washer_od / 2 - (gusset_y + gusset_th / 2) >= 5, "plate-bolt washer fouls the gussets");
assert(plat_width() / 2 - rail_pitch_y / 2 - washer_od / 2 >= 5, "rail-bolt washer overhangs the leg edge (Y)");
assert(shelf_z0() - (rail_z0 + rail_pitch_z) >= head_d / 2, "upper rail-bolt head fouls the shelf underside");
assert(max(leg_th + plat_depth(), plat_width(), leg_h) <= 256, "exceeds the Bambu A1 bed (256 x 256)");

echo(str("envelope (mm): ", leg_th + plat_depth(), " x ", plat_width(), " x ", leg_h));
echo(str("plate holes: x = ", plat_depth() / 2 - bp_pitch_wid / 2, " / ", plat_depth() / 2 + bp_pitch_wid / 2,
         ", y = +/-", bp_pitch_len / 2));
echo(str("rail bolts: y = +/-", rail_pitch_y / 2, ", z = ", rail_z0, " / ", rail_z0 + rail_pitch_z));

module gusset(yc) {
    zt = shelf_z0();
    // Five-point profile: the exposed hypotenuse is the PoC triangle's, while
    // the straight edges sit `lap` deep inside the leg and shelf solids.
    profile = [
        [-lap,        zt + lap],
        [gusset_run,  zt + lap],
        [gusset_run,  zt],
        [0,           zt - gusset_drop],
        [-lap,        zt - gusset_drop],
    ];
    translate([0, yc + gusset_th / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = gusset_th)
                polygon(profile);
}

module ebrake_bracket() {
    difference() {
        union() {
            // Leg: back face (x = -leg_th) sits flat on the rail.
            cuboid([leg_th, plat_width(), leg_h], anchor = RIGHT + BOTTOM);
            // Shelf: runs back over the full leg thickness so the union overlaps.
            up(leg_h) left(leg_th)
                cuboid([leg_th + plat_depth(), plat_width(), plat_th], anchor = LEFT + TOP);
            for (yc = [-gusset_y, gusset_y]) gusset(yc);
        }

        // Handbrake plate holes, down through the shelf.
        for (dx = [-1, 1], dy = [-1, 1])
            translate([plat_depth() / 2 + dx * bp_pitch_wid / 2, dy * bp_pitch_len / 2, shelf_z0() - lap])
                cyl(d = bp_hole_d, h = plat_th + 2 * lap, anchor = BOTTOM);

        // Rail-bolt holes, through the leg into the T-slots.
        for (dy = [-1, 1], i = [0, 1])
            translate([-leg_th / 2, dy * rail_pitch_y / 2, rail_z0 + i * rail_pitch_z])
                xcyl(d = rail_hole_d, l = leg_th + 2 * lap);

        // Lightening windows: one through the shelf, one through the leg.
        translate([plat_depth() / 2, 0, leg_h - plat_th / 2])
            cuboid([shelf_win_x, shelf_win_y, plat_th + 2 * lap], rounding = win_r, edges = "Z");
        translate([-leg_th / 2, 0, leg_win_zc])
            cuboid([leg_th + 2 * lap, leg_win_y, leg_win_z], rounding = win_r, edges = "X");
    }
}

ebrake_bracket();
