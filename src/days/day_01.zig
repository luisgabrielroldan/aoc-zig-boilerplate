const std = @import("std");
const aoc = @import("../aoc.zig");

pub const Solution = aoc.Solution("01", struct {
    pub fn part1(_: std.mem.Allocator, input: [][]const u8) !usize {
        var sum: usize = 0;

        for (input) |line| {
            var digits: [2]u8 = undefined;
            digits[0] = try first_digit(line, false);
            digits[1] = try last_digit(line, false);

            sum += try std.fmt.parseInt(u32, digits[0..], 10);
        }
        return sum;
    }

    pub fn part2(_: std.mem.Allocator, input: [][]const u8) !usize {
        var sum: usize = 0;

        for (input) |line| {
            var digits: [2]u8 = undefined;
            digits[0] = try first_digit(line, true);
            digits[1] = try last_digit(line, true);

            sum += try std.fmt.parseInt(u32, digits[0..], 10);
        }
        return sum;
    }

    fn first_digit(line: []const u8, consider_names: bool) !u8 {
        for (0..line.len) |i| {
            if (get_digit(line[i..], consider_names)) |digit| {
                return digit;
            }
        }
        @panic("No digit found!");
    }

    fn last_digit(line: []const u8, consider_names: bool) !u8 {
        var i: usize = line.len - 1;
        while (i >= 0) {
            if (get_digit(line[i..], consider_names)) |digit| {
                return digit;
            }
            i -= 1;
        }
        @panic("No digit found!");
    }

    fn get_digit(input: []const u8, consider_names: bool) ?u8 {
        const first_char = input[0];

        if (std.ascii.isDigit(first_char)) {
            return first_char;
        }

        if (!consider_names) {
            return null;
        }

        const ASCII_TO_DIGIT = [_]struct { []const u8, u8 }{
            .{ "zero", '0' },
            .{ "one", '1' },
            .{ "two", '2' },
            .{ "three", '3' },
            .{ "four", '4' },
            .{ "five", '5' },
            .{ "six", '6' },
            .{ "seven", '7' },
            .{ "eight", '8' },
            .{ "nine", '9' },
        };

        for (ASCII_TO_DIGIT) |item| {
            if (std.mem.startsWith(u8, input, item[0])) {
                return item[1];
            }
        }

        return null;
    }
});

test "part 1" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.first, "sample-1");
    try std.testing.expectEqual(142, result);
}

test "part 2" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.second, "sample-2");
    try std.testing.expectEqual(281, result);
}
