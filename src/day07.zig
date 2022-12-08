const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const util = @import("util.zig");
const gpa = util.gpa; // gpa = general purpose allocator.
const print = std.debug.print;
const puzzleinput = @import("puzzleinput.zig");
const DataStream = @import("datastream.zig");
const data = @embedFile("data/day07.txt");

const ROOT_DIR = "/";
const UP_DIR = "..";
const LS_CMD = "ls";
const CD_CMD = "cd";
fn isUpDir(word: []const u8) bool {
    return std.mem.eql(u8, word, UP_DIR);
}
fn isListCommand(word: []const u8) bool {
    return std.mem.eql(u8, word, LS_CMD);
}
fn isChangeDirectoryCommand(word: []const u8) bool {
    return std.mem.eql(u8, word, CD_CMD);
}

const Directory = struct {
    name: []const u8,
    size: usize
};

fn isDirectoryNameChar(stream: DataStream) bool {
    const char = stream.getChar();
    return char == '/' or char == '.' or stream.isAlphanumeric();
}

fn readDirectoryName(stream: *DataStream) []const u8 {
    const start = stream.seekForwardWhileCondition(isDirectoryNameChar, false);
    const end = stream.seekForwardWhileCondition(isDirectoryNameChar, true);
    return stream.*.data[start..end];
}

const TermMode = enum { none, await_command, list };

pub fn main() !void {
    const dir_size_threshold: usize = 100000;
    const disk_size: usize = 70000000;
    const desired_unused_size: usize = 30000000;

    var term_mode: TermMode = .none;
    var all_dirs = List(Directory).init(gpa);
    var current_dir_stack = List(usize).init(gpa);
    var lines = puzzleinput.inputLines(data);

    // iterate over each line.
    while (lines.next()) |line| {
        var stream = DataStream {.data = line};

        // currently listing files/dirs, so add each listed file
        // size to each directory in the current stack.
        if (term_mode == .list) {
            if (stream.isNumerical()) {
                const size = stream.readNumber();
                for (current_dir_stack.items) |dir_idx| {
                    var dir = &all_dirs.items[dir_idx];
                    dir.size += size;
                }
            }
        }

        // if $ is read then switch to command mode.
        if (stream.readChar() == '$') {
            term_mode = .await_command;
            const word = stream.readWord();
            if (isChangeDirectoryCommand(word)) {
                // Change Directory command, we either pop the last
                // directory from the stack, or allocate a new one and
                // and it to the stack.
                // Note: this assumes a directory is only visited once.
                const dir_name = readDirectoryName(&stream);
                if (isUpDir(dir_name)) {
                    _ = current_dir_stack.pop();
                } else {
                    try all_dirs.append(.{.name = dir_name, .size = 0});
                    try current_dir_stack.append(all_dirs.items.len - 1);
                }
            } else if (isListCommand(word)) {
                // LiSt command.
                term_mode = .list;
            }
        }
    }

    var sum_of_sizes_under_threshold: usize = 0;
    for (all_dirs.items) |dir| {
        var b_under_threshold = dir.size <= dir_size_threshold;
        if (b_under_threshold) {
            sum_of_sizes_under_threshold += dir.size;
        }
    }
    print("sum of dirs under threshold: {d}\n", .{sum_of_sizes_under_threshold});

    const used_size = all_dirs.items[0].size;
    const unused_size = disk_size - used_size;
    const size_to_free = desired_unused_size - unused_size;
    print("used: {d}\nunused: {d}\ndelete: {d}\n", .{used_size, unused_size, size_to_free});
    
    var free_candidates = List(usize).init(gpa);
    for (all_dirs.items) |dir, dir_i| {
        if (dir.size >= size_to_free) {
            try free_candidates.append(dir_i);
            print("delete candidate: {s} [{d}]\n", .{dir.name, dir.size});
        }
    }

    var smallest_size: usize = disk_size;
    var smallest_dir: Directory = undefined;
    for (free_candidates.items) |dir_idx| {
        var dir = all_dirs.items[dir_idx];
        if (dir.size < smallest_size) {
            smallest_size = dir.size;
            smallest_dir = dir;
        }
    }
    print("delete this directory: {s} [{d}]\n", .{smallest_dir.name, smallest_dir.size});
}

