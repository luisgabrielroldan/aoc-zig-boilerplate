const std = @import("std");
const aoc = @import("../aoc.zig");
const testing = std.testing;

const Card = struct {
    allocator: std.mem.Allocator,
    id: u32,
    winners: std.AutoHashMap(u32, void),
    numbers: std.AutoHashMap(u32, void),
    instances: u32,

    pub fn parse(allocator: std.mem.Allocator, input: []const u8) !Card {
        var tokens = std.mem.tokenizeAny(u8, input[5..], ":|");
        var id_str = tokens.next().?;

        id_str = std.mem.trim(u8, id_str, " ");
        const id = try std.fmt.parseInt(u32, id_str, 10);
        const winners = try parse_numbers(allocator, tokens.next().?);
        const numbers = try parse_numbers(allocator, tokens.next().?);

        return .{
            .allocator = allocator,
            .id = id,
            .winners = winners,
            .numbers = numbers,
            .instances = 1,
        };
    }

    pub fn matches(self: Card) u32 {
        var count: u32 = 0;
        var iter = self.numbers.keyIterator();

        while (iter.next()) |n| {
            if (self.winners.contains(n.*)) {
                count += 1;
            }
        }

        return count;
    }

    pub fn points(self: Card) u32 {
        var score: u32 = 0;
        var iter = self.numbers.keyIterator();

        while (iter.next()) |n| {
            if (self.winners.contains(n.*)) {
                score = if (score == 0) 1 else score * 2;
            }
        }

        return score;
    }

    pub fn deinit(self: *Card) void {
        self.winners.deinit();
        self.numbers.deinit();
    }

    fn parse_numbers(allocator: std.mem.Allocator, input: []const u8) !std.AutoHashMap(u32, void) {
        var numbers = std.AutoHashMap(u32, void).init(allocator);

        var tokens = std.mem.tokenizeAny(u8, input, " ");
        while (tokens.next()) |token| {
            try numbers.put(try std.fmt.parseInt(u32, token, 10), {});
        }

        return numbers;
    }
};

pub const Solution = aoc.Solution("04", struct {
    pub fn part1(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        var sum: usize = 0;

        for (input) |line| {
            var card = try Card.parse(allocator, line);
            defer card.deinit();

            sum += card.points();
        }

        return sum;
    }

    pub fn part2(allocator: std.mem.Allocator, input: [][]const u8) !usize {
        var cards = std.ArrayList(Card).init(allocator);
        defer {
            for (cards.items) |*c| {
                c.deinit();
            }
            cards.deinit();
        }

        for (input) |line| {
            const card = try Card.parse(allocator, line);
            try cards.append(card);
        }

        var i: usize = 0;

        while (i < cards.items.len) {
            const current_card = cards.items[i];

            const matches = current_card.matches();

            for ((i + 1)..(i + 1 + matches)) |x| {
                cards.items[x].instances += current_card.instances;
            }

            i += 1;
        }

        var sum: usize = 0;

        for (cards.items) |c| {
            sum += c.instances;
        }

        return sum;
    }
});

test "part 1" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.first, "sample-1");
    try std.testing.expectEqual(13, result);
}

test "part 2" {
    const result = try Solution.run_with_input(std.testing.allocator, aoc.Part.second, "sample-1");
    try std.testing.expectEqual(30, result);
}

test "Card.parse" {
    var card = try Card.parse(testing.allocator, "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53");
    defer card.deinit();

    try testing.expectEqual(1, card.id);
    try testing.expectEqual(5, card.winners.count());
    try testing.expectEqual(8, card.numbers.count());
    try testing.expectEqual(8, card.points());
}
