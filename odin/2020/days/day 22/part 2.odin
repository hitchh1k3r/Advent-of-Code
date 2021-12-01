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

PART_2_TEST_A_EXPECT : aoc.Result = 291;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  players := groups(input);

  Deck :: struct
  {
    cards : [50]int,
    count : int,
  };

  player1 : Deck;
  player2 : Deck;
  p1Index := 0;
  p2Index := 0;

  clone_deck :: proc(deck : ^Deck, count : int) -> Deck
  {
    result : Deck;
    result.count = count;
    for i in 0..<count
    {
      result.cards[i] = deck.cards[i];
    }
    return result;
  }

  add_card :: proc(using deck : ^Deck, card : int)
  {
    cards[count] = card;
    count += 1;
  }

  take_card :: proc(using deck : ^Deck) -> int
  {
    result := cards[0];
    count -= 1;
    for i in 0..<count
    {
      cards[i] = cards[i+1];
    }
    return result;
  }

  for line in lines(players[0])
  {
    val := int_val(line);
    if val > 0
    {
      add_card(&player1, val);
    }
  }
  for line in lines(players[1])
  {
    val := int_val(line);
    if val > 0
    {
      add_card(&player2, val);
    }
  }

  round_hash :: proc(player1, player2 : ^Deck) -> u128
  {
    hash : u128;
    shift : u32;
    for i in 0..<player1.count
    {
      hash |= u128(player1.cards[i]) << shift;
      shift += 4;
    }
    shift += 4;
    for i in 0..<player2.count
    {
      hash |= u128(player2.cards[i]) << shift;
      shift += 4;
    }
    return hash;
  }

  game :: proc(player1, player2 : ^Deck, winnerCache : ^map[u128]int) -> int
  {
    @static gameCount := 0;
    gameCount += 1;
    // printf("GAME %v\n", gameCount);
    pastTurns : [dynamic]u128;
    defer delete(pastTurns);
    startHash := round_hash(player1, player2);
    if startHash in winnerCache^
    {
      return winnerCache[startHash];
    }
    winner := 0;
    for winner == 0
    {
      hash := round_hash(player1, player2);
      if (slice.contains(pastTurns[:], hash))
      {
        winner = 1;
        break;
      }
      append(&pastTurns, hash);

      roudWinner := 0;
      p1 := take_card(player1);
      p2 := take_card(player2);
      // println(p1, "vs", p2);

      if p1 <= player1.count && p2 <= player2.count
      {
        rec1 := clone_deck(player1, p1);
        rec2 := clone_deck(player2, p2);
        roudWinner = game(&rec1, &rec2, winnerCache);
      }
      else if p1 > p2
      {
        roudWinner = 1;
      }
      else
      {
        roudWinner = 2;
      }

      if roudWinner == 1
      {
        add_card(player1, p1);
        add_card(player1, p2);
      }
      else
      {
        add_card(player2, p2);
        add_card(player2, p1);
      }

      if player1.count == 0
      {
        winner = 2;
        break;
      }

      if player2.count == 0
      {
        winner = 1;
        break;
      }
    }
    // printf("WINNER %v is %v\n", gameCount, winner);
    winnerCache[startHash] = winner;
    return winner;
  }

  winnerCache : map[u128]int;

  game(&player1, &player2, &winnerCache);

  score : int = 0;
  mult : int = 1;

  for i in 0..<player1.count
  {
    score += (player1.count-i)*player1.cards[i];
  }
  for i in 0..<player2.count
  {
    score += (player2.count-i)*player2.cards[i];
  }

  return int(score);
}
