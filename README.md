# Advent of Code Zig Boilerplate

## Overview

This boilerplate is designed to help you quickly set up and organize your solutions for Advent of Code puzzles in Zig. It provides a consistent structure for your code, input files, and tests, making it easier to focus on problem-solving.

## Project structure

```
├── src
│   ├── main.zig        # Entry point for running solutions
│   ├── aoc.zig         # Common utilities
│   └── days
│       ├── day_01.zig  # Solution for Day 1 (Example provided);
│       └── day_xx.zig  # Solution for Day XX (copy from this to start a new solution)
├── inputs
│   ├── 01_input.txt    # Real input for Day1
│   ├── 01_sample.txt # Sample input for Day 1
│   └── XX_input.txt    # Real input for Day XX (to be added)
```

## Adding solutions

### 1. Create a new file for the day copying the day_xx.zig

```zig
const std = @import("std");
const aoc = @import("../aoc.zig");

// Change the day number. For example for day 2:
pub const Solution = aoc.Solution("02" , struct {

    // Input will be read from the file inputs/02_input.txt

    pub fn part1(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        // Your Part 1 solution here
        return answer;
    }

    pub fn part2(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        // Your Part 2 solution here
        return answer;
    }
});

test "part 1" {
    // This test will read the sample input from inputs/02_sample-1.txt
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.first, "sample-1");
    try std.testing.expectEqual(expected_result_part1, result);
}

test "part 2" {
    // This test will read the sample input from inputs/02_sample-2.txt
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.second, "sample-2");
    try std.testing.expectEqual(expected_result_part2, result);
}
```

The day number, also used as prefix for the input files is the first argument to the `aoc.Solution` function.
The second argument is a struct with two functions, `part1` and `part2`, which should contain your solutions for the two parts of the puzzle.

### 2. Add the new file to the list

```zig
const DAYS = [_]type{
    @import("days/day_01.zig").Solution,
    @import("days/day_XX.zig").Solution, // <-- Add this line changing XX to the day number
};

```

### 3. Input files

Place your input files in the inputs directory with the following naming convention:

Real Puzzle Input: `XX_input.txt` (e.g., `02_input.txt` for Day 2)
Sample Inputs: `XX_sample-1.txt`, `XX_sample-2.txt`, etc.

## Running solutions

To run the solution for a specific day, use:

```bash
zig build run -- <day number>
```

To run all test:
```bash
zig build test
```

# License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

