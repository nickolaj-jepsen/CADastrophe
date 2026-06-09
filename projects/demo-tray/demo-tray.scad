include <BOSL2/std.scad>
$fa = 2; $fs = 0.4;   // curve resolution: Manifold makes fine curves cheap

// --- parameters (mm) ---
width      = 60;
depth      = 40;
height     = 18;
wall       = 2;
fillet     = 4;
hole_d     = 4;    // corner mounting-hole diameter
hole_inset = 6;    // hole centre, inset from each edge

// --- derived ---
function inner_fillet() = max(fillet - wall, 0.5);

module demo_tray() {
    // The outer shell is the parent; the removed features are its children
    // (note: no semicolon after cuboid — the { } block holds its children).
    diff()
        cuboid([width, depth, height], rounding = fillet, edges = "Z") {
            // Hollow it out from the top, leaving a `wall`-thick floor and walls.
            position(TOP) up(0.01)                   // +0.01 avoids a coincident top face
                tag("remove")
                cuboid([width - 2 * wall, depth - 2 * wall, height - wall],
                       rounding = inner_fillet(), edges = "Z", anchor = TOP);

            // Four mounting holes straight through the floor (over-cut both ends).
            for (sx = [-1, 1], sy = [-1, 1])
                position(BOTTOM)
                    translate([sx * (width / 2 - hole_inset),
                               sy * (depth / 2 - hole_inset), -0.2])
                    tag("remove")
                    cyl(d = hole_d, h = wall + 0.4, anchor = BOTTOM);
        }
}

demo_tray();
