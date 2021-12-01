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
import "core:container"

import "../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_1_TEST_A_EXPECT : aoc.Result = 306;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt, container;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  players := groups(input);

  /*
  player1 : Queue(int) = ---;
  player2 : Queue(int) = ---;
  queue_init(&player1, 0, 10000);
  queue_init(&player2, 0, 10000);

  for line in lines(players[0])
  {
    val := int_val(line);
    println(line, val, queue_len(player1));
    if val > 0
    {
      queue_push_front(&player1, int(val));
    }
  }
  for line in lines(players[1])
  {
    val := int_val(line);
    println(line, val, queue_len(player2));
    if val > 0
    {
      queue_push_front(&player2, int(val));
    }
  }

  for queue_len(player1) > 0 && queue_len(player2) > 0
  {
    p1 := queue_pop_back(&player1);
    p2 := queue_pop_back(&player2);
    if p1 > p2
    {
      queue_push_front(&player1, p1);
      queue_push_front(&player1, p2);
    }
    else
    {
      queue_push_front(&player2, p2);
      queue_push_front(&player2, p1);
    }
    println("PLAYER 1");
    for i in 0..<queue_len(player1)
    {
      println(queue_get(player1, i));
    }
    println("PLAYER 2");
    for i in 0..<queue_len(player2)
    {
      println(queue_get(player2, i));
    }
  }

  winner : ^Queue(int);

  if queue_len(player1) > 0
  {
    winner = &player1;
  }
  else
  {
    winner = &player2;
  }

  score : int = 0;
  mult : int = 1;

  for queue_len(winner^) > 0
  {
    val := queue_pop_back(winner);
    println(val);
    score += mult * val;
    mult += 1;
  }
  */

  player1 : [10000]int;
  player2 : [10000]int;
  p1Index := 0;
  p2Index := 0;

  for line in lines(players[0])
  {
    val := int_val(line);
    if val > 0
    {
      player1[p1Index] = val;
      p1Index += 1;
    }
  }
  for line in lines(players[1])
  {
    val := int_val(line);
    if val > 0
    {
      player2[p2Index] = val;
      p2Index += 1;
    }
  }

  for p1Index > 0 && p2Index > 0
  {
    p1 := player1[0];
    p2 := player2[0];
    p1Index -= 1;
    for i in 0..<p1Index
    {
      player1[i] = player1[i+1];
    }
    p2Index -= 1;
    for i in 0..<p2Index
    {
      player2[i] = player2[i+1];
    }
    if p1 > p2
    {
      player1[p1Index] = p1;
      p1Index += 1;
      player1[p1Index] = p2;
      p1Index += 1;
    }
    else
    {
      player2[p2Index] = p2;
      p2Index += 1;
      player2[p2Index] = p1;
      p2Index += 1;
    }
  }

  score : int = 0;
  mult : int = 1;

  for i in 0..<p1Index
  {
    score += (p1Index-i)*player1[i];
  }
  for i in 0..<p2Index
  {
    score += (p2Index-i)*player2[i];
  }

  return int(score); // 36768
}
