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

PART_2_TEST_A_EXPECT : aoc.Result = nil;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  all_lines := lines(input);

  Scan :: struct
  {
    children, cats, samoyeds, pomeranians, akitas, vizslas, goldfish, trees, cars, perfumes : int,
  };

  sues : [500]Scan;
  for i in 0..<500
  {
    sues[i].children = -1;
    sues[i].cats = -1;
    sues[i].samoyeds = -1;
    sues[i].pomeranians = -1;
    sues[i].akitas = -1;
    sues[i].vizslas = -1;
    sues[i].goldfish = -1;
    sues[i].trees = -1;
    sues[i].cars = -1;
    sues[i].perfumes = -1;
  }

  for line, i in all_lines
  {
    all_words := words(line);
    set_value :: proc(using _ : ^Scan, name : string, amount : int)
    {
      switch name
      {
        case "children:":
          children = amount;
        case "cats:":
          cats = amount;
        case "samoyeds:":
          samoyeds = amount;
        case "pomeranians:":
          pomeranians = amount;
        case "akitas:":
          akitas = amount;
        case "vizslas:":
          vizslas = amount;
        case "goldfish:":
          goldfish = amount;
        case "trees:":
          trees = amount;
        case "cars:":
          cars = amount;
        case "perfumes:":
          perfumes = amount;
      }
    };
    set_value(&sues[i], all_words[2], int_val(all_words[3]));
    set_value(&sues[i], all_words[4], int_val(all_words[5]));
    set_value(&sues[i], all_words[6], int_val(all_words[7]));
  }

  for i in 0..<500
  {
    using sue := sues[i]
    if children > -1 && children != 3
    {
      continue;
    }
    if cats > -1 && cats <= 7
    {
      continue;
    }
    if samoyeds > -1 && samoyeds != 2
    {
      continue;
    }
    if pomeranians > -1 && pomeranians >= 3
    {
      continue;
    }
    if akitas > -1 && akitas != 0
    {
      continue;
    }
    if vizslas > -1 && vizslas != 0
    {
      continue;
    }
    if goldfish > -1 && goldfish >= 5
    {
      continue;
    }
    if trees > -1 && trees <= 3
    {
      continue;
    }
    if cars > -1 && cars != 2
    {
      continue;
    }
    if perfumes > -1 && perfumes != 1
    {
      continue;
    }
    return i+1;
  }

  return nil;
}
