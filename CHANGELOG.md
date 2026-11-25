# Changelog

All notable changes to this project are documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- The printed top lid for the acrylic column (`lid/column_lid.scad`), from open-source-bioreactor:
  an 8 mm flange over a 10 mm, Ø99.6 mm plug that centres it in the bore, the jar lid's 18 mm
  plate in all, so open-source-bioreactor's std pins and blanks fit its ports unchanged
- Three lid variants: `npt`, a 1/2 NPT thread through the plate; `centre`, one std bayonet port;
  and `ring`, a std port in the middle with as many round it as fit, derived from the bore
- `pocket_depth`, which sinks the ports' panel down the bore as the floor of an open cup for a deep
  headspace; the 100 mm `centre_pocket` lid is printed and in use on the lab's column
- `part = "print"`, each lid turned as it prints, and `part = "assembly"`, the lid with a blank
  in each port
- The column as measured (`column/column.scad`): a 100 mm bore all the way down, a 115 mm tube,
  17 mm flanges, 670 mm overall, the floor 653 mm below the top face
- turbidity-sensor's sampler case (v0.4.0) standing on the lid's centre port
  (`sampler/column_sampler.scad`)
- `reactor.scad`, which works out the pocket depth from the culture held and the headspace wanted,
  and cuts the sampler's riser to end at the culture's mid-depth; either can be set instead. The
  build fails past a hard limit: headspace under `headspace_min`, less than `inlet_cover_min`
  over the riser's end after a `top_up_drop`, a riser that reaches the floor, or a stroke that
  leaves less than `stroke_past_beam_min` past the beam once it has moved the line's volume. The
  echo gives what was wanted beside what was used, and a cut list. `show` draws the reactor
  assembled, cut in half with each part's cut face in its own colour, or the lid as it prints
- `just setup`, which installs the libraries scadman pins (bayonet-port-scad, threads-scad and
  turbidity-sensor), and `just check`, which builds each variant and `centre_pocket` to
  `output/<name>.stl`, as they print, and runs the reactor's checks, on those libraries alone;
  CI runs it on the OpenSCAD 2026.10.15 snapshot
- `just render`, pictures of the views `views.tsv` lists as PNGs in `output/figures/`, or those a
  glob names: the reactor cut in half from the front, and the lid as it prints
- The GPL-3.0-or-later licence
