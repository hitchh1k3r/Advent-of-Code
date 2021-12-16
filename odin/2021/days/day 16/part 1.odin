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

PART_1_TEST_A_EXPECT : aoc.Result = 31;
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

  read_packet :: proc(stream : ^DataStream, version_sum : ^int)
  {
    version := read_bits(stream, 3);
    version_sum^ += int(version);
    type_id := read_bits(stream, 3);
    switch type_id
    {
      case 4: // LITERAL
        read := u64(1)
        for read > 0
        {
          read = read_bits(stream, 1)
          block := read_bits(stream, 4)
        }
      case: // OPERATORS
        if read_bits(stream, 1) == 0
        {
          sub_length := int(read_bits(stream, 15));
          stash_byte_index, stash_bit_pos := stream.byte_index, stream.bit_pos;
          read_bits(stream, sub_length)
          target_byte_index, target_bit_pos := stream.byte_index, stream.bit_pos;
          stream.byte_index, stream.bit_pos = stash_byte_index, stash_bit_pos;

          for (stream.byte_index*8+stream.bit_pos) != (target_byte_index*8+target_bit_pos)
          {
            read_packet(stream, version_sum)
          }
        }
        else
        {
          sub_packets := int(read_bits(stream, 11));
          for i in 1..sub_packets
          {
            read_packet(stream, version_sum);
          }
        }
    }
  }

  version_sum := 0;
  read_packet(&data_stream, &version_sum);
  return version_sum;
}
