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
PART_2_TEST_B_EXPECT : aoc.Result = 9;
PART_2_TEST_C_EXPECT : aoc.Result = 1;

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

  DataStream :: struct {
    raw : []u8,
    byte_index : int,
    bit_pos : int,
  }

  data_stream := DataStream{ make([]u8, len(input)/2), 0, 0 };

  for i in 0..<len(data_stream.raw)
  {
    num, _ := strconv.parse_uint(input[(2*i):2*(i+1)], 16);
    data_stream.raw[i] = u8(num);
  }

  read_bits :: proc(using stream : ^DataStream, bits_to_read : int) -> u64
  {
    result : u64;
    bits_to_read := bits_to_read;

    for i in 1..bits_to_read
    {
      bit := (u64(raw[byte_index]) >> uint(7-bit_pos)) & 0b1;
      result |= bit << uint(bits_to_read-i);
      bit_pos += 1;
      if bit_pos >= 8
      {
        bit_pos = 0;
        byte_index += 1;
      }
    }

    return result;
  }

  peek_bit :: proc(using stream : ^DataStream) -> u64
  {
    result : u64;

    return u64(raw[byte_index] >> uint(7-bit_pos)) & 0b1;;
  }

  read_packet :: proc(stream : ^DataStream, depth : int) -> int
  {
    version := read_bits(stream, 3);
    type_id := read_bits(stream, 3);
    switch type_id
    {
      case 4: // LITERAL
        read := u64(1)
        num := 0;
        for read > 0
        {
          read = read_bits(stream, 1);
          num <<= 4;
          num |= int(read_bits(stream, 4));
        }
        when DEBUG
        {
          for i in 1..depth
          {
            print("  ");
          }
          println("LITERAL", num);
        }
        return num;
      case: // OPERATORS
        sub_values : [dynamic]int;
        if read_bits(stream, 1) == 0
        {
          sub_length := int(read_bits(stream, 15));
          stash_byte_index, stash_bit_pos := stream.byte_index, stream.bit_pos;
          read_bits(stream, sub_length)
          target_byte_index, target_bit_pos := stream.byte_index, stream.bit_pos;
          stream.byte_index, stream.bit_pos = stash_byte_index, stash_bit_pos;

          for (stream.byte_index*8+stream.bit_pos) != (target_byte_index*8+target_bit_pos)
          {
            append(&sub_values, read_packet(stream, depth+1));
          }
        }
        else
        {
          sub_packets := int(read_bits(stream, 11));
          for i in 1..sub_packets
          {
            append(&sub_values, read_packet(stream, depth+1));
          }
          assert(len(sub_values) > 0);
        }
        when DEBUG
        {
          for i in 1..depth
          {
            print("  ");
          }
        }
        switch type_id
        {
          case 0: // SUM
            num := 0;
            for v in sub_values
            {
              num += v;
            }
            when DEBUG do println("SUM", sub_values, num);
            return num;
          case 1: // PROD
            num := 1;
            for v in sub_values
            {
              num *= v;
            }
            when DEBUG do println("PROD", sub_values, num);
            return num;
          case 2: // MIN
            num := max(int);
            for v in sub_values
            {
              num = min(num, v);
            }
            if len(sub_values) == 0
            {
              num = 0;
            }
            when DEBUG do println("MIN", sub_values, num);
            return num;
          case 3: // MAX
            num := min(int);
            for v in sub_values
            {
              num = max(num, v);
            }
            if len(sub_values) == 0
            {
              num = 0;
            }
            when DEBUG do println("MAX", sub_values, num);
            return num;
          case 5: // GREATER
            if sub_values[0] > sub_values[1]
            {
              when DEBUG do println("GREATER", sub_values, "1");
              return 1;
            }
            else
            {
              when DEBUG do println("GREATER", sub_values, "0");
              return 0;
            }
          case 6: // LESS
            if sub_values[0] < sub_values[1]
            {
              when DEBUG do println("LESS", sub_values, "1");
              return 1;
            }
            else
            {
              when DEBUG do println("LESS", sub_values, "0");
              return 0;
            }
          case 7: // EQUAL
            if sub_values[0] == sub_values[1]
            {
              when DEBUG do println("EQUAL", sub_values, "1");
              return 1;
            }
            else
            {
              when DEBUG do println("EQUAL", sub_values, "0");
              return 0;
            }
        }
    }

    assert(false);
    return 0;
  }

  return read_packet(&data_stream, 0);
}
