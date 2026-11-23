#!/usr/bin/env bash
#
# Build every column lid to output/<name>.stl, turned as it prints, and fail on any that does not.
# This is the repository's check as well as its export.
#
# A failing render still exits 0, so stderr is the signal: an ERROR, or a WARNING, which is where
# OpenSCAD says a solid is not a 2-manifold; and a file that is not there or is empty. Only CGAL
# prints that warning, so a build that offers a backend is pinned to it, as check-mesh does.
set -uo pipefail
: "${OPENSCAD:=openscad}"
: "${OUT:=output}"
src=lid/column_lid.scad
mkdir -p "$OUT"
backend=""
help=$("$OPENSCAD" --help 2>&1)
case "$help" in *--backend*) backend="--backend=CGAL" ;; esac

# One lid: its name, then the settings that make it.
build() {
    local name=$1
    shift
    "$OPENSCAD" $backend "$@" -D 'part="print"' -o "$OUT/$name.stl" "$src" 2>"$OUT/$name.err" >/dev/null
}
build npt -D 'variant="npt"' &
build centre -D 'variant="centre"' &
build ring -D 'variant="ring"' &
build centre_pocket -D 'variant="centre"' -D pocket_depth=100 &
wait

failed=0
for name in npt centre ring centre_pocket; do
    if grep -qE '^(ERROR|WARNING)' "$OUT/$name.err"; then
        echo "FAIL  $name  $(grep -m1 -E '^(ERROR|WARNING)' "$OUT/$name.err")"
        failed=1
    elif [ ! -s "$OUT/$name.stl" ]; then
        echo "FAIL  $name  wrote no STL; see $OUT/$name.err"
        failed=1
    else
        echo "ok    $name  $OUT/$name.stl  $(sed -n 's/^ECHO: "column lid: [a-z]*; //p' "$OUT/$name.err" | sed 's/"$//; s/.*mm holes on [0-9.]* mm; //')"
        rm -f "$OUT/$name.err"
    fi
done

# The reactor: the pocket and riser it works out, and the same on the 100 mm lid already printed.
# Its asserts are the check; an echo export writes them into the file, not to stderr.
reactor() {
    local name=$1
    shift
    "$OPENSCAD" "$@" --export-format echo -o "$OUT/$name.echo" reactor.scad 2>/dev/null
    if [ ! -s "$OUT/$name.echo" ] || grep -qE '^(ERROR|WARNING)' "$OUT/$name.echo"; then
        echo "FAIL  $name  $(grep -m1 -E '^(ERROR|WARNING)' "$OUT/$name.echo" | cut -c1-200)"
        failed=1
    else
        echo "ok    $name  $(sed -n 's/^ECHO: "reactor: //p' "$OUT/$name.echo" | sed 's/"$//')"
        echo "      $(sed -n 's/^ECHO: "\(cut list: .*\)"$/\1/p' "$OUT/$name.echo")"
    fi
}
reactor reactor
reactor reactor_on_100 -D pocket_depth_set=100
exit $failed
