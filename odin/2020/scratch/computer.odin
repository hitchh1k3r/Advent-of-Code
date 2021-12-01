  // COMPUTER  TYPES ///////////////////////////////////////////////////////////////////////////////

  Computer :: struct
  {
    state : ComputerState,
    logLevel : LogLevel,
    logPreamble : string,
    acc : int,
    inst_ptr : int,
    prog : []Instruction,
  };

  ComputerState :: enum
  {
    RUNNING, FINISHED, ERR_INFINITE_LOOP, ERR_INST_PTR_OOB
  };

  LogLevel :: enum
  {
    NONE, IO, ERROR, WARN, TRACE
  };

  Instruction :: struct
  {
    op : Op,
    val : int,
    coverage : int,
  };

  Op :: enum
  {
    ACC, JMP, NOP
  };

  // COMPUTER  PROCS ///////////////////////////////////////////////////////////////////////////////

  resetComputer :: proc(using comp : ^Computer, label : string, instructions : []Instruction, debugLevel : LogLevel = .ERROR)
  {
    using aoc, fmt;

    state = .RUNNING;
    logLevel = debugLevel;
    logPreamble = cat(label, " :: ");
    inst_ptr = 0;
    acc = 0;
    if prog != nil
    {
      delete(prog);
    }
    prog = make([]Instruction, len(instructions));
    for v, i in instructions
    {
      prog[i] = v;
    }

    if logLevel >= .WARN
    {
      println("\n", ANSI_FG_BRIGHT_WHITE, logPreamble, "RESETTING COMPUTER", ANSI_RESET);
    }
  }

  stepComputer :: proc(using ^Computer)
  {
    using aoc, fmt;

    if state != .RUNNING
    {
      return;
    }
    if inst_ptr == len(prog)
    {
      state = .FINISHED;
      if logLevel >= .NONE
      {
        println(ANSI_FG_GREEN, logPreamble, "PROGRAM COMPLETED", ANSI_RESET);
      }
      return;
    }

    if inst_ptr < 0 || inst_ptr >= len(prog)
    {
      state = .ERR_INST_PTR_OOB;
      if logLevel >= .ERROR
      {
        println(ANSI_FG_YELLOW, logPreamble, "!!!!! OUT OF BOUNDS INSTRUCTION POINTER !!!!!", ANSI_RESET);
      }
      return;
    }

    if logLevel >= .TRACE
    {
      println("  ", logPreamble, "ACC: ", acc, "  InstPtr: ", inst_ptr, " ", prog[inst_ptr]);
    }

    if prog[inst_ptr].coverage > 0
    {
      state = .ERR_INFINITE_LOOP;
      if logLevel >= .ERROR
      {
        println(ANSI_FG_YELLOW, logPreamble, "INFINITE LOOP DETECTED", ANSI_RESET);
      }
      return;
    }

    prog[inst_ptr].coverage += 1;
    switch prog[inst_ptr].op
    {
      case .ACC:
      {
        acc += prog[inst_ptr].val;
        inst_ptr += 1;
      }
      case .JMP:
      {
        inst_ptr += prog[inst_ptr].val;
      }
      case .NOP:
      {
        inst_ptr += 1;
      }
    }
    return;
  }

  parseInstruction :: proc(allLines : []string) -> []Instruction
  {
    using aoc, strings, fmt;

    instructions : [dynamic]Instruction;
    for line in allLines
    {
      inst : Instruction;
      bits := split(line, " ");
      ok : bool;
      inst.op, ok = reflect.enum_from_name(Op, temp_str(to_upper(bits[0])));
      if !ok
      {
        println(ANSI_FG_BRIGHT_RED, "Faild to parse OpCode:", bits[0], ANSI_RESET);
      }
      inst.val = int_val(bits[1]);
      append(&instructions, inst);
    }
    return instructions[:];
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////

  instructions := parseInstruction(allLines);

  comp : Computer;
  resetComputer(&comp, "COMPUTER", instructions);

  for comp.state == .RUNNING
  {
    stepComputer(&comp);
  }