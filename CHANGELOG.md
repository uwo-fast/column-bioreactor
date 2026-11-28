# Changelog

All notable changes to this project are documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- A printed top lid for the acrylic column (`lid/column_lid.scad`), adapted from
  open-source-bioreactor. It has an 8 mm flange over a Ø99.6 mm plug, 10 mm long, that centres it
  in the bore. The total plate is the jar lid's 18 mm, so the std pins and blanks from
  open-source-bioreactor fit its ports unchanged
- Three lid variants: `npt`, with a 1/2 NPT thread through the plate; `centre`, with one std
  bayonet port; and `ring`, with a std port in the centre and as many around it as fit, calculated
  from the bore
- `pocket_depth`, which lowers the port panel into the bore as the floor of an open cup, for a deep
  headspace. The 100 mm `centre_pocket` lid has been printed and is in use on the lab's column
- `part = "print"`, which draws each lid in print orientation, and `part = "assembly"`, which draws
  the lid with a blank in each port
- The column as measured (`column/column.scad`): a 100 mm bore along the full length, a 115 mm
  tube, 17 mm flanges, 670 mm overall, and the floor 653 mm below the top face
- The turbidity-sensor sampler case (v0.4.0), mounted on the centre port of the lid
  (`sampler/column_sampler.scad`)
- `reactor.scad`, which calculates the pocket depth from the culture volume and the target
  headspace, and cuts the sampler riser so that it ends at the culture mid-depth. Either value can
  be set instead. The build fails when it passes a hard limit: headspace under `headspace_min`,
  less than `inlet_cover_min` over the riser end after a `top_up_drop`, a riser that reaches the
  floor, or a stroke that leaves less than `stroke_past_beam_min` past the beam after it has moved
  the line volume. The echo output shows the target values beside the values used, and a cut list.
  `show` draws the assembled reactor, a half section with the cut face of each part in its own
  colour, or the lid in print orientation
- `just setup`, which installs the libraries pinned by scadman (bayonet-port-scad, threads-scad and
  turbidity-sensor), and `just check`, which builds each variant and `centre_pocket` to
  `output/<name>.stl` in print orientation and runs the reactor checks, using only those libraries.
  CI runs it on the OpenSCAD 2026.10.15 snapshot
- `just render`, which renders the views listed in `views.tsv` as PNGs in `output/figures/`, or
  only those matching a glob: the reactor in half section from the front, and the lid in print
  orientation
- The GPL-3.0-or-later licence

### Changed

- turbidity-sensor is pinned at v0.5.0, which also brings in syringe-actuator v0.1.2. The lids, the
  reactor checks and both cut lists are the same as on v0.4.0
- turbidity-sensor is pinned at v0.6.0, which can draw the sampler foot's o-rings and the riser.
  syringe-actuator stays at v0.1.2. The lids, the reactor checks and both cut lists are the same
  as on v0.5.0
