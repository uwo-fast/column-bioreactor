/**
 * @file column.scad
 * @brief The lab's acrylic column U3, as measured: the vessel that holds the culture, closed by the lid
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A clear acrylic tube between a top flange, which the lid bolts to, and a bottom plate. The bore
 * is 100 mm along the full length, including the joint to the bottom spool, so the culture is a
 * single cylinder from the floor up. `use` this file for the functions, or open it alone to draw
 * the body.
 *
 * FRAME: z = 0 is the top face of the top flange, where the lid seats. The column extends down.
 *
 * Measured on U3, 2026-11-22: 670 mm overall from the top flange to the bottom of the bottom plate,
 * with a 17 mm flange at each end. The tube is 115 mm outside diameter. Not yet modelled: the joint to the bottom spool,
 * the sparger ring and its feed bosses, the drain and the light bars (issue #2).
 */

/* [Column - measured] */

// Tube bore, which is also the culture diameter, mm
column_bore = 100;
// Tube outside diameter, mm
column_tube_od = 115;
// Top flange and bottom plate outside diameter, mm
column_flange_od = 160;
// Top flange and bottom plate thickness, mm
column_flange_t = 17;
// Top face of the top flange to the underside of the bottom plate, mm
column_height = 670;
// Bolt circle and holes of the top flange, the same as the lid
column_bolt_circle = 139.5;
column_bolt_count = 8;
column_bolt_hole = 10;

// mL of culture per mm of height in the bore
function column_ml_per_mm() = PI * pow(column_bore / 2, 2) / 1000;
// The inside floor: the top face of the bottom plate
function column_floor_z() = -(column_height - column_flange_t);
// mL the bore holds from the floor up to the top face
function column_capacity_ml() = -column_floor_z() * column_ml_per_mm();
// Height of the culture surface with ml in the column
function column_surface_z(ml) = column_floor_z() + ml / column_ml_per_mm();
// Depth of a culture of volume ml
function column_culture_depth(ml) = ml / column_ml_per_mm();

module column_body() {
  $fn = 128;
  difference() {
    union() {
      translate([0, 0, -column_flange_t]) cylinder(d=column_flange_od, h=column_flange_t);
      translate([0, 0, -column_height + column_flange_t]) cylinder(d=column_tube_od, h=column_height - 2 * column_flange_t);
      translate([0, 0, -column_height]) cylinder(d=column_flange_od, h=column_flange_t);
    }
    translate([0, 0, column_floor_z()]) cylinder(d=column_bore, h=column_height);
    for (i = [0:column_bolt_count - 1])
      rotate([0, 0, i * 360 / column_bolt_count])
        translate([column_bolt_circle / 2, 0, -column_flange_t - 1]) cylinder(d=column_bolt_hole, h=column_flange_t + 2);
  }
}

// A culture of volume ml, as a solid in the bore
module column_culture(ml) {
  translate([0, 0, column_floor_z()]) cylinder(d=column_bore, h=column_culture_depth(ml), $fn=128);
}

color("LightCyan", 0.35) column_body();
