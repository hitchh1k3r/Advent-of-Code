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
PART_2_TEST_B_EXPECT : aoc.Result = 61229;
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
  all_lines := lines(input);

  segments :: bit_set['a'..'g'];

  word_to_set :: proc(str : string) -> segments
  {
    result : segments;
    for c in str
    {
      result += { c };
    }
    return result;
  }

  sum_num := 0;
  for line, i in all_lines
  {
    blobs := strings.split(line, " | ");

    encoding : [10]segments;

    all_crypt := words(blobs[0]);
    crypt : [10]segments;
    adg : segments;
    for c, i in all_crypt
    {
      crypt[i] = word_to_set(c);
      if card(crypt[i]) == 2
      {
        encoding[1] = crypt[i];
      }
      else if card(crypt[i]) == 3
      {
        encoding[7] = crypt[i];
      }
      else if card(crypt[i]) == 4
      {
        encoding[4] = crypt[i];
      }
      else if card(crypt[i]) == 5
      {
        if adg == {}
        {
          adg = crypt[i];
        }
        else
        {
          adg &= crypt[i];
        }
      }
      else if card(crypt[i]) == 7
      {
        encoding[8] = crypt[i];
      }
    }

    a, b, d, e : segments;

    a = encoding[7]-encoding[1];
    b = (encoding[4]-encoding[1])-adg;
    d = (encoding[4]-encoding[1])-b;
    e = (encoding[8]-encoding[4]-adg);

    for cry in crypt
    {
      if card(cry) == 5 && (cry & b) == b && (cry & e) == {}
      {
        encoding[5] = cry;
      }
      else if card(cry) == 5 && (cry & b) == {} && (cry & e) == e
      {
        encoding[2] = cry;
      }
      else if card(cry) == 5 && (cry & b) == {} && (cry & e) == {}
      {
        encoding[3] = cry;
      }
      else if card(cry) == 6 && (cry & d) == d && (cry & e) == e
      {
        encoding[6] = cry;
      }
      else if card(cry) == 6 && (cry & d) == {} && (cry & e) == e
      {
        encoding[0] = cry;
      }
      else if card(cry) == 6 && (cry & d) == d && (cry & e) == {}
      {
        encoding[9] = cry;
      }
    }

    num := 0;
    all_words := words(blobs[1]);
    for word, i in all_words
    {
      digit := 0;
      switch word_to_set(word)
      {
        case encoding[0]:
          digit = 0;
        case encoding[1]:
          digit = 1;
        case encoding[2]:
          digit = 2;
        case encoding[3]:
          digit = 3;
        case encoding[4]:
          digit = 4;
        case encoding[5]:
          digit = 5;
        case encoding[6]:
          digit = 6;
        case encoding[7]:
          digit = 7;
        case encoding[8]:
          digit = 8;
        case encoding[9]:
          digit = 9;
      }
      order := 1;
      for q in 0..<(len(all_words)-i)-1
      {
        order *= 10;
      }
      num += digit * order;
    }
    when DEBUG
    {
      // println(blobs[0]);
      for e, i in encoding
      {
        // println(" ",i,e);
      }
      println(blobs[1], num);
    }
    sum_num += num;
  }

  return sum_num;
}
