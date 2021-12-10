@echo off

pushd "odin"

  pushd "2015/days/day 25"

    vcvarsall amd64 && odin run . -debug

  popd

popd
