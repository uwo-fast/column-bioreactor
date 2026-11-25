/**
 * @file column_sampler.scad
 * @brief The turbidity-sensor sampler case on the centre port of the column lid
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The sampler case stands on a std bayonet port in an 18 mm panel (the column lid plate), with the
 * bayonet-port-scad pin as its foot. bayonet.scad in turbidity-sensor sets this up, so this file
 * only includes it. `use` this file so that the case globals stay separate from the lid globals.
 *
 * FRAME: the port frame, with z = 0 on the top face of the panel and +z up out of the column.
 */

include <turbidity-sensor/hardware/sampler-case/bayonet.scad>
piece = "none"; // turn off the drawing in bayonet.scad

// Top end of the riser, above the top face of the panel
function column_sampler_riser_top_z() = sampler_riser_top_z();
// Face the actuator bolts to, above the top face of the panel
function column_sampler_face_z() = sampler_face_z();
// Riser tube
function column_sampler_riser_id() = riser_id;
function column_sampler_riser_od() = riser_od;
// The rest of the line, as defined by the sampler case: the clear FEP tube cut length and size, the
// silicone sleeve over the top of the riser, the syringe, one stroke, and the line volume from the
// open end of a riser of length l to past the beam. The syringe is set in the sampler case:
// -D syringe="..."
function column_sampler_fep_cut() = sampler_clear_tube_cut();
function column_sampler_fep_od() = tube_od;
function column_sampler_fep_id() = tube_id;
function column_sampler_sleeve_l() = sampler_sleeve_l();
function column_sampler_syringe_name() = get(sampler_syringe(), "name");
function column_sampler_stroke_ml() = sampler_stroke_ml();
function column_sampler_line_ml(l) = sampler_line_ml(l);

// Both printed parts in place, with the pin as the foot of the base, and every bought part except
// the riser.
module column_sampler() {
  $fn = 64;
  color("DimGray") sampler_base() foot();
  color("DimGray") sampler_top();
  sampler_bought();
}

// The riser, length l, hanging from its top end
module column_sampler_riser(l) {
  color("Silver") translate([0, 0, sampler_riser_top_z() - l]) difference() {
    cylinder(d=riser_od, h=l, $fn=24);
    translate([0, 0, -1]) cylinder(d=riser_id, h=l + 2, $fn=24);
  }
}
