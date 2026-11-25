/**
 * @file column_lid.scad
 * @brief A printed top lid for the lab's acrylic column reactors, with the bayonet ports from
 *        open-source-bioreactor
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * It uses the bayonet port and NPT mount libraries without modifying them. `just check` builds
 * every variant (scripts/build-lids.sh), and reactor.scad includes this file to draw the lid at the
 * depth the culture requires.
 *
 * The column is a clear acrylic tube with a radially bolted flange at each end. The column flange
 * has the o-ring in a groove in its face, so this lid seals by clamping against it. The lid is a
 * flat flange that the bolts pass through, with a plain plug below it that fits into the bore and
 * centres the lid, as the jar lid plug does in the jar mouth. The plate is 18 mm thick like the
 * jar lid (an 8 mm flange and a 10 mm plug), because the bayonet pins are designed for that panel.
 * This way the printed pins and blanks from open-source-bioreactor fit these ports unchanged.
 *
 * The column is not always full, and with a deep headspace anything hanging from a flat lid does
 * not reach the culture. pocket_depth lowers the port panel by that distance into the bore, as the
 * floor of a cup with a wall of thickness pocket_wall. The cup is open at the top so that a hand
 * can reach in to turn the pin. 0 gives a flat lid.
 *
 * FRAME: z = 0 is the top face of the lid, where the bolt heads sit. The flange and the plug extend
 * down from it, the plug into the column bore. The top face of the port panel is at
 * z = -pocket_depth, which is the top face of the lid itself on a flat lid.
 */

include <bayonet-port-scad/custom/bayonet_interfaces.scad>;
use <bayonet-port-scad/custom/bayonet_port.scad>;
include <bayonet-port-scad/utils/npt_threads.scad>;
use <threads-scad/threads.scad>;

/* [Variant] */

// Lid features, all centred: a 1/2 NPT thread, one std bayonet port, or a ring of std ports around one
variant = "ring"; // [npt, centre, ring]
// The lid as mounted on the column, with a blank pin in each port, or in print orientation
part = "lid"; // [lid, assembly, print, none]

/* [Column - measured] */

// Flange outer diameter, mm
flange_od = 160;
// Bolt circle diameter, measured centre to centre, mm
bolt_circle = 139.5;
// Bolt holes, evenly spaced
bolt_count = 8;
// Bolt hole diameter, mm
bolt_hole = 10;
// Tube bore that the plug fits into, mm
tube_id = 100;

/* [Lid] */

// Flange thickness, the part of the plate the bolts pass through, mm
flange_thickness = 8;
// Depth of the plug in the bore, mm
plug_height = 10;
// Diametral clearance of the plug in the bore, the same as the jar lid, mm
plug_allowance = 0.4;
// Plastic left between a port hole and the edge of the plug, mm
port_wall = 2;
// Gap between the flanges of neighbouring ports, mm
port_gap = 3;
// Depth of the port panel (the cup floor) below the top face, into the bore; 0 is a flat lid, mm
pocket_depth = 0;
// Cup wall thickness, when there is a cup, mm
pocket_wall = 5;

/* [Hidden] */

$fn = $preview ? 64 : 128;
eps = 0.01;

port = bayonet_std;
npt = npt_thread_by_name("1/2 NPT");

plate = flange_thickness + plug_height; // the panel thickness the bayonet pins are designed for
plug_r = (tube_id - plug_allowance) / 2;
hole_r = bayonet_port_hole_radius(port);
flange_r = bayonet_flange_radius(port);

pocketed = pocket_depth > 0;
pocket_r = plug_r - pocket_wall; // inside radius of the cup
floor_z = -pocket_depth; // top face of the port panel

// The ring: placed as far out as the plug allows a hole, with as many ports as fit around it with
// port_gap between flanges. It must clear the flange of the centre port by the same gap. In a cup,
// the pin flanges sit on the floor, so they must also stay port_gap inside the cup wall.
ring_r = pocketed
  ? min(pocket_r - port_wall - hole_r, pocket_r - port_gap - flange_r)
  : plug_r - port_wall - hole_r;
ring_n = floor(180 / asin((flange_r + port_gap / 2) / ring_r));

// Position of each port, [x, y]; the first is the centre port.
ports =
  variant == "npt" ? []
  : variant == "centre" ? [[0, 0]]
  : concat([[0, 0]], [for (i = [0:ring_n - 1]) ring_r * [cos(i * 360 / ring_n), sin(i * 360 / ring_n)]]);

// The 1/2 NPT thread is cut straight through the plate with no boss, so the top stays flat and
// every variant prints the same way, top face on the bed. The thread matches the thermocouple
// mount (the ScrewHole call and values in npt_thread_mount()) and, like it, is straight, not
// tapered. The 18 mm plate covers the 8.1 mm hand-tight and 13.6 mm made-up engagement of a
// 1/2 NPT fitting (ASME B1.20.1 L1 and L2).
npt_allowance = 0.6; // the same as the mount

assert(
  variant == "npt" || variant == "centre" || variant == "ring",
  str("column_lid: no variant \"", variant, "\"; npt, centre or ring")
);
assert(
  bolt_circle / 2 + bolt_hole / 2 < flange_od / 2,
  str("column_lid: the bolt holes reach r ", bolt_circle / 2 + bolt_hole / 2, ", past the flange's ", flange_od / 2)
);
assert(
  bolt_circle / 2 - bolt_hole / 2 > plug_r,
  str("column_lid: the bolt holes come in to r ", bolt_circle / 2 - bolt_hole / 2, ", over the plug's ", plug_r)
);
assert(
  variant != "ring" || ring_r >= 2 * flange_r + port_gap,
  str(
    "column_lid: a ring at r ", ring_r, " leaves ", ring_r - 2 * flange_r,
    " mm between its flanges and the middle port's, under the ", port_gap, " wanted"
  )
);
assert(variant != "ring" || ring_n >= 1, "column_lid: no port fits on the ring");
assert(pocket_depth >= 0, str("column_lid: pocket_depth is how far down, not up; got ", pocket_depth));
assert(
  !pocketed || len(ports) == 0 || flange_r + port_gap <= pocket_r,
  str("column_lid: a pin's ", flange_r * 2, " mm flange does not sit in a ", pocket_r * 2, " mm cup")
);
assert(
  npt_thread_major_diameter(npt) / 2 < (pocketed ? pocket_r : plug_r) - port_wall,
  str("column_lid: the NPT thread, r ", npt_thread_major_diameter(npt) / 2, ", does not fit in the plug")
);

echo(str(
  "column lid: ", variant, "; ", flange_od, " mm across, ", bolt_count, " x ", bolt_hole, " mm holes on ",
  bolt_circle, " mm; a ", flange_thickness, " mm flange over a ",
  pocketed
    ? str(
      "cup of ", plug_r * 2, " mm in the ", tube_id, " mm bore, ", pocket_r * 2, " mm inside, its ", plate,
      " mm floor ", pocket_depth, " mm below the top face, ", pocket_r - flange_r,
      " mm round a pin's flange for the fingers; "
    )
    : str(plug_height, " mm plug of ", plug_r * 2, " mm in the ", tube_id, " mm bore; "),
  variant == "npt"
    ? str("a 1/2 NPT thread through the ", plate, " mm plate")
    : variant == "centre"
      ? "one std bayonet port in the middle"
      : str(
        ring_n, " std ports on a ", ring_r * 2, " mm ring and one in the middle, ",
        2 * ring_r * sin(180 / ring_n) - 2 * flange_r, " mm between ring flanges and ",
        ring_r - 2 * flange_r, " mm to the middle one"
      )
));

// The flange with the plug below it. On a pocketed lid the plug is a cup, hollow down to the floor.
module column_lid_blank() {
  difference() {
    union() {
      translate([0, 0, -flange_thickness])
        cylinder(d=flange_od, h=flange_thickness);
      translate([0, 0, floor_z - plate])
        cylinder(r=plug_r, h=plate - flange_thickness - floor_z + eps);
    }
    if (pocketed)
      translate([0, 0, floor_z])
        cylinder(r=pocket_r, h=pocket_depth + eps);
  }
}

module column_lid() {
  difference() {
    if (variant == "npt")
      ScrewHole(
        outer_diam=npt_thread_major_diameter(npt) - npt_allowance,
        height=plate * 1.1,
        position=[0, 0, floor_z - plate - plate * 0.05],
        rotation=[0, 0, 0],
        pitch=npt_thread_pitch(npt),
        tooth_angle=60,
        tolerance=0.4,
        tooth_height=npt_thread_pitch(npt) * 0.55
      ) column_lid_blank();
    else
      column_lid_blank();
    for (i = [0:bolt_count - 1])
      rotate([0, 0, i * 360 / bolt_count])
        translate([bolt_circle / 2, 0, -plate])
          cylinder(d=bolt_hole, h=plate * 3, center=true);
    for (p = ports)
      translate([p[0], p[1], floor_z - plate / 2])
        cylinder(r=hole_r, h=plate + 2 * eps, center=true);
  }

  // The lock half of the coupling in each hole, as on the jar lid, printed as one piece.
  for (p = ports)
    translate([p[0], p[1], floor_z])
      bayonet_port(type=port, part="lock", panel_thickness=plate);
}

// Print orientation. A flat lid prints on its top face with the plug up and needs no supports. A
// pocketed lid prints on its floor with the cup upward, and only the flange ledge is supported.
if (part == "none") {
} else if (part == "print")
  if (pocketed)
    translate([0, 0, plate - floor_z])
      column_lid();
  else
    rotate([180, 0, 0])
      column_lid();
else
  color("SlateBlue")
    column_lid();

if (part == "assembly")
  for (p = ports)
    color("DarkSlateGray")
      translate([p[0], p[1], floor_z])
        bayonet_port(type=port, part="pin", panel_thickness=plate, text_labels=true, label="BLANK");
