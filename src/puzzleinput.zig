const std = @import("std");

pub fn inputLines(data: []const u8) std.mem.SplitIterator(u8) {
    return std.mem.split(u8, data, "\n");
}

pub fn executeFuncPerInputLine(
    data: []const u8, 
    func: fn ([]const u8, usize) anyerror!i32) !i32 {

    var sum: i32 = 0;
    var lines = inputLines(data);
    var line_i: usize = 0;
    while (lines.next()) |line| {
        sum += try func(line, line_i);
        line_i += 1;
    }
    return sum;
}

pub fn executeFuncPerGroupOfInputLines(
    comptime group_size: usize, 
    data: []const u8, 
    func: fn ([group_size][]const u8, usize) anyerror!i32) !i32 {

    var sum: i32 = 0;
    var lines = inputLines(data);
    var group_i: usize = 0;
    var group_count: usize = 0;
    var group_lines: [group_size][]const u8 = undefined;
    while (lines.next()) |line| {
        group_lines[group_count] = line;
        group_count += 1;
        if (group_count == group_size) {
            sum += try func(group_lines, group_i);
            group_count = 0;
            group_i += 1;
        }
    }
    return sum;
}