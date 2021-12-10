@echo off

pushd "odin"

  pushd "2021/days/day 10"

    vcvarsall amd64 && odin run . -debug

  popd

popd
