#!/usr/bin/env bash
#
# Build every column lid to output/<name>.stl in print orientation, and fail if any build fails.
# This is both the repository check and its export.
#
# A failing render still exits 0, so the script checks stderr for an ERROR or a WARNING (OpenSCAD
# reports a solid that is not 2-manifold as a WARNING), and checks for a missing or empty file.
# Only CGAL prints that warning, so when OpenSCAD offers a backend option the build pins CGAL, as
# check-mesh does.
set -uo pipefail
: "${OPENSCAD:=openscad}"
: "${OUT:=output}"
src=lid/column_lid.scad
mkdir -p "$OUT"
backend=""
help=$("$OPENSCAD" --help 2>&1)
case "$help" in *--backend*) backend="--backend=CGAL" ;; esac

# Build one lid: its name, then the settings for it.
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

# The reactor checks: the derived pocket and riser, and the same for the printed 100 mm lid.
# The asserts are the check. An echo export writes them to the file, not to stderr.
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
