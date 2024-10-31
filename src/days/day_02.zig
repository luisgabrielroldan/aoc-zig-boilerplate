const std = @import("std");
const aoc = @import("../aoc.zig");
const testing = std.testing;

const Color = enum {
    Red,
    Green,
    Blue,
};

fn parseColor(input: []const u8) !Color {
    const COLORS = [_][]const u8{ "red", "green", "blue" };

    for (COLORS, 0..) |color, i| {
        if (std.mem.eql(u8, input, color)) {
            return @enumFromInt(i);
        }
    }

    @panic("Invalid color");
}

const Set = struct {
    cubes: std.AutoHashMap(Color, u32),

    pub fn parse(allocator: std.mem.Allocator, input: []const u8) !Set {
        var cubes = std.AutoHashMap(Color, u32).init(allocator);
        var tokens = std.mem.tokenizeAny(u8, input, " ;,");
        while (tokens.next()) |count| {
            const count_int = try std.fmt.parseInt(u32, count, 10);
            if (tokens.next()) |color| {
                const colorEnum = try parseColor(color);
                try cubes.put(colorEnum, count_int);
            } else {
                @panic("Expected color!");
            }
        }

        return .{ .cubes = cubes };
    }

    pub fn deinit(self: *Set) void {
        self.cubes.deinit();
    }
};

const Game = struct {
    id: usize,
    sets: std.ArrayList(Set),

    pub fn parse(allocator: std.mem.Allocator, input: []const u8) !Game {
        var sets = std.ArrayList(Set).init(allocator);
        var tokens = std.mem.tokenizeAny(u8, input, ":;");
        const id = try parseId(tokens.next().?);
        while (tokens.next()) |set_slice| {
            const set = try Set.parse(allocator, set_slice);
            try sets.append(set);
        }

        return .{
            .id = id,
            .sets = sets,
        };
    }

    pub fn maxCubes(self: Game, color: Color) u32 {
        var max: u32 = 0;
        for (self.sets.items) |set| {
            if (set.cubes.get(color)) |count| {
                if (count > max) {
                    max = count;
                }
            }
        }
        return max;
    }

    pub fn getPower(self: Game) usize {
        return self.maxCubes(Color.Red) * self.maxCubes(Color.Green) * self.maxCubes(Color.Blue);
    }

    fn parseId(input: []const u8) !u32 {
        var tokens = std.mem.tokenizeAny(u8, input, " ");
        _ = tokens.next(); // Skip "Game"
        const id = tokens.next().?;
        return try std.fmt.parseInt(u32, id, 10);
    }

    pub fn deinit(self: *Game) void {
        for (self.sets.items) |*set| {
            set.deinit();
        }
        self.sets.deinit();
    }
};

pub const Solution = aoc.Solution("02", struct {
    pub fn part1(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        const MAX_RED = 12;
        const MAX_GREEN = 13;
        const MAX_BLUE = 14;

        var sum: usize = 0;

        for (input) |line| {
            var game = try Game.parse(allocator, line);
            defer game.deinit();

            const validRed = game.maxCubes(Color.Red) <= MAX_RED;
            const validGreen = game.maxCubes(Color.Green) <= MAX_GREEN;
            const validBlue = game.maxCubes(Color.Blue) <= MAX_BLUE;

            if (validRed and validGreen and validBlue) {
                sum += game.id;
            }
        }

        return sum;
    }

    pub fn part2(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        var sum: usize = 0;

        for (input) |line| {
            var game = try Game.parse(allocator, line);
            defer game.deinit();
            sum += game.getPower();
        }

        return sum;
    }
});

test "part 1" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.first, "sample-1");
    try std.testing.expectEqual(8, result);
}

test "part 2" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.second, "sample-1");
    try std.testing.expectEqual(2286, result);
}

test "parseColor" {
    try std.testing.expectEqual(Color.Red, try parseColor("red"));
    try std.testing.expectEqual(Color.Green, try parseColor("green"));
    try std.testing.expectEqual(Color.Blue, try parseColor("blue"));
}

test "Set.parse" {
    const input = "3 blue, 4 red";
    var set = try Set.parse(std.testing.allocator, input);
    defer set.deinit();

    try testing.expectEqual(3, set.cubes.get(Color.Blue));
    try testing.expectEqual(4, set.cubes.get(Color.Red));
}

test "Game.parse" {
    const input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green";
    var game = try Game.parse(std.testing.allocator, input);
    defer game.deinit();
    try testing.expectEqual(1, game.id);
    try testing.expectEqual(3, game.sets.items[0].cubes.get(Color.Blue));
    try testing.expectEqual(4, game.sets.items[0].cubes.get(Color.Red));
    try testing.expectEqual(1, game.sets.items[1].cubes.get(Color.Red));
    try testing.expectEqual(2, game.sets.items[1].cubes.get(Color.Green));
    try testing.expectEqual(6, game.sets.items[1].cubes.get(Color.Blue));
    try testing.expectEqual(2, game.sets.items[2].cubes.get(Color.Green));

    try testing.expectEqual(6, game.maxCubes(Color.Blue));
    try testing.expectEqual(4, game.maxCubes(Color.Red));
    try testing.expectEqual(2, game.maxCubes(Color.Green));

    try testing.expectEqual(48, game.getPower());
}
