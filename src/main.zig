const std = @import("std");
const aoc = @import("aoc.zig");

const DAYS = [_]type{
    @import("days/day_01.zig").Solution,
    @import("days/day_02.zig").Solution,
    @import("days/day_03.zig").Solution,
    @import("days/day_04.zig").Solution,
    @import("days/day_05.zig").Solution,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const choose = try std.fmt.parseInt(u32, args[1], 10);

    inline for (DAYS, 0..) |day, i| {
        if (i + 1 == choose) {
            std.debug.print("Day: {d}\n\n", .{i + 1});

            const result1 = try day.run(allocator, aoc.Part.first);
            const result2 = try day.run(allocator, aoc.Part.second);

            std.debug.print("Result 1: {d}\n", .{result1});
            std.debug.print("Result 2: {d}\n", .{result2});

            return;
        }
    }

    std.debug.print("Day not found: {}\n", .{choose});
}

test "days_tests" {
    _ = DAYS;
}
