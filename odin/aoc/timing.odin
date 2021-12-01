package aoc;

import "core:reflect"
import "core:runtime"
import "core:sync"
import "core:sys/windows"

////////////////////////////////////////////////////////////////////////////////////////////////////

PerformanceTimer :: struct
{
  name              : string,
  lock              : sync.Mutex,
  invocations       : int,
  totalTime         : windows.LARGE_INTEGER,
  firstLOC, lastLOC : runtime.Source_Code_Location,
  parent            : ^PerformanceTimer,
  children          : []^PerformanceTimer,
}

PerformanceTiming :: struct
{
  lock          : sync.Mutex,
  sampleIdCount : int,
  rootTimers    : []^PerformanceTimer,
}

PerformanceSampleId :: struct
{
  index : int,
  name : string,
}

////////////////////////////////////////////////////////////////////////////////////////////////////

@(deferred_out=_end_performance_timer)
PERF :: proc(sampleId : PerformanceSampleId, loc := #caller_location) -> ^PerformanceTimer
{
  return _begin_performance_timer(sampleId, loc);
}

END_PERF :: proc()
{
  _end_performance_timer_early();
}

init_performance_timing :: proc(sampleIdCount : int, loc := #caller_location)
{
  @static isInitialized : bool;
  assert(!isInitialized, "Performance Timing Is Already Initialized", loc);
  isInitialized = true;

  sync.mutex_init(&performanceTiming.lock);
  performanceTiming.sampleIdCount = sampleIdCount;
  performanceTiming.rootTimers = make([]^PerformanceTimer, sampleIdCount);
}

clear_all_performance_timers :: proc()
{
  using performanceTiming;

  // TODO (hitch) 2020-12-10 Make this NOT leak all the memory!
  //                         It will have to do a recursive delete!
  for _, i in rootTimers
  {
    if rootTimers[i] != nil
    {
      free(rootTimers[i]);
    }
    rootTimers[i] = nil;
  }
  currentTimer = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

              performanceTiming : PerformanceTiming;
@thread_local currentTimer      : ^PerformanceTimer;
@thread_local startTimeStack    : Stack(windows.LARGE_INTEGER, 10);

_begin_performance_timer :: proc(sampleId : PerformanceSampleId, loc := #caller_location) -> ^PerformanceTimer
{
  using sync, reflect;

  newPerfTimer : ^PerformanceTimer;

  // TODO (hitch) 2020-12-11 This makes a program that can finish in 1/200 second,
  //                         finish in 8 seconds.... it needs WAY MORE SPEED!!!

  // Get Or Make New Timer:
  if currentTimer == nil
  {
    mutex_lock(&performanceTiming.lock);
    newPerfTimer = performanceTiming.rootTimers[sampleId.index];
    if newPerfTimer == nil
    {
      // Make Root Timer:
      newPerfTimer = new(PerformanceTimer);
      newPerfTimer.name = sampleId.name;
      newPerfTimer.children = make([]^PerformanceTimer, 25);
      mutex_init(&newPerfTimer.lock);
      mutex_lock(&newPerfTimer.lock);
      performanceTiming.rootTimers[sampleId.index] = newPerfTimer;
      mutex_unlock(&performanceTiming.lock);
      newPerfTimer.firstLOC = loc;
    }
    else
    {
      // Get Root Timer:
      mutex_lock(&newPerfTimer.lock);
      mutex_unlock(&performanceTiming.lock);
    }
  }
  else
  {
    mutex_lock(&currentTimer.lock);
    newPerfTimer = currentTimer.children[sampleId.index];
    if newPerfTimer == nil
    {
      // Make Child Timer:
      newPerfTimer = new(PerformanceTimer);
      newPerfTimer.name = sampleId.name;
      newPerfTimer.children = make([]^PerformanceTimer, 25);
      mutex_init(&newPerfTimer.lock);
      mutex_lock(&newPerfTimer.lock);
      currentTimer.children[sampleId.index] = newPerfTimer;
      mutex_unlock(&currentTimer.lock);
      newPerfTimer.firstLOC = loc;
    }
    else
    {
      // Get Child Timer:
      mutex_lock(&newPerfTimer.lock);
      mutex_unlock(&currentTimer.lock);
    }
    newPerfTimer.parent = currentTimer;
  }

  // Start The Timer:
  newPerfTimer.invocations += 1;
  newPerfTimer.lastLOC = loc;
  mutex_unlock(&newPerfTimer.lock);
  currentTimer = newPerfTimer;

  startTime : windows.LARGE_INTEGER;
  windows.QueryPerformanceCounter(&startTime);
  push(&startTimeStack, startTime);

  return newPerfTimer;
}

_end_performance_timer_early :: proc()
{
  if currentTimer != nil
  {
    startTime := pop(&startTimeStack);
    endTime : windows.LARGE_INTEGER;
    windows.QueryPerformanceCounter(&endTime);
    sync.mutex_lock(&currentTimer.lock);
    currentTimer.totalTime += endTime - startTime;
    sync.mutex_unlock(&currentTimer.lock);
    currentTimer = currentTimer.parent;
  }
}

_end_performance_timer :: proc(timer : ^PerformanceTimer)
{
  if currentTimer == timer
  {
    startTime := pop(&startTimeStack);
    endTime : windows.LARGE_INTEGER;
    windows.QueryPerformanceCounter(&endTime);
    sync.mutex_lock(&currentTimer.lock);
    currentTimer.totalTime += endTime - startTime;
    sync.mutex_unlock(&currentTimer.lock);
    currentTimer = currentTimer.parent;
  }
}
