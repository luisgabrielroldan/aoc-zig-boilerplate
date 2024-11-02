const std = @import("std");
const aoc = @import("../aoc.zig");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;

const Range = struct {
    dest: u64,
    source: u64,
    length: u64,
};

const SeedRange = struct { u64, u64 };

const Almanac = struct {
    allocator: Allocator,
    seeds: []u64,
    maps: ArrayList([]Range),

    pub fn init(allocator: Allocator, input: [][]const u8) !@This() {
        var maps = ArrayList([]Range).init(allocator);
        const seeds = try parseSeeds(allocator, input[0]);

        var i: usize = 2;
        var buffer = ArrayList([]const u8).init(allocator);
        defer buffer.deinit();

        while (i < input.len) {
            if (std.mem.eql(u8, input[i], "")) {
                const ranges = try parseMap(allocator, buffer.items);
                try maps.append(ranges);
                buffer.deinit();
                buffer = ArrayList([]const u8).init(allocator);
                i += 1;
                continue;
            }

            try buffer.append(input[i]);

            i += 1;
        }

        const ranges = try parseMap(allocator, buffer.items);
        try maps.append(ranges);

        return .{
            .allocator = allocator,
            .seeds = seeds,
            .maps = maps,
        };
    }

    pub fn getSeedLocation(self: @This(), seed: u64) u64 {
        var value: u64 = seed;

        for (self.maps.items) |ranges| {
            value = translateRange(ranges, value);
        }

        return value;
    }

    fn translateRange(ranges: []const Range, source: u64) u64 {
        for (ranges) |range| {
            if (range.source <= source and source < (range.source + range.length)) {
                const offset = @as(i128, @intCast(range.dest)) - @as(i128, @intCast(range.source));
                const result = source + offset;
                return @as(u64, @intCast(result));
            }
        }

        return source;
    }

    pub fn parseMap(allocator: Allocator, lines: [][]const u8) ![]Range {
        var ranges = ArrayList(Range).init(allocator);
        defer ranges.deinit();

        var i: usize = 1;

        while (i < lines.len) {
            const range = try parseRange(lines[i]);
            try ranges.append(range);
            i += 1;
        }

        return try ranges.toOwnedSlice();
    }

    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.seeds);
        for (self.maps.items) |ranges| {
            self.allocator.free(ranges);
        }
        self.maps.deinit();
    }

    pub fn parseMapHeader(line: []const u8) []const u8 {
        var tokens = std.mem.tokenizeAny(u8, line, " ");
        return tokens.next().?;
    }

    pub fn parseRange(line: []const u8) !Range {
        var tokens = std.mem.tokenizeAny(u8, line, " ");
        const dest = try std.fmt.parseInt(u64, tokens.next().?, 10);
        const source = try std.fmt.parseInt(u64, tokens.next().?, 10);
        const length = try std.fmt.parseInt(u64, tokens.next().?, 10);

        return .{
            .source = source,
            .dest = dest,
            .length = length,
        };
    }

    fn parseSeeds(allocator: Allocator, line: []const u8) ![]u64 {
        var seeds = ArrayList(u64).init(allocator);
        defer seeds.deinit();

        var tokens = std.mem.tokenizeAny(u8, line[6..], " ");
        while (tokens.next()) |token| {
            const value = try std.fmt.parseInt(u64, token, 10);
            try seeds.append(value);
        }

        return seeds.toOwnedSlice();
    }
};

pub const Solution = aoc.Solution("05", struct {
    pub fn part1(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        var almanac = try Almanac.init(allocator, input);
        defer almanac.deinit();

        var nearest: u64 = 0;

        for (almanac.seeds) |seed| {
            const location = almanac.getSeedLocation(seed);

            if (nearest == 0 or location < nearest) {
                nearest = location;
            }
        }

        return nearest;
    }

    pub fn part2(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        var almanac = try Almanac.init(allocator, input);
        defer almanac.deinit();

        // Collect seed ranges
        var seeds = ArrayList(SeedRange).init(allocator);
        defer seeds.deinit();
        var i: usize = 0;
        while (i < almanac.seeds.len) {
            try seeds.append(.{ almanac.seeds[i], almanac.seeds[i] + almanac.seeds[i + 1] });
            i += 2;
        }

        // Translate the seeds through the maps
        for (almanac.maps.items) |ranges| {
            var new = ArrayList(SeedRange).init(allocator);

            while (seeds.items.len > 0) {
                const start, const end = seeds.pop();

                var reached_end = true;
                for (ranges) |range| {
                    const o_start = @max(start, range.source);
                    const o_end = @min(end, range.source + range.length);

                    if (o_start < o_end) {
                        const from = o_start - range.source + range.dest;
                        const to = o_end - range.source + range.dest;
                        try new.append(.{ from, to });

                        if (o_start > start) {
                            try seeds.append(.{ start, o_start });
                        }
                        if (end > o_end) {
                            try seeds.append(.{ o_end, end });
                        }

                        reached_end = false;
                        break;
                    }
                }

                if (reached_end) {
                    try new.append(.{ start, end });
                }
            }

            seeds.deinit();
            seeds = new;
        }

        // Get the minimum value from the seeds
        var min: u64 = 0;
        for (seeds.items) |range| {
            if (min == 0 or range[0] < min) {
                min = range[0];
            }
        }

        return min;
    }
});

test "part 1" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.first, "sample-1");
    try std.testing.expectEqual(35, result);
}

test "part 2" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.second, "sample-1");
    try std.testing.expectEqual(46, result);
}

test "Almanac.init" {
    const allocator = testing.allocator;
    const input = try Solution.read_input(allocator, "sample-1");
    defer Solution.free_input(allocator, input);
    // ---------

    var almanac = try Almanac.init(allocator, input);
    defer almanac.deinit();

    try testing.expectEqualSlices(u64, &[_]u64{ 79, 14, 55, 13 }, almanac.seeds);

    try testing.expectEqual(82, almanac.getSeedLocation(79));
    try testing.expectEqual(43, almanac.getSeedLocation(14));
    try testing.expectEqual(86, almanac.getSeedLocation(55));
    try testing.expectEqual(35, almanac.getSeedLocation(13));
}

test "Almanac.readRange" {
    const range = try Almanac.parseRange("50 98 2");

    try testing.expectEqual(98, range.source);
    try testing.expectEqual(50, range.dest);
    try testing.expectEqual(2, range.length);
}

test "Almanac.translateRange 1" {
    const ranges = [_]Range{
        .{ .source = 98, .dest = 50, .length = 2 },
    };

    try testing.expectEqual(50, Almanac.translateRange(&ranges, 98));
    try testing.expectEqual(51, Almanac.translateRange(&ranges, 99));
    try testing.expectEqual(100, Almanac.translateRange(&ranges, 100));
}
