package aoc;

// Stack ///////////////////////////////////////////////////////////////////////////////////////////

Stack :: struct(ELEMENT_TYPE : typeid, CAPACITY := 256)
{
  arr : [CAPACITY]ELEMENT_TYPE,
  index : int,
}

stack_push :: proc(using stack : ^$S/Stack($ELEMENT_TYPE, $CAPACITY), el : ELEMENT_TYPE)
{
  assert(index+1 < CAPACITY);
  arr[index] = el;
  index += 1;
}

stack_pop :: proc(using stack : ^$S/Stack($ELEMENT_TYPE, $CAPACITY)) -> ELEMENT_TYPE
{
  assert(index > 0);
  index -= 1;
  return stack.arr[index];
}

stack_peek :: proc(using stack : $S/Stack($ELEMENT_TYPE, $CAPACITY)) -> ELEMENT_TYPE
{
  assert(index > 0);
  return stack.arr[index-1];
}

// Priority Queue //////////////////////////////////////////////////////////////////////////////////

PriorityQueue :: struct(ELEMENT_TYPE : typeid, CAPACITY := 256)
{
  arr : [CAPACITY]ELEMENT_TYPE,
  index : int,
  priority : proc(item: ELEMENT_TYPE) -> int,
}

priority_queue_push :: proc(using queue : ^$Q/PriorityQueue($ELEMENT_TYPE, $CAPACITY), item : ELEMENT_TYPE)
{
  assert(index+1 < CAPACITY);
  arr[index] = item;
  index += 1;
}

priority_queue_pop :: proc(using queue : ^$Q/PriorityQueue($ELEMENT_TYPE, $CAPACITY)) -> ELEMENT_TYPE
{
  assert(index > 0);

  max_item : ELEMENT_TYPE;
  max_index := -1;
  max_p := -1;
  for q, i in arr
  {
    if i >= index
    {
      break;
    }

    my_p := priority(q);
    if my_p > max_p
    {
      max_p = my_p;
      max_item = q;
      max_index = i;
    }
  }
  slice := arr[max_index:index+1];
  shift_left(&slice, 1);
  index -= 1;
  return max_item;
}

// Procedures //////////////////////////////////////////////////////////////////////////////////////

push :: proc { stack_push, priority_queue_push };

pop :: proc { stack_pop, priority_queue_pop };
