/**
 * @file reactor.scad
 * @brief The assembled column reactor: the column, the pocket lid sized to the culture, and the
 *        turbidity sampler on the centre port of the lid, with its riser cut to suit the culture
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The culture volume and the target headspace set how far the lid panel sits down the bore. The
 * panel depth and the culture set the riser length. Each is a default that can be overridden:
 *
 * - culture_ml: the culture volume, which top-ups maintain.
 * - headspace: target distance from the culture surface to the underside of the panel, for foam.
 * - pocket_depth: undef (the default) calculates it from the two inputs above. Set it to build for
 *   a lid already printed; the headspace is then whatever that depth leaves.
 * - riser_l: undef cuts the riser so that its open end is at the culture mid-depth. Set it to
 *   check a riser already cut.
 *
 * Only the hard limits stop the build: headspace under headspace_min, less than inlet_cover_min of
 * culture over the riser inlet after the level drops by top_up_drop, a riser that reaches the
 * floor, or a stroke that leaves less than stroke_past_beam_min past the beam after it has moved
 * the line volume. The echo shows the target values beside the values used.
 *
 * FRAME: the column.scad frame, with z = 0 on the top face of the top flange, which is also the top
 * face of the lid.
 */

use <column/column.scad>
use <sampler/column_sampler.scad>

/* [Culture] */

// Culture volume, mL, maintained by top-ups. Run 1 held 4.0 L, and run 2 starts at that volume
culture_ml = 4000;
// Maximum level drop between top-ups, mm. Run 1 lost about 0.5 mm per hour, about 25 over two days
top_up_drop = 25;

/* [Headspace and lid] */

// Target distance from the culture surface to the underside of the panel, mm. Run 1 had about
// 24 mm, with no foam or splash reaching the panel
headspace = 24;
// Minimum headspace the build accepts, mm
headspace_min = 20;
// Depth of the panel below the top face of the lid, mm; undef calculates it from culture and headspace
pocket_depth_set = undef;

/* [Riser] */

// Riser length, mm; undef cuts it so that its open end is at the culture mid-depth
riser_l_set = undef;
// Minimum culture depth over the open end of the riser after the level drops by top_up_drop, mm
inlet_cover_min = 40;
// Minimum stroke volume left after the culture that stood in the line has passed the beam, mL. The
// syringe is set in the sampler case: -D syringe="5ml-gnr2" (the default) or another 5 mL layout
stroke_past_beam_min = 1.0;

/* [Output] */

// The assembled reactor, a half section showing the culture and the riser, or the pocket lid at
// this depth in print orientation
show = "assembly"; // [assembly, section, lid]

/* [Hidden] */

// Lid plate thickness (the bayonet panel): 8 mm flange plus 10 mm plug, as plate in column_lid.scad
lid_plate = 18;

surface_z = column_surface_z(culture_ml);
depth = column_culture_depth(culture_ml);
pocket_wanted = -(surface_z + headspace) - lid_plate;
pocket = is_undef(pocket_depth_set) ? pocket_wanted : pocket_depth_set;
panel_z = -pocket;                              // top face of the panel
headspace_used = (panel_z - lid_plate) - surface_z;
riser_top_z = panel_z + column_sampler_riser_top_z();
inlet_wanted_z = column_floor_z() + depth / 2;
riser_l = is_undef(riser_l_set) ? riser_top_z - inlet_wanted_z : riser_l_set;
inlet_z = riser_top_z - riser_l;
cover_low = (surface_z - top_up_drop) - inlet_z;
stroke_ml = column_sampler_stroke_ml();
line_ml = column_sampler_line_ml(riser_l);
// Largest culture volume that still leaves headspace_min under the lid
culture_max_ml = (panel_z - lid_plate - headspace_min - column_floor_z()) * column_ml_per_mm();

assert(culture_ml > 0 && culture_ml < column_capacity_ml(),
       str("reactor: ", culture_ml, " mL does not fit the column's ", column_capacity_ml(), " mL"));
assert(pocket >= 0, str("reactor: a ", headspace, " mm headspace over ", culture_ml,
                        " mL puts the panel above the lid's top face; a flat lid leaves ", -lid_plate - surface_z));
assert(headspace_used >= headspace_min,
       str("reactor: a ", pocket, " mm pocket leaves ", headspace_used, " mm over ", culture_ml,
           " mL, under the ", headspace_min, " mm minimum; the most it allows is ", culture_max_ml, " mL"));
assert(cover_low >= inlet_cover_min,
       str("reactor: the riser's open end has ", cover_low, " mm of culture over it once the level drops ",
           top_up_drop, " mm, under the ", inlet_cover_min, " mm minimum"));
assert(inlet_z > column_floor_z(), str("reactor: a ", riser_l, " mm riser reaches the floor"));
assert(stroke_ml - line_ml >= stroke_past_beam_min,
       str("reactor: a ", stroke_ml, " mL stroke of the ", column_sampler_syringe_name(), " leaves ", stroke_ml - line_ml,
           " mL past the beam after the ", line_ml, " mL in a ", riser_l, " mm riser's line, under the ",
           stroke_past_beam_min, " mL minimum"));

echo(str(
  "reactor: ", culture_ml, " mL stands ", depth, " mm deep, its surface ", -surface_z, " mm below the top face; ",
  "pocket ", pocket, is_undef(pocket_depth_set) ? " (derived)" : str(" (set; derived ", pocket_wanted, ")"),
  ", headspace ", headspace_used, " (wanted ", headspace, ", min ", headspace_min, "), the lid holds up to ",
  culture_max_ml, " mL; riser ", riser_l, is_undef(riser_l_set) ? " (cut to mid-depth)" : " (set)",
  ", its open end ", inlet_z - column_floor_z(), " mm off the floor and ", surface_z - inlet_z,
  " mm under the surface, ", cover_low, " mm at the low level; stroke ", stroke_ml, " mL, line ", line_ml,
  " mL, ", stroke_ml - line_ml, " mL past the beam (min ", stroke_past_beam_min, ")"
));
echo(str(
  "cut list: riser ", riser_l, " mm of ", column_sampler_riser_od(), " x ", column_sampler_riser_id(),
  " mm stainless tube; clear FEP tube ", column_sampler_fep_cut(), " mm of ", column_sampler_fep_od(), " x ",
  column_sampler_fep_id(), " mm; silicone sleeve ", column_sampler_sleeve_l(), " mm over the riser's top; ",
  column_sampler_syringe_name(), ", with a luer-to-barb fitting into the FEP's top end"
));

// The lid at this depth, with one port in the centre. It is included here, after every value its
// overrides read, with part = "none" so that it draws nothing itself. It draws from its own globals.
include <lid/column_lid.scad>
part = "none";
variant = "centre";
pocket_depth = pocket;

assert(plate == lid_plate, str("reactor: the lid's plate is ", plate, " mm, not the ", lid_plate, " assumed"));

// In the section, removes the near half along the sampler plane and draws each cut face in colour c
module half(c) difference() {
  children();
  if (show == "section") color(c) translate([-300, -600, column_floor_z() - 100]) cube([600, 600, -column_floor_z() + 600]);
}

module reactor() {
  half("LightCyan") color("LightCyan", 0.3) column_body();
  half("YellowGreen") color("YellowGreen", 0.5) column_culture(culture_ml);
  half("SlateBlue") color("SlateBlue") column_lid();
  half("Gainsboro") translate([0, 0, panel_z]) {
    column_sampler();
    column_sampler_riser(riser_l);
  }
}

if (show == "assembly" || show == "section") {
  reactor();
} else if (show == "lid") {
  // in the print orientation column_lid.scad uses for a pocketed lid: on its floor, cup upward
  translate([0, 0, plate + pocket]) column_lid();
}
