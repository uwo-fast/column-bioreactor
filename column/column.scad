/**
 * @file column.scad
 * @brief The lab's acrylic column, U3, as measured: the vessel the lid closes and the culture fills
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * A clear acrylic tube between a top flange, which the lid bolts to, and a bottom plate. The bore
 * runs 100 mm all the way down, through the joint to the bottom spool, so the culture fills it as
 * one cylinder from the floor up. `use` this file for the functions; open it alone to draw the body.
 *
 * FRAME: z = 0 is the top flange's top face, where the lid seats; the column runs down from it.
 *
 * Measured on U3, 2026-11-22: 670 mm overall, top flange to the bottom of the bottom plate, with a
 * 17 mm flange at each end; tube 115 mm outside. Not yet modelled: the joint to the bottom spool,
 * the sparger ring and its feed bosses, the drain and the light bars (issue #2).
 */

/* [Column - measured] */

// The tube's bore, the culture's diameter, mm
column_bore = 100;
// The tube's outside diameter, mm
column_tube_od = 115;
// Top flange and bottom plate outside diameter, mm
column_flange_od = 160;
// Top flange and bottom plate thickness, mm
column_flange_t = 17;
// Top flange's top face to the bottom plate's underside, mm
column_height = 670;
// The top flange's bolt circle and holes, as the lid's
column_bolt_circle = 139.5;
column_bolt_count = 8;
column_bolt_hole = 10;

// mL of culture per mm of height in the bore
function column_ml_per_mm() = PI * pow(column_bore / 2, 2) / 1000;
// The inside floor, the bottom plate's top face
function column_floor_z() = -(column_height - column_flange_t);
// mL the bore holds from the floor up to the top face
function column_capacity_ml() = -column_floor_z() * column_ml_per_mm();
// Where the culture's surface stands with ml in the column
function column_surface_z(ml) = column_floor_z() + ml / column_ml_per_mm();
// How deep a culture of ml stands
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

// The culture, ml of it, as a solid in the bore
module column_culture(ml) {
  translate([0, 0, column_floor_z()]) cylinder(d=column_bore, h=column_culture_depth(ml), $fn=128);
}

color("LightCyan", 0.35) column_body();
