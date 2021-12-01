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

import "../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_2_TEST_A_EXPECT : aoc.Result = 7*1;
PART_2_TEST_B_EXPECT : aoc.Result = 12*11;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  when MODE == .SOLUTION
  {
    targets := []string{ "departure location","departure station","departure platform","departure track","departure date","departure time" };
  }
  else
  {
    targets := []string{ "class","row" };
  }

  input := get_input(MODE);
  allLines := lines(input);

  Rule :: struct {
    name : string,
    minA, maxA : int,
    minB, maxB : int,
  };

  rules : [dynamic]Rule;

  readIndex := 0;
  for line in allLines
  {
    if len(line) > 0
    {
      name := strings.split(line, ": ");
      ab := strings.split(name[1], " or ");
      a := strings.split(ab[0], "-");
      b := strings.split(ab[1], "-");
      append(&rules, Rule{ name[0], int_val(a[0]), int_val(a[1]), int_val(b[0]), int_val(b[1]) });
    }
    else
    {
      break;
    }
    readIndex += 1;
  }

  PossibleFileds :: bit_set[0..19];
  possibleFileds := make([]PossibleFileds, len(rules));
  for v in 0..<len(rules)
  {
    for i in 0..<len(rules)
    {
      possibleFileds[i] |= { v };
    }
  }

  checkLines:
  for line in allLines[readIndex+5:]
  {
    vals := int_arr(strings.split(line, ","));
    validCount := 0;
    checkVals:
    for val in vals
    {
      checkRules:
      for rule in rules
      {
        if (val >= rule.minA && val <= rule.maxA) ||
           (val >= rule.minB && val <= rule.maxB)
        {
          validCount += 1;
          continue checkVals;
        }
      }
    }
    if validCount == len(vals)
    {
      for val, i in vals
      {
        for rule, r in rules
        {
          if (val >= rule.minA && val <= rule.maxA) ||
             (val >= rule.minB && val <= rule.maxB)
          {
          }
          else
          {
            possibleFileds[i] &~= { r };
          }
        }
      }
    }
  }

  hasChange := true;
  for hasChange
  {
    hasChange = false;
    for p, i in possibleFileds
    {
      if card(p) == 1
      {
        for q in 0..<len(possibleFileds)
        {
          if p < possibleFileds[q]
          {
            hasChange = true;
            possibleFileds[q] &~= p;
          }
        }
      }
    }
  }

  targetProduct := 1;

  myTicket := int_arr(strings.split(allLines[readIndex+2], ","));

  eachTarget:
  for target in targets
  {
    for rule, ruleIndex in rules
    {
      if rule.name == target
      {
        for possibility, tickPosition in possibleFileds
        {
          if possibility == { ruleIndex }
          {
            targetProduct *= myTicket[tickPosition];
            continue eachTarget;
          }
        }
      }
    }
  }

  return targetProduct;
}
