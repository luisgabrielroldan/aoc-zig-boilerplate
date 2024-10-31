const std = @import("std");
const aoc = @import("../aoc.zig");

const Gear = struct { x: usize, y: usize };

const Number = struct {
    digits: []const u8,
    x: usize,
    y: usize,

    pub fn getNumber(self: Number) !u32 {
        return try std.fmt.parseInt(u32, self.digits, 10);
    }

    pub fn init(digits: []const u8, x: usize, y: usize) Number {
        return .{ .digits = digits, .x = x, .y = y };
    }

    pub fn isAdjacent(self: Number, x: usize, y: usize) bool {
        const x1: usize = @max(0, @as(i32, @intCast(self.x)) - 1);
        const y1: usize = @max(0, @as(i32, @intCast(self.y)) - 1);
        const x2 = self.x + self.digits.len;
        const y2 = self.y + 1;

        return (x1 <= x and x <= x2 and y1 <= y and y <= y2);
    }
};

const Schematic = struct {
    allocator: std.mem.Allocator,
    data: [][]const u8,

    pub fn init(allocator: std.mem.Allocator, data: [][]const u8) Schematic {
        return .{ .allocator = allocator, .data = data };
    }

    fn isSymbol(char: u8) bool {
        return char != '.' and !std.ascii.isDigit(char);
    }

    fn isPart(self: Schematic, number: Number) bool {
        const width = self.data[0].len;
        const height = self.data.len;

        const x1: usize = @max(0, @as(i32, @intCast(number.x)) - 1);
        const y1: usize = @max(0, @as(i32, @intCast(number.y)) - 1);
        const x2 = @min(width - 1, number.x + number.digits.len);
        const y2 = @min(height - 1, number.y + 1);

        if (isSymbol(self.data[number.y][x1])) {
            return true;
        }
        if (isSymbol(self.data[number.y][x2])) {
            return true;
        }
        for (x1..x2 + 1) |x| {
            if (isSymbol(self.data[y1][x])) {
                return true;
            }
        }
        for (x1..x2 + 1) |x| {
            if (isSymbol(self.data[y2][x])) {
                return true;
            }
        }

        return false;
    }

    pub fn getGearRatio(self: Schematic, x: usize, y: usize) !u32 {
        const parts = try self.getParts();
        defer parts.deinit();

        var ratio: u32 = 1;
        var parts_count: usize = 0;

        for (parts.items) |part| {
            if (part.isAdjacent(x, y)) {
                ratio = ratio * try part.getNumber();
                parts_count += 1;
            }
        }

        if (parts_count < 2) {
            return 0;
        }

        return ratio;
    }

    pub fn getGears(self: Schematic) !std.ArrayList(Gear) {
        var gears = std.ArrayList(Gear).init(self.allocator);

        const width = self.data[0].len;
        const height = self.data.len;
        var y: usize = 0;
        var x: usize = 0;

        while (y < height) {
            x = 0;
            while (x < width) {
                if (self.data[y][x] == '*') {
                    try gears.append(.{ .x = x, .y = y });
                }

                x += 1;
            }
            y += 1;
        }

        return gears;
    }

    pub fn getParts(self: Schematic) !std.ArrayList(Number) {
        var parts = std.ArrayList(Number).init(self.allocator);

        const width = self.data[0].len;
        const height = self.data.len;
        var y: usize = 0;
        var x: usize = 0;

        while (y < height) {
            x = 0;
            while (x < width) {
                const ch = self.data[y][x];

                if (!std.ascii.isDigit(ch)) {
                    x += 1;
                    continue;
                }

                const start = x;
                const line = self.data[y];
                var len: usize = 0;
                while (x < width) {
                    if (!std.ascii.isDigit(line[x])) {
                        break;
                    }

                    x += 1;
                    len += 1;
                }

                const digits = line[start .. start + len];
                const number = Number.init(digits, start, y);

                if (self.isPart(number)) {
                    try parts.append(number);
                }

                x += 1;
            }

            y += 1;
        }

        return parts;
    }
};

pub const Solution = aoc.Solution("03", struct {
    // https://adventofcode.com/2023/day/3
    pub fn part1(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        const schema = Schematic.init(allocator, input);
        const parts = try schema.getParts();
        defer parts.deinit();

        var sum: usize = 0;
        for (parts.items) |part| {
            sum += try part.getNumber();
        }

        return sum;
    }

    // https://adventofcode.com/2023/day/3#part2
    pub fn part2(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        const schema = Schematic.init(allocator, input);
        const gears = try schema.getGears();
        defer gears.deinit();

        var sum: usize = 0;

        for (gears.items) |gear| {
            sum += try schema.getGearRatio(gear.x, gear.y);
        }

        return sum;
    }
});

test "part 1" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.first, "sample-1");
    try std.testing.expectEqual(4361, result);
}

test "part 2" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.second, "sample-1");
    try std.testing.expectEqual(467835, result);
}
