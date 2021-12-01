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

PART_1_TEST_A_EXPECT : aoc.Result = nil;
PART_1_TEST_B_EXPECT : aoc.Result = 3;
PART_1_TEST_C_EXPECT : aoc.Result = 12;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  rules : = lines(strings.split(input, "\n\n")[0]);
  allLines : = lines(strings.split(input, "\n\n")[1]);

  stat_print :: proc(depth : int, ruleIndex : int, rule : string, str : string, validIndices : ^map[int]int)
  {
    for i in 1..depth
    {
      print("  ");
    }
    println("RULE", ruleIndex, ":", rule);
    for i in 1..depth
    {
      print("  ");
    }
    println("STR:", str);
    for i in 1..depth
    {
      print("  ");
    }
    println("STARTS:", validIndices^);
  }

  validate_rule :: proc(str : string, validIndices : ^map[int]int, rules : []string, ruleIndex : int, depth := 0) -> bool
  {
    rule := rules[ruleIndex];

    // stat_print(depth, ruleIndex, rule, str, validIndices);

    /*
    println(ruleIndex, ":", rule);
    totalGood := 0;
    for charIndex, good in validIndices
    {
      for i in 1..depth
      {
        print("  ");
      }
      totalGood += 1;
      println(good, ":", str[charIndex:], "?");
      if good > 1
      {
        println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      }
    }
    if totalGood > 1
    {
      println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    */

    success : [dynamic]int;

    eachIndex:
    for charIndex in validIndices
    {
      if charIndex in validIndices^ && validIndices[charIndex] > 0
      {
        // println(str[charIndex:], ruleIndex, ":", rule);
        validIndices[charIndex] -= 1;
        if charIndex < len(str)
        {
          if rule[0] == '"'
          {
            if str[charIndex] == rule[1]
            {
              append(&success, charIndex+1);
            }
          }
          else
          {
            orRules := strings.split(rule, " | ");
            defer delete(orRules);
            orTest:
            for orRule in orRules
            {
              validIndicesPrime : map[int]int;
              validIndicesPrime[charIndex] = 1;
              defer delete(validIndicesPrime);
              subRules := strings.split(orRule, " ");
              defer delete(subRules);
              for subRule in subRules
              {
                subIndex := int_val(subRule);
                if !validate_rule(str, &validIndicesPrime, rules, subIndex, depth+1)
                {
                  continue orTest;
                }
              }
              for validPrime, good in validIndicesPrime
              {
                if good > 0
                {
                  append(&success, validPrime);
                }
              }
            }
          }
        }
      }
    }
    for validIndex in success
    {
      if validIndex in validIndices^
      {
        validIndices[validIndex] += 1;
      }
      else
      {
        validIndices[validIndex] = 1;
      }
    }
    return len(success) > 0;
  }

  count := 0;
  for line in allLines
  {
    validIndices : map[int]int;
    validIndices[0] = 1;
    if validate_rule(line, &validIndices, rules, 0)
    {
      if val, ok := validIndices[len(line)]; ok && val > 0
      {
        println("PASS", line);
        count += 1;
      }
      else
      {
        println("INCOMPLETE", line);
      }
    }
    else
    {
      println("FAIL", line);
    }
    println();
  }

  return count; // 226, 181
}
