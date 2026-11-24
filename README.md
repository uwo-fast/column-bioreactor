# column-bioreactor

An acrylic column bioreactor: the column as measured, a printed top lid in place of the plain acrylic
disc, and the reactor assembled with turbidity-sensor's sampler case on the lid. The lid carries the
same bayonet ports and instruments as the jar reactor in
[open-source-bioreactor](https://github.com/uwo-fast/open-source-bioreactor) mount on top. The
ports come from [bayonet-port-scad](https://github.com/CameronBrooks11/bayonet-port-scad), and the
NPT thread from threads-scad, both pinned through scadman.

```sh
just setup   # install the pinned libraries into .scadman/env
just check   # every lid to output/<name>.stl, as it prints, and the reactor's checks; fails on any that does not build
just render  # the pictures in views.tsv to output/figures/<name>.png, or those a glob names
```

## The column, as measured

The lab's column U3. `column/column.scad` draws it from these.

|         |                                                                             |
| ------- | --------------------------------------------------------------------------- |
| flange  | Ø160 mm, 17 mm thick, at the top and as the bottom plate                    |
| bolts   | 8 × Ø10 mm holes, evenly spaced on a Ø139.5 mm circle                       |
| bore    | Ø100 mm all the way down, through the joint and the bottom spool: 7.85 mL/mm |
| tube    | Ø115 mm outside                                                             |
| overall | 670 mm; the floor is 653 mm below the top flange's top face                  |
| seal    | an o-ring in a groove in the column flange's own face                       |

Not yet modelled: the joint to the bottom spool, the sparger ring and its feed bosses, the drain and
the light bars (#2).

## The lid

An 8 mm flange the bolts pass, over a plain 10 mm plug, Ø99.6 mm, that drops into the bore and
centres it. The column's o-ring seals on the flange's underside, so the lid needs no groove. The
18 mm plate is the jar lid's, because the bayonet pins are cut for that panel.

| `variant` | carries                                                                     |
| --------- | --------------------------------------------------------------------------- |
| `npt`     | a 1/2 NPT thread through the plate, the thermocouple mount's thread         |
| `centre`  | one std bayonet port in the middle                                          |
| `ring`    | a std port in the middle and as many round it as fit: 6, on a Ø70.8 mm ring |

**A pocket for a deep headspace.** A column is not always full, and what hangs from a flat lid
may not reach the culture. `pocket_depth` sinks the ports' panel that far down the bore, as the
floor of a cup with a `pocket_wall` wall (5 mm, so 89.6 mm inside), open at the top so a hand
reaches in to turn the pin. 0, the default, is the flat lid. It suits the `centre` lid: a ring
cannot clear its middle port inside the cup, and the build says so. `just check` builds
`centre_pocket` at 100 mm, with 30.7 mm round the pin's flange for the fingers.

**On the column:** `centre_pocket` at 100 mm has been printed and is in use on the lab's column.
Its 99.6 mm cup in the 100 mm bore (0.4 mm diametral clearance) and the 10 mm bolt holes fit as
modelled. The flat lids, the NPT thread and the ring have not been printed yet.

The ring is derived, not chosen. It sits as far out as the plug leaves 2 mm round each hole, and
takes as many ports as keep 3 mm between flanges. A different bore or interface recomputes it, and
a ring that cannot clear the middle port fails the build.

**Printing:** `just check` writes each lid turned as it prints (`part = "print"`). The flat
lids lie top face on the bed, plug up, with no supports; that is why the NPT is cut through the
plate without a boss. The pocket lid stands on its floor, the cup rising, and only the flange's
ledge needs supports. 18 mm of plate holds a 1/2 NPT
fitting's 8.1 mm hand-tight and 13.6 mm made-up engagement.

**Pins:** open-source-bioreactor's std pins and blanks fit these ports unchanged (its `just export-parts`).
Its thermocouple port pin is a 1/2 NPT mount on a std bayonet, so the `centre` lid takes a
threaded fitting that way too. `part = "assembly"` draws the lid with a blank in each port.

## The reactor

`reactor.scad` sizes the pocket lid to the culture and cuts the sampler's riser to it. Its inputs
are defaults to override:

| input              | default | what it is                                                                     |
| ------------------ | ------- | ------------------------------------------------------------------------------ |
| `culture_ml`       | 4000    | the culture held; run 1 held 4.0 L                                              |
| `headspace`        | 24      | wanted from the surface to the panel's underside, mm; run 1's, with no foam on the panel |
| `headspace_min`    | 20      | the least the build accepts, mm                                                 |
| `pocket_depth_set` | undef   | undef works the pocket out from the two above; set it to a lid already printed  |
| `riser_l_set`      | undef   | undef cuts the riser to end open at the culture's mid-depth; set it to check one already cut |
| `inlet_cover_min`  | 40      | the least culture over the riser's open end, mm                                 |
| `top_up_drop`      | 25      | how far the level may fall between top-ups, mm; about two days in run 1         |
| `stroke_past_beam_min` | 1.0 | the least of a stroke left once the culture that stood in the line has passed the beam, mL |
| `syringe`          | `"5ml-gnr2"` | the sampler case's own setting, so set it with `-D syringe="..."`: any 5 mL layout of syringe-actuator; the other sizes do not build in the sampler case yet |

Overriding the pocket eats into the headspace, and the build fails only past a hard limit:
headspace under `headspace_min`, less than `inlet_cover_min` over the riser's end once the level has
dropped by `top_up_drop`, a riser that reaches the floor, or a stroke that leaves less than
`stroke_past_beam_min` past the beam once it has moved the line's volume. The echo gives what was
wanted beside what was used, and a cut list: the riser, the clear FEP tube, the silicone sleeve and
the syringe.

```sh
openscad -D pocket_depth_set=100 --export-format echo -o - reactor.scad   # with OPENSCADPATH=.scadman/env
```

On the printed 100 mm lid at 4.0 L, that gives 25.7 mm of headspace and a 315.9 mm riser, whose line
holds 2.54 mL; the 5 mL gnr2's 5.17 mL stroke leaves 2.63 mL past the beam. The cut list: the
315.9 mm riser of 4 x 3 mm stainless, 44.6 mm of 7.94 x 6.35 mm FEP, and a 16 mm silicone sleeve.
`show` draws the `assembly`, a `section` cut through the sampler, or the `lid` as it prints.
