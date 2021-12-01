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

PART_2_TEST_A_EXPECT : aoc.Result = "mxmxvkd,sqjhc,fvjkl";
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  Allergen :: enum
  {
    dairy,
    eggs,
    fish,
    nuts,
    sesame,
    shellfish,
    soy,
    wheat,
  };

  Allergens :: bit_set[Allergen];

  data : map[string]Allergens;
  counts : map[string]int;

  allLines := lines(input);

  allAllergens : Allergens;

  for line in allLines
  {
    bits := strings.split(line, " (contains ");
    defer delete(bits);
    for allergen in strings.split(bits[1][:len(bits[1])-1], ", ")
    {
      bit, ok := reflect.enum_from_name(Allergen, allergen);
      if !ok
      {
        no(allergen);
      }
      allAllergens |= {bit};
    }
  }

  for line in allLines
  {
    bits := strings.split(line, " (");
    defer delete(bits);
    for ingredient in strings.split(bits[0], " ")
    {
      if ingredient not_in data
      {
        data[ingredient] = allAllergens;
        counts[ingredient] = 1;
      }
      else
      {
        counts[ingredient] += 1;
      }
    }
  }

  slice_contains :: proc(strs : []string, str : string) -> bool
  {
    for s in strs
    {
      if s == str
      {
        return true;
      }
    }
    return false;
  }

  for line in allLines
  {
    bits := strings.split(line, " (contains ");
    defer delete(bits);
    ingredients := strings.split(bits[0], " ");
    for allergen in strings.split(bits[1][:len(bits[1])-1], ", ")
    {
      bit, ok := reflect.enum_from_name(Allergen, allergen);
      if !ok
      {
        no(allergen);
      }
      for ingredient in data
      {
        if !slice_contains(ingredients, ingredient)
        {
          data[ingredient] &~= {bit};
        }
      }
    }
  }

  count_bits :: proc(s : u8) -> int
  {
    c := s;
    count := 0;
    for c > 0
    {
      count += int(c & 1);
      c = c >> 1;
    }
    return count;
  }

  change := true;
  for change
  {
    change = false;
    for ing, p in data
    {
      // Odin Bug??? 2020-12-21 calling card is causing:
      //             error: invalid redefinition of function 'llvm.ctpop.i8'
      //             So we made a count_bits, LLVM can probably optimize it to ctpop anyway!
      // if card(p) == 1
      if count_bits(transmute(u8)p) == 1
      {
        for q in data
        {
          if p < data[q]
          {
            data[q] &~= p;
            change = true;
          }
        }
      }
    }
  }

  result : strings.Builder = strings.make_builder();
  defer strings.destroy_builder(&result);

  first := true;
  for allergen in Allergen
  {
    for ing, s in data
    {
      if s == {allergen}
      {
        if first
        {
          first = false;
        }
        else
        {
          sbprint(&result, ",");
        }
        sbprint(&result, ing);
      }
    }
  }

  return strings.to_string(result);
}
