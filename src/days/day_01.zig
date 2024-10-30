const std = @import("std");
const aoc = @import("../aoc.zig");

pub const Solution = aoc.Solution("01", struct {
    pub fn part1(_: std.mem.Allocator, _: [][]const u8) !usize {
        return 0;
    }

    pub fn part2(_: std.mem.Allocator, _: [][]const u8) !usize {
        return 0;
    }
});

test "part 1" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.first, "sample-1");
    try std.testing.expectEqual(0, result);
}

test "part 2" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.second, "sample-2");
    try std.testing.expectEqual(0, result);
}
