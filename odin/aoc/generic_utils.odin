package aoc;

import "core:fmt";

no :: proc(val : any, loc := #caller_location)
{
  if val != nil
  {
    fmt.println(ANSI_FG_BRIGHT_RED, "    !!NO!! !!NO!! !!NO!! ", val, " AT ", loc);
  }
  else
  {
    fmt.println(ANSI_FG_BRIGHT_RED, "    !!NO!! !!NO!! !!NO!! AT ", loc);
  }
}