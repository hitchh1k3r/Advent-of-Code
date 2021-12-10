package main;

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"
import "core:os"
import "core:slice"
import "core:reflect"
import "core:math"
import "core:time"
import "core:sys/windows"
import "core:sort"
import "core:unicode/utf8"

import "../../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_1_TEST_A_EXPECT : aoc.Result = 99;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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
  all_lines := lines(input);
  package_weights := int_arr(all_lines);

  total_weight := sum(package_weights);

  PackageSet :: bit_set[0..<29];

  has_solution :: proc(remainder : int, used_packages : PackageSet, weights : []int, index : int) -> bool
  {
    used_packages := used_packages;
    remainder := remainder;
    if index not_in used_packages
    {
      used_packages += { index };
      remainder -= weights[index];
      if remainder == 0
      {
        when DEBUG do println("Solution:", used_packages);
        return true;
      }
    }

    if remainder > 0
    {
      for i in index+1..<len(weights)
      {
        if has_solution(remainder, used_packages, weights, i)
        {
          return true;
        }
      }
    }

    return false;
  }

  find_sums :: proc(entanglement : ^map[PackageSet]int, solution_weight : int, remainder : int, current_set : PackageSet, weights : []int, index : int)
  {
    current_set := current_set;
    current_set += { index };
    remainder := remainder - weights[index];
    if remainder == 0
    {
      // if has_solution(solution_weight, current_set, weights, 0)
      {
        qe := 1;
        for i in 0..<len(weights)
        {
          if i in current_set
          {
            qe *= weights[i];
          }
        }
        when DEBUG do println("QE:", qe, current_set);
        entanglement[current_set] = qe;
      }
      return;
    }

    if remainder > 0
    {
      for i in index+1..<len(weights)
      {
        find_sums(entanglement, solution_weight, remainder, current_set, weights, i);
      }
    }
  }

  entanglement : map[PackageSet]int;
  for i in 0..<len(package_weights)
  {
    find_sums(&entanglement, total_weight/3, total_weight/3, {}, package_weights[:], i);
  }

  min_count := max(int);
  min_qe := max(int);
  for packages, qe in entanglement
  {
    count := card(packages);
    if count < min_count
    {
      min_count = count;
      min_qe = qe;
    }
    else if count == min_count
    {
      min_qe = min(min_qe, qe);
    }
  }

  return min_qe;
}
