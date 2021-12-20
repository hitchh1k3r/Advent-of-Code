package aoc

import "core:fmt"
import "core:reflect"
import "core:intrinsics"
import "core:runtime"
import "core:strconv"
import "core:strings"

printf :: fmt.printf
println :: fmt.println
eprintf :: fmt.eprintf
eprintln :: fmt.eprintln

no :: proc(val : any, loc := #caller_location) {
  if val != nil {
    fmt.println(ANSI_FG_BRIGHT_RED, "    !!NO!! !!NO!! !!NO!! ", val, " AT ", loc)
  } else {
    fmt.println(ANSI_FG_BRIGHT_RED, "    !!NO!! !!NO!! !!NO!! AT ", loc)
  }
}

SmartCapture :: struct {
  call : proc(str : string, user_data : any) -> (length : int, ok : bool),
  user_data : any,
}
RuneCapture :: struct {
  call : proc(c : rune, user_data : any) -> bool,
  user_data : any,
}
SizedCapture :: struct {
  call : proc(str : string, user_data : any) -> bool,
  user_data : any,
}
Boundry :: struct {
  call : proc(str : string, user_data : any) -> (boundry_start : int, boundry_end : int, ok : bool),
  user_data : any,
}

RuneType :: bit_set[enum { REPEAT, OPTIONAL, WHITESPACE, DIGIT, ALPHA, DOT, COMMA }]

ParseArg :: union { ^string, ^rune, ^int, ^uint, ^f32, SmartCapture, RuneCapture, SizedCapture, string, int, RuneType, Boundry }

parse_input :: proc(str : string, args : ..ParseArg) -> (length: int, ok : bool) {
  str := str
  length = 0

  parse_capture :: proc(str : string, args : []ParseArg, arg_idx : ^int) -> (length : int, ok : bool) {
    partial_str := "<smart capture>"
    #partial switch capture in args[arg_idx^] {
      case ^string:
        if arg_idx^+1 >= len(args) {
          capture^ = str
          return len(str), true
        } else {
          if start, end, ok := parse_boundry(str, args[arg_idx^+1]); ok {
            partial_str = str[:start]
            capture^ = str[:start]
            arg_idx^ += 1
            return end, true
          }
        }
      case ^rune:
        if len(str) >= 1 {
          capture^ = rune(str[0])
          return length, true
        }
      case ^int:
        if arg_idx^+1 >= len(args) {
          if result, ok := strconv.parse_int(str); ok
          {
            capture^ = result
            return len(str), true
          }
        } else {
          if start, end, ok := parse_boundry(str, args[arg_idx^+1]); ok {
            partial_str = str[:start]
            if result, ok := strconv.parse_int(str[:start]); ok
            {
              capture^ = result
              arg_idx^ += 1
              return end, true
            }
          }
        }
      case ^uint:
        if arg_idx^+1 >= len(args) {
          if result, ok := strconv.parse_uint(str); ok
          {
            capture^ = result
            return len(str), true
          }
        } else {
          if start, end, ok := parse_boundry(str, args[arg_idx^+1]); ok {
            partial_str = str[:start]
            if result, ok := strconv.parse_uint(str[:start]); ok
            {
              capture^ = result
              arg_idx^ += 1
              return end, true
            }
          }
        }
      case ^f32:
        if arg_idx^+1 >= len(args) {
          if result, ok := strconv.parse_f32(str); ok
          {
            capture^ = result
            return len(str), true
          }
        } else {
          if start, end, ok := parse_boundry(str, args[arg_idx^+1]); ok {
            partial_str = str[:start]
            if result, ok := strconv.parse_f32(str[:start]); ok
            {
              capture^ = result
              arg_idx^ += 1
              return end, true
            }
          }
        }
      case SmartCapture:
        if length, ok := capture.call(str, capture.user_data); ok {
          return length, true
        }
      case RuneCapture:
        if len(str) >= 1 && capture.call(rune(str[0]), capture.user_data) {
          return length, true
        }
      case SizedCapture:
        if arg_idx^+1 >= len(args) {
          if capture.call(str, capture.user_data)
          {
            return len(str), true
          }
        } else {
          if start, end, ok := parse_boundry(str, args[arg_idx^+1]); ok {
            partial_str = str[:start]
            if capture.call(str[:start], capture.user_data)
            {
              arg_idx^ += 1
              return end, true
            }
          }
        }
    }
    // eprintf("Could not capture %v|%v| from string \"%v\" at \"%v\"\n", reflect.union_variant_typeid(args[arg_idx^]), args[arg_idx^], partial_str, str[:min(len(str), 100)])
    return 0, false
  }

  parse_boundry :: proc(str : string, arg : ParseArg) -> (start : int, end : int, ok : bool) {
    #partial switch boundry in arg {
      case string:
        if start := strings.index(str, boundry); start >= 0
        {
          return start, start + len(boundry), true
        }
      case int:
        if len(str) >= boundry
        {
          return 0, boundry, true
        }
      case RuneType:
        start := -1
        end := -1
        for c, i in str
        {
          if .WHITESPACE in boundry && (c == ' ' || c == '\t' || c == '\n') ||
             .DIGIT in boundry      && (c >= '0' && c <= '9') ||
             .ALPHA in boundry      && ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) ||
             .DOT in boundry        && c == '.' ||
             .COMMA in boundry      && c == ','
          {
            if start < 0
            {
              start = i
            }
          }
          else
          {
            if start >= 0
            {
              end = i
              break;
            }
          }

          if .REPEAT not_in boundry && start >= 0
          {
            end = start + 1
            break
          }
        }
        if start >= 0
        {
          if end < 0
          {
            end = len(str)
          }
          return start, end, true
        }
        else if .OPTIONAL in boundry
        {
          return 0, 0, true
        }
      case Boundry:
        if length, end, ok := boundry.call(str, boundry.user_data); ok {
          return start, end, ok
        }
    }
    // eprintf("Could not find boundry %v|%v| from string \"%v\"\n", reflect.union_variant_typeid(arg), arg, str[:min(len(str), 100)])
    return 0, 0, false
  }

  for arg_idx := 0; arg_idx < len(args); arg_idx += 1 {
    switch reflect.union_variant_typeid(args[arg_idx]) {
      // Captures:
      case typeid_of(^string): fallthrough
      case typeid_of(^rune): fallthrough
      case typeid_of(^int): fallthrough
      case typeid_of(^uint): fallthrough
      case typeid_of(^f32): fallthrough
      case typeid_of(SmartCapture): fallthrough
      case typeid_of(RuneCapture): fallthrough
      case typeid_of(SizedCapture):
        if advance, ok := parse_capture(str, args, &arg_idx); ok {
          if len(str) >= advance {
            str = str[advance:]
            length += advance
          } else {
            // eprintf("Capture %v|%v| is misplaced in string \"%v\"\n", reflect.union_variant_typeid(args[arg_idx]), args[arg_idx], str[:min(len(str), 100)])
            return length, false
          }
        } else {
          return length, false
        }

      // Boundries:
      case typeid_of(string): fallthrough
      case typeid_of(int): fallthrough
      case typeid_of(RuneType): fallthrough
      case typeid_of(Boundry):
        if start, end, ok := parse_boundry(str, args[arg_idx]); ok {
          if start == 0 && len(str) >= end {
            str = str[end:]
            length += end
          } else {
            // eprintf("Boundry %v|%v| is misplaced in string \"%v\"\n", reflect.union_variant_typeid(args[arg_idx]), args[arg_idx], str[:min(len(str), 100)])
            return length, false
          }
        } else {
          return length, false
        }
    }
  }
  return length, true
}

any_ptr :: proc(v : any, $E : typeid) -> ^E {
  return cast(^E)v.data
}

capture_enum :: proc(store : ^$ENUM_TYPE) -> SmartCapture {
  return {proc(str : string, user_data : any) -> (int, bool) {
      length := 0
      ok := false
      for t in ENUM_TYPE {
        name := reflect.enum_string(t)
        if len(name) > length {
          if len(str) >= len(name) && str[:len(name)] == name {
            any_ptr(user_data, ENUM_TYPE)^ = t
            length = len(name)
            ok = true
          }
        }
      }
      return length, ok
    }, store^}
}
