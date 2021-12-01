package aoc;

import "core:os"
import "core:fmt";
import "core:strings";
import "core:sys/windows"

LogicMode :: enum { SOLUTION, TEST_A, TEST_B, TEST_C };

Result :: union { string, int }; // TODO (hitch) 2020-12-11 Add more types (maybe bool)? Then make
                                 //       the print results smarter about typeid comparing.

LogicCallback :: #type proc() -> Result;

PT_GET_INPUT :: PerformanceSampleId{ 0, "get_input" };
PT_TEST_A    :: PerformanceSampleId{ 1, "Test A" };
PT_TEST_B    :: PerformanceSampleId{ 2, "Test B" };
PT_TEST_C    :: PerformanceSampleId{ 3, "Test C" };
PT_SOLUTION  :: PerformanceSampleId{ 4, "Solution" };

get_input :: proc($MODE : LogicMode, loc := #caller_location) -> string
{
  using strings;

  PERF(PT_GET_INPUT);

  when MODE == .SOLUTION
  {
    bytes, _ := os.read_entire_file("input.txt");
    input, _ := replace_all(string(bytes), "\r", "");
  }
  when MODE == .TEST_A
  {
    bytes, _ := os.read_entire_file("test_a.txt");
    input, _ := replace_all(string(bytes), "\r", "");
  }
  when MODE == .TEST_B
  {
    bytes, _ := os.read_entire_file("test_b.txt");
    input, _ := replace_all(string(bytes), "\r", "");
  }
  when MODE == .TEST_C
  {
    bytes, _ := os.read_entire_file("test_c.txt");
    input, _ := replace_all(string(bytes), "\r", "");
  }
  return input;
}

test_runner :: proc(name : string, doTestA, doTestB, doTestC, doInput : LogicCallback, expectedTestAResult, expectedTestBResult, expectedTestCResult : Result)
{
  using fmt;

  result : Result;
  testsPassed : bool = true;

  // TEST A:
  if expectedTestAResult != nil
  {
    print(ANSI_FG_PURPLE);
    println("\n ", name, ":: TEST A");
    println("-----------------------");
    print(ANSI_RESET);
    {
      PERF(PT_TEST_A);
      result = doTestA();
    }
    testsPassed &= print_test_results(name, expectedTestAResult, result);
    print(ANSI_FG_PURPLE);
  }

  // TEST B:
  if expectedTestBResult != nil
  {
    print(ANSI_FG_PURPLE);
    println("\n ", name, ":: TEST B");
    println("-----------------------");
    print(ANSI_RESET);
    {
      PERF(PT_TEST_B);
      result = doTestB();
    }
    testsPassed &= print_test_results(name, expectedTestBResult, result);
  }

  // TEST C:
  if expectedTestCResult != nil
  {
    print(ANSI_FG_PURPLE);
    println("\n ", name, ":: TEST C");
    println("-----------------------");
    print(ANSI_RESET);
    {
      PERF(PT_TEST_C);
      result = doTestC();
    }
    testsPassed &= print_test_results(name, expectedTestCResult, result);
  }

  // SOLUTION:
  if testsPassed
  {
    print(ANSI_FG_BRIGHT_PURPLE);
    println("\n ", name, ":: SOLUTION");
    println("-----------------------");
    print(ANSI_RESET);
    {
      PERF(PT_SOLUTION);
      result = doInput();
    }
    println(args={ANSI_FG_BRIGHT_GREEN, "    > ", name, " :: ", ANSI_BG_GREEN, ANSI_FG_BLACK, " ", result, " ", ANSI_RESET}, sep="");
  }

  // TIMING:
  print(ANSI_FG_GRAY);
  println("\n ", name, ":: TIMING");
  println("-----------------------");
  frq : windows.LARGE_INTEGER;
  windows.QueryPerformanceFrequency(&frq);
  print_timing :: proc(timers : []^PerformanceTimer, indent : int, frq : windows.LARGE_INTEGER)
  {
    for timer in timers
    {
      if timer != nil
      {
        printf(temp_str(cat("%", 2+(2*indent), "v- %", 25-(2*indent), "v :: % 9v times :: % 12.3vμs :: % 10vkc\n")), "", timer.name, timer.invocations, f64(timer.totalTime)/f64(frq) * 1000.0 * 1000.0, timer.totalTime);
        if len(timer.children) > 0
        {
          print_timing(timer.children, indent + 1, frq);
        }
      }
    }
  }
  print_timing(performanceTiming.rootTimers, 0, frq);
  print(ANSI_RESET);
  print("\n\n");
  clear_all_performance_timers();
}

print_test_results :: proc(name : string, expected, actual : Result) -> bool
{
  using fmt;

  expectedInt, expectIsInt := expected.(int);
  expectedString, expectIsString := expected.(string);
  actualInt, actualIsInt := actual.(int);
  actualString, actualIsString := actual.(string);
  if expectIsInt && !actualIsInt
  {
    if actualIsString
    {
      println(args={ANSI_FG_RED, "    > ", name, " :: EXPECTED AN int<", expected, "> :: GOT A string<", actual, ">", ANSI_RESET}, sep="");
    }
    else
    {
      println(args={ANSI_FG_RED, "    > ", name, " :: EXPECTED AN int<", expected, "> :: GOT: nil", ANSI_RESET}, sep="");
    }
    return false;
  }
  else if expectIsString && !actualIsString
  {
    if actualIsInt
    {
      println(args={ANSI_FG_RED, "    > ", name, " :: EXPECTED A string<", expected, "> :: GOT AN int<", actual, ">", ANSI_RESET}, sep="");
    }
    else
    {
      println(args={ANSI_FG_RED, "    > ", name, " :: EXPECTED A string<", expected, "> :: GOT: nil", ANSI_RESET}, sep="");
    }
    return false;
  }
  else if (expectIsInt && actualIsInt && actualInt != expectedInt) ||
          (expectIsString && actualIsString && actualString != expectedString)
  {
    println(args={ANSI_FG_RED, "    > ", name, " :: EXPECTED: ", ANSI_BG_RED, ANSI_FG_BRIGHT_CYAN, " ", expected, " ", ANSI_FG_RED, " :: GOT: ", ANSI_BG_RED, ANSI_FG_BRIGHT_CYAN, " ", actual, " ", ANSI_RESET}, sep="");
    return false;
  }
  else
  {
    println(args={ANSI_FG_GRAY, "    > ", name, " :: ", ANSI_BG_GRAY, ANSI_FG_WHITE, " ", actual, " ", ANSI_RESET}, sep="");
  }

  return true;
}
