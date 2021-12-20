package main;

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"
import "core:os"
import "core:slice"
import "core:reflect"
import "core:math"
import "core:math/linalg"
import "core:time"
import "core:sys/windows"
import "core:sort"
import "core:unicode/utf8"
import "core:thread"

import "../../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_2_TEST_A_EXPECT : aoc.Result = 3621;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: true;
    TIMING :: false;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
  }

  input := get_input(MODE);

  V4 :: [4]int
  Mat4 :: matrix[4,4]int

  Scanner :: struct {
    beacon_readings : [dynamic]V4,
    beacon_offsets : [][]V4,
    transforms : []Mat4,
  }

  inv_mat :: proc(mat : Mat4) -> Mat4 {
    // https://stackoverflow.com/a/7596981
    s0 := mat[0, 0] * mat[1, 1] - mat[1, 0] * mat[0, 1]
    s1 := mat[0, 0] * mat[1, 2] - mat[1, 0] * mat[0, 2]
    s2 := mat[0, 0] * mat[1, 3] - mat[1, 0] * mat[0, 3]
    s3 := mat[0, 1] * mat[1, 2] - mat[1, 1] * mat[0, 2]
    s4 := mat[0, 1] * mat[1, 3] - mat[1, 1] * mat[0, 3]
    s5 := mat[0, 2] * mat[1, 3] - mat[1, 2] * mat[0, 3]

    c5 := mat[2, 2] * mat[3, 3] - mat[3, 2] * mat[2, 3]
    c4 := mat[2, 1] * mat[3, 3] - mat[3, 1] * mat[2, 3]
    c3 := mat[2, 1] * mat[3, 2] - mat[3, 1] * mat[2, 2]
    c2 := mat[2, 0] * mat[3, 3] - mat[3, 0] * mat[2, 3]
    c1 := mat[2, 0] * mat[3, 2] - mat[3, 0] * mat[2, 2]
    c0 := mat[2, 0] * mat[3, 1] - mat[3, 0] * mat[2, 1]

    invdet := 1 / (s0 * c5 - s1 * c4 + s2 * c3 + s3 * c2 - s4 * c1 + s5 * c0)

    result : Mat4 = ---

    result[0, 0] = ( mat[1, 1] * c5 - mat[1, 2] * c4 + mat[1, 3] * c3) * invdet
    result[0, 1] = (-mat[0, 1] * c5 + mat[0, 2] * c4 - mat[0, 3] * c3) * invdet
    result[0, 2] = ( mat[3, 1] * s5 - mat[3, 2] * s4 + mat[3, 3] * s3) * invdet
    result[0, 3] = (-mat[2, 1] * s5 + mat[2, 2] * s4 - mat[2, 3] * s3) * invdet

    result[1, 0] = (-mat[1, 0] * c5 + mat[1, 2] * c2 - mat[1, 3] * c1) * invdet
    result[1, 1] = ( mat[0, 0] * c5 - mat[0, 2] * c2 + mat[0, 3] * c1) * invdet
    result[1, 2] = (-mat[3, 0] * s5 + mat[3, 2] * s2 - mat[3, 3] * s1) * invdet
    result[1, 3] = ( mat[2, 0] * s5 - mat[2, 2] * s2 + mat[2, 3] * s1) * invdet

    result[2, 0] = ( mat[1, 0] * c4 - mat[1, 1] * c2 + mat[1, 3] * c0) * invdet
    result[2, 1] = (-mat[0, 0] * c4 + mat[0, 1] * c2 - mat[0, 3] * c0) * invdet
    result[2, 2] = ( mat[3, 0] * s4 - mat[3, 1] * s2 + mat[3, 3] * s0) * invdet
    result[2, 3] = (-mat[2, 0] * s4 + mat[2, 1] * s2 - mat[2, 3] * s0) * invdet

    result[3, 0] = (-mat[1, 0] * c3 + mat[1, 1] * c1 - mat[1, 2] * c0) * invdet
    result[3, 1] = ( mat[0, 0] * c3 - mat[0, 1] * c1 + mat[0, 2] * c0) * invdet
    result[3, 2] = (-mat[3, 0] * s3 + mat[3, 1] * s1 - mat[3, 2] * s0) * invdet
    result[3, 3] = ( mat[2, 0] * s3 - mat[2, 1] * s1 + mat[2, 2] * s0) * invdet

    return result
  }

  look_mat :: proc(forward, up : [3]int) -> Mat4 {
    right := linalg.cross(up, forward)
    return {
      right.x, up.x, forward.x, 0,
      right.y, up.y, forward.y, 0,
      right.z, up.z, forward.z, 0,
      0,       0,    0,         1,
    }
  }

  @static orientations : [24]Mat4
  orientations[ 0] = look_mat({ 0,  0,  1}, { 0,  1,  0})
  orientations[ 1] = look_mat({ 0,  0,  1}, { 1,  0,  0})
  orientations[ 2] = look_mat({ 0,  0,  1}, { 0, -1,  0})
  orientations[ 3] = look_mat({ 0,  0,  1}, {-1,  0,  0})
  orientations[ 4] = look_mat({ 0,  0, -1}, { 0,  1,  0})
  orientations[ 5] = look_mat({ 0,  0, -1}, { 1,  0,  0})
  orientations[ 6] = look_mat({ 0,  0, -1}, { 0, -1,  0})
  orientations[ 7] = look_mat({ 0,  0, -1}, {-1,  0,  0})
  orientations[ 8] = look_mat({ 1,  0,  0}, { 0,  1,  0})
  orientations[ 9] = look_mat({ 1,  0,  0}, { 0,  0,  1})
  orientations[10] = look_mat({ 1,  0,  0}, { 0, -1,  0})
  orientations[11] = look_mat({ 1,  0,  0}, { 0,  0, -1})
  orientations[12] = look_mat({-1,  0,  0}, { 0,  1,  0})
  orientations[13] = look_mat({-1,  0,  0}, { 0,  0,  1})
  orientations[14] = look_mat({-1,  0,  0}, { 0, -1,  0})
  orientations[15] = look_mat({-1,  0,  0}, { 0,  0, -1})
  orientations[16] = look_mat({ 0,  1,  0}, { 1,  0,  0})
  orientations[17] = look_mat({ 0,  1,  0}, { 0,  0,  1})
  orientations[18] = look_mat({ 0,  1,  0}, {-1,  0,  0})
  orientations[19] = look_mat({ 0,  1,  0}, { 0,  0, -1})
  orientations[20] = look_mat({ 0, -1,  0}, { 1,  0,  0})
  orientations[21] = look_mat({ 0, -1,  0}, { 0,  0,  1})
  orientations[22] = look_mat({ 0, -1,  0}, {-1,  0,  0})
  orientations[23] = look_mat({ 0, -1,  0}, { 0,  0, -1})

  @static scanners : [dynamic]Scanner

  advance := 0
  read_ptr := 0
  ok : bool
  scanner_id : int
  for read_ptr < len(input) {
    if advance, ok = aoc.parse_input(input[read_ptr:], "--- scanner ", &scanner_id, " ---\n"); ok {
      read_ptr += advance
    } else {
      assert(false)
    }
    append(&scanners, Scanner{})
    scanner := &scanners[len(scanners)-1]
    pos : V4
    pos.w = 1
    for ok
    {
      advance, ok = aoc.parse_input(input[read_ptr:], &pos.x, ",", &pos.y, ",", &pos.z, "\n")
      read_ptr += advance
      append(&scanner.beacon_readings, pos)
    }
    read_ptr += 1
  }

  when DEBUG
  {
    println("Scanners:")
    for scanner, idx in scanners
    {
      println(idx, scanner.beacon_readings)
    }
    println()
  }

  for scanner in &scanners
  {
    using scanner
    beacon_offsets = make([][]V4, len(beacon_readings))
    transforms = make([]Mat4, len(scanners))
    for beacon_root, root_idx in beacon_readings
    {
      beacon_offsets[root_idx] = make([]V4, len(beacon_readings))
      for beacon, beacon_idx in beacon_readings
      {
        beacon_offsets[root_idx][beacon_idx] = (beacon - beacon_root)
        beacon_offsets[root_idx][beacon_idx].w = 1
      }
    }
  }

  when DEBUG
  {
    println("Offsets:")
    for scanner, scanner_idx in scanners
    {
      println("Scanner", scanner_idx)
      for beacon_offsets, idx in scanner.beacon_offsets
      {
        println(idx, beacon_offsets)
      }
    }
    println()
  }

  ThreadData :: struct {
    scanner_root_idx, scanner_idx : int,
  }
  threads : [dynamic]^thread.Thread
  thread_data : [1000]ThreadData

  for scanner_root, scanner_root_idx in scanners[:len(scanners)-1]
  {
    for scanner, scanner_idx in scanners[scanner_root_idx+1:]
    {
      thread_data[len(threads)] = ThreadData{ scanner_root_idx, scanner_idx }
      append(&threads, thread.create(proc(t : ^thread.Thread) {
          using data := (cast(^ThreadData)t.user_args[0])^
          scanner_root := &scanners[scanner_root_idx]
          scanner := &scanners[scanner_root_idx+1+scanner_idx]
          for transformation, ti in orientations
          {
            for root_beacon_set, rbi in scanner_root.beacon_offsets
            {
              for beacon_set, bsi in scanner.beacon_offsets
              {
                overlap := 0
                search: for root_beacon in root_beacon_set
                {
                  comp_beacon := V4(transformation * root_beacon)
                  for beacon in beacon_set
                  {
                    if comp_beacon == beacon
                    {
                      overlap += 1
                      if overlap >= 12
                      {
                        break search
                      }
                      continue search
                    }
                  }
                }
                if overlap >= 12
                {
                  println("OVERLAP :: \ts1:", scanner_root_idx, " \ts2:", scanner_idx+scanner_root_idx+1, " \torientation:", ti, " \tb1:", rbi, " \tb2:", bsi)
                  when DEBUG {
                    println(scanner_root_idx, "->", (scanner_root_idx+1+scanner_idx), transformation)
                    println((scanner_root_idx+1+scanner_idx), "->", scanner_root_idx, inv_mat(transformation))
                  }
                  root_to_idx := transformation
                  root_beacon_in_idx_scanner_space := root_to_idx * scanner_root.beacon_readings[rbi]
                  idx_beacon_in_idx_scanner_space := scanner.beacon_readings[bsi]
                  offset_from_root_to_idx_in_idx_scanner_space := idx_beacon_in_idx_scanner_space - root_beacon_in_idx_scanner_space

                  translation := Mat4{
                    1, 0, 0, offset_from_root_to_idx_in_idx_scanner_space.x,
                    0, 1, 0, offset_from_root_to_idx_in_idx_scanner_space.y,
                    0, 0, 1, offset_from_root_to_idx_in_idx_scanner_space.z,
                    0, 0, 0, 1,
                  }

                  root_to_idx = translation * root_to_idx

                  scanner_root.transforms[scanner_root_idx+1+scanner_idx] = root_to_idx
                  scanner.transforms[scanner_root_idx] = inv_mat(root_to_idx)
                  return
                }
              }
            }
          }
        }))
      t := threads[len(threads)-1]
      t.user_args[0] = &thread_data[len(threads)-1]
      thread.start(t)
    }
  }

  thread.join_mulitple(..threads[:])

  scanners[0].transforms[0] = {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1,
  }

  s0_transformerize :: proc(scanner_idx : int, me_to_s0 : Mat4) {
    when DEBUG do println("Transformerizing", scanner_idx)
    for scanner, idx in scanners {
      if scanners[idx].transforms[scanner_idx] != {} && scanners[idx].transforms[0] == {} {
        scanners[idx].transforms[0] = me_to_s0 * scanners[idx].transforms[scanner_idx]
        s0_transformerize(idx, scanners[idx].transforms[0])
      }
    }
  }

  when DEBUG do println()

  for scanner, idx in scanners {
    if scanners[idx].transforms[0] != {} {
      s0_transformerize(idx, scanners[idx].transforms[0])
    }
  }

  when DEBUG {
    println()
    for scanner, idx in scanners {
      for _, s2_idx in scanners {
        if scanner.transforms[s2_idx] != {} {
          println(idx, "->", s2_idx, scanner.transforms[s2_idx])
        }
      }
    }
  }

  max_dist := 0

  for s1 in scanners {
    s1_pos := V4{ s1.transforms[0][0,3], s1.transforms[0][1,3], s1.transforms[0][2,3], 1}
    for s2 in scanners {
      s2_pos := V4{ s2.transforms[0][0,3], s2.transforms[0][1,3], s2.transforms[0][2,3], 1}
      offset := s2_pos - s1_pos
      dist := abs(offset.x) + abs(offset.y) + abs(offset.z)
      max_dist = max(max_dist, dist)
    }
  }

  return max_dist
}
