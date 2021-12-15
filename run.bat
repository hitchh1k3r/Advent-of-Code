@echo off

pushd "odin"

  rem pushd "build_submit"
  pushd "2021/days/day 15"

    vcvarsall amd64 && odin run . -debug

  popd

popd
