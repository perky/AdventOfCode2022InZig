const std = @import("std");
const List = std.ArrayList;
const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    // allocate a list where each entry
    var inventory_counts = List(u32).init(gpa);
    defer inventory_counts.deinit();
    try inventory_counts.append(0);
    var inventory_i : usize = 0;
    var line_iterator = std.mem.split(u8, data, "\n");
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            try inventory_counts.append(0);
            inventory_i += 1;
        } else {
            var value = try std.fmt.parseInt(u32, line, 10);
            inventory_counts.items[inventory_i] += value;
        }
    }

    const largest_inventory_count = largestValueInArray(u32, inventory_counts.items);
    try stdout.print("largest inventory is: {d}\n", .{largest_inventory_count});

    const largest_three_inventory_count = largestNValuesInArray(u32, 3, inventory_counts.items);
    const sum_of_largest_three = largest_three_inventory_count[0] + largest_three_inventory_count[1] + largest_three_inventory_count[2];
    try stdout.print("largest three inventories are: {d} {d} {d}\nThe sum is: {d}\n", .{
        largest_three_inventory_count[0],
        largest_three_inventory_count[1],
        largest_three_inventory_count[2],
        sum_of_largest_three
    });
}

fn largestValueInArray(comptime T: type, values: []T) T {
    var largest_value: T = 0;
    for (values) |value| {
        if (value > largest_value) {
            largest_value = value;
        }
    }
    return largest_value;
}

fn largestNValuesInArray(comptime T: type, comptime N: u32, values: []T) [N]T {
    var result: [N]T = undefined;
    var next_largest_value: u32 = std.math.maxInt(T);
    var i: u32 = 0;
    while(i < N) : (i += 1) {
        var largest_value: u32 = 0;
        for (values) |value| {
            if (value > largest_value and value < next_largest_value) {
                largest_value = value;
            }
        }
        result[i] = largest_value;
        next_largest_value = largest_value;
    }
    return result;
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
