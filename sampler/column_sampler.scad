/**
 * @file column_sampler.scad
 * @brief turbidity-sensor's sampler case on the column lid's centre port
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * The sampler case stands on a std bayonet port of an 18 mm panel, the column lid's plate, with
 * bayonet-port-scad's pin as its foot: turbidity-sensor's bayonet.scad sets that up, so this file
 * only includes it. `use` this file, so the case's globals stay out of the lid's.
 *
 * FRAME: the port's, z = 0 on the panel's top face, +z up out of the column.
 */

include <turbidity-sensor/hardware/sampler-case/bayonet.scad>
piece = "none"; // bayonet.scad's own drawing, off

// The riser's top end, over the panel's top face
function column_sampler_riser_top_z() = sampler_riser_top_z();
// The face the actuator bolts to, over the panel's top face
function column_sampler_face_z() = sampler_face_z();
// The riser's bore, for the line's volume
function column_sampler_riser_id() = riser_id;
function column_sampler_riser_od() = riser_od;

// Both prints in place, the pin as the base's foot, and every bought part but the riser.
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
