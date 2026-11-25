#!/usr/bin/env bash
#
# Render the rows of views.tsv to output/figures/<name>.png, cropped to the model. $1 is a glob
# matched against the names; "*" selects all. Rows render as orthographic previews unless a row
# passes --render. A failing render still exits 0, so the script checks stderr for errors and also
# fails if the image is missing.
set -uo pipefail
: "${OPENSCAD:=openscad}"
out=output/figures
mkdir -p "$out"
fail=0
while IFS=$'\t' read -r name view flags; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    # shellcheck disable=SC2053
    [[ "$name" == ${1:-*} ]] || continue
    # shellcheck disable=SC2086
    "$OPENSCAD" --projection=o --viewall --autocenter --camera="0,0,0,$view,0" \
        --imgsize=2400,1800 --colorscheme=Tomorrow ${flags:-} -o "$out/$name.png" reactor.scad \
        2>"$out/$name.err" >/dev/null
    if grep -q '^ERROR' "$out/$name.err" || [ ! -s "$out/$name.png" ]; then
        echo "FAIL  $name  see $out/$name.err"
        rm -f "$out/$name.png"
        fail=1
        continue
    fi
    bg=$(magick "$out/$name.png" -format '%[pixel:p{0,0}]' info:)
    magick "$out/$name.png" -fuzz 2% -trim +repage -bordercolor "$bg" -border 40 "$out/$name.png"
    rm -f "$out/$name.err"
    echo "ok    $name"
done < views.tsv
exit $fail
