# OpenSCAD is whichever is first on PATH unless OPENSCAD names one.
export OPENSCAD := env("OPENSCAD", "openscad")
# The pinned libraries only, whatever OPENSCADPATH the shell carries.
export OPENSCADPATH := justfile_directory() + "/.scadman/env"

# List the recipes.
default:
    @just --list

# Install the pinned libraries into .scadman/env.
setup:
    scadman sync

# Build every lid to output/<name>.stl, turned as it prints, and fail on any that does not build.
check:
    @scripts/build-lids.sh
