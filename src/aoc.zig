const std = @import("std");

pub const Part = enum { first, second };

pub fn Solution(comptime input_prefix: []const u8, comptime impl: type) type {
    return struct {
        fn do_run(allocator: std.mem.Allocator, part: Part, input: [][]const u8) !usize {
            if (part == Part.first) {
                return try impl.part1(allocator, input);
            } else {
                return try impl.part2(allocator, input);
            }
        }

        pub fn run(allocator: std.mem.Allocator, part: Part) !usize {
            return run_with_input(allocator, part, "input");
        }

        pub fn run_with_input(allocator: std.mem.Allocator, part: Part, input_name: []const u8) !usize {
            const fileName = try std.fmt.allocPrint(allocator, "{s}_{s}", .{ input_prefix, input_name });
            defer allocator.free(fileName);

            const input_lines = try readFileLines(allocator, fileName);

            defer {
                for (input_lines.items) |line| {
                    allocator.free(line);
                }
                input_lines.deinit();
            }

            return try do_run(allocator, part, input_lines.items);
        }
    };
}

pub fn readFileLines(allocator: std.mem.Allocator, name: []const u8) !std.ArrayList([]const u8) {
    const filename = try std.fmt.allocPrint(allocator, "inputs/{s}.txt", .{name});
    defer allocator.free(filename);

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var result = std.ArrayList([]const u8).init(allocator);
    errdefer {
        for (result.items) |line| {
            allocator.free(line);
        }
        result.deinit();
    }

    var buf = std.ArrayList(u8).init(allocator);
    defer buf.deinit();

    while (true) {
        buf.clearRetainingCapacity();

        reader.streamUntilDelimiter(buf.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => {
                if (buf.items.len > 0) {
                    const line = try allocator.dupe(u8, buf.items);
                    try result.append(line);
                }
                break;
            },
            else => return err,
        };

        const line = try allocator.dupe(u8, buf.items);
        try result.append(line);
    }

    return result;
}
