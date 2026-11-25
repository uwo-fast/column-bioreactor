# column-bioreactor

An acrylic column bioreactor. The repository models the column as measured, a printed top lid that
replaces the plain acrylic disc, and the assembled reactor with the turbidity-sensor sampler case
mounted on the lid. The lid has the same bayonet ports as the jar reactor in
[open-source-bioreactor](https://github.com/uwo-fast/open-source-bioreactor), so the same
instruments mount on top. The ports come from
[bayonet-port-scad](https://github.com/CameronBrooks11/bayonet-port-scad) and the NPT thread from
threads-scad. Both libraries are pinned with scadman.

```sh
just setup   # install the pinned libraries into .scadman/env
just check   # build every lid to output/<name>.stl in print orientation and run the reactor checks; fails if any build fails
just render  # render the views in views.tsv to output/figures/<name>.png, or only those matching a glob
```

Any change that someone building or using the lid or the reactor would notice (the CAD, its checks,
a recipe or a pinned library) needs a line under `## [Unreleased]` in [CHANGELOG.md](CHANGELOG.md),
in the same pull request. At a release, those lines move under the new version.

`just render` also needs ImageMagick (`magick`) to crop the images.

## The column, as measured

The measurements are from the lab's column U3. `column/column.scad` models the column from them.

|         |                                                                                |
| ------- | ------------------------------------------------------------------------------ |
| flange  | Ø160 mm, 17 mm thick, at the top and as the bottom plate                       |
| bolts   | 8 × Ø10 mm holes, evenly spaced on a Ø139.5 mm circle                          |
| bore    | Ø100 mm along the full length, including the joint and the bottom spool: 7.85 mL/mm |
| tube    | Ø115 mm outside diameter                                                       |
| overall | 670 mm. The floor is 653 mm below the top face of the top flange.              |
| seal    | an o-ring in a groove in the face of the column flange                         |

Not yet modelled: the joint to the bottom spool, the sparger ring and its feed bosses, the drain and
the light bars (#2).

## The lid

The lid is an 8 mm flange that the bolts pass through, above a plain Ø99.6 mm plug, 10 mm long,
that fits into the bore and centres the lid. The column o-ring seals against the underside of the
flange, so the lid needs no groove. The plate is 18 mm thick, the same as the jar lid, because the
bayonet pins are designed for that panel thickness.

| `variant` | features                                                                      |
| --------- | ----------------------------------------------------------------------------- |
| `npt`     | a 1/2 NPT thread through the plate, the same thread as the thermocouple mount |
| `centre`  | one std bayonet port in the centre                                            |
| `ring`    | a std port in the centre and as many around it as fit: 6, on a Ø70.8 mm circle |

**Pocket for a deep headspace.** The column is not always full, and anything hanging from a flat
lid may not reach the culture. `pocket_depth` lowers the port panel by that distance into the bore.
The panel forms the floor of a cup with a wall of thickness `pocket_wall` (5 mm, which gives an
89.6 mm inside diameter). The cup is open at the top so that a hand can reach in to turn the pin.
The default, 0, gives a flat lid. The pocket suits the `centre` lid. On a `ring` lid the ring ports
cannot clear the centre port inside the cup, and the build reports this as an error. `just check`
builds `centre_pocket` at 100 mm, which leaves 30.7 mm around the pin flange for fingers.

**Use on the column:** `centre_pocket` at 100 mm has been printed and is in use on the lab's
column. The 99.6 mm cup fits the 100 mm bore (0.4 mm diametral clearance), and the 10 mm bolt holes
fit as modelled. The flat lids, the NPT thread and the ring have not been printed yet.

The ring is calculated, not chosen. Its radius is the largest that leaves 2 mm of plug around each
hole, and it holds as many ports as fit with 3 mm between flanges. A different bore or interface
changes the result, and the build fails if the ring cannot clear the centre port.

**Printing:** `just check` exports each lid in print orientation (`part = "print"`). The flat lids
print top face down with the plug up, and need no supports. This is why the NPT thread is cut
through the plate without a boss. The pocket lid prints standing on its floor with the cup upward,
and only the flange ledge needs supports. The 18 mm plate covers the 8.1 mm hand-tight and 13.6 mm
made-up engagement of a 1/2 NPT fitting.

**Pins:** the std pins and blanks from open-source-bioreactor (its `just export-parts`) fit these
ports unchanged. Its thermocouple port pin is a 1/2 NPT mount on a std bayonet, so the `centre` lid
can also take a threaded fitting this way. `part = "assembly"` draws the lid with a blank in each
port.

## The reactor

`reactor.scad` sizes the pocket lid to the culture volume and cuts the sampler riser to length.
Its inputs are defaults that can be overridden:

| input              | default | description                                                                    |
| ------------------ | ------- | ------------------------------------------------------------------------------ |
| `culture_ml`       | 4000    | culture volume; run 1 held 4.0 L                                                |
| `headspace`        | 24      | target distance from the culture surface to the underside of the panel, mm; the run 1 value, with no foam reaching the panel |
| `headspace_min`    | 20      | minimum headspace the build accepts, mm                                         |
| `pocket_depth_set` | undef   | undef calculates the pocket depth from the two inputs above; set it to match a lid already printed |
| `riser_l_set`      | undef   | undef cuts the riser so that its open end is at the culture mid-depth; set it to check a riser already cut |
| `inlet_cover_min`  | 40      | minimum culture depth over the open end of the riser, mm                        |
| `top_up_drop`      | 25      | maximum level drop between top-ups, mm; about two days in run 1                 |
| `stroke_past_beam_min` | 1.0 | minimum stroke volume left after the culture that stood in the line has passed the beam, mL |
| `syringe`          | `"5ml-gnr2"` | a setting of the sampler case, so set it with `-D syringe="..."`. Any 5 mL layout from syringe-actuator works; the other sizes do not build in the sampler case yet |

Overriding the pocket depth reduces the headspace. The build fails only when it passes a hard
limit:

- headspace under `headspace_min`
- less than `inlet_cover_min` of culture over the riser end after the level drops by `top_up_drop`
- a riser that reaches the floor
- a stroke that leaves less than `stroke_past_beam_min` past the beam after it has moved the line
  volume

The echo output shows the target values beside the values used, and a cut list for the riser, the
clear FEP tube, the silicone sleeve and the syringe.

```sh
openscad -D pocket_depth_set=100 --export-format echo -o - reactor.scad   # with OPENSCADPATH=.scadman/env
```

For the printed 100 mm lid at 4.0 L, this gives 25.7 mm of headspace and a 315.9 mm riser whose
line holds 2.54 mL. The 5.17 mL stroke of the 5 mL gnr2 leaves 2.63 mL past the beam. The cut list
is the 315.9 mm riser of 4 x 3 mm stainless tube, 44.6 mm of 7.94 x 6.35 mm FEP, and a 16 mm
silicone sleeve. `show` selects what is drawn: the `assembly`, a `section` cut through the sampler,
or the `lid` in print orientation.
