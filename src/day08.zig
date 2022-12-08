const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const puzzleinput = @import("puzzleinput.zig");
const DataStream = @import("datastream.zig");
const util = @import("util.zig");
const gpa = util.gpa;
const print = std.debug.print;
const data = @embedFile("data/day08.txt");

const GridList = struct {
    list: List(i32),
    width: usize,
    height: usize,
    userdata: *anyopaque = undefined,

    pub fn init(allocator: Allocator, width: usize, height: usize) GridList {
        return GridList{
            .list = List(i32).init(allocator),
            .width = width,
            .height = height
        };
    }

    pub fn indexFromCoords(self: GridList, x: usize, y: usize) usize {
        return (y * self.width) + x;
    }
    
    pub fn getFromCoords(self: GridList, x: usize, y: usize) i32 {
        return self.list.items[self.indexFromCoords(x,y)];
    }

    pub fn append(self: *GridList, value: i32) !void {
        try self.list.append(value);
    }

    const ForEachFn = fn(GridList, usize, usize, b_inner: bool) void;
    pub fn forEach(self: GridList, 
                   for_each_fn: ForEachFn) void {
        var y: usize = 0;
        while (y < self.height) : (y += 1) {
            var x: usize = 0;
            while (x < self.width) : (x += 1) {
                for_each_fn(self, x, y, true);
            }
            for_each_fn(self, x, y, false);
        }
    }

    pub fn castUserdataAsSlice(self: GridList, comptime T: type) []T {
        var slice_ptr: *[]T = @ptrCast(*[]T, @alignCast(@alignOf([]T), self.userdata));
        return slice_ptr.*;
    }
};

const Direction = enum {left, right, up, down};

fn markVisibleFromDirection(grid: *GridList, visible: []bool, direction: Direction) void {
    var i: usize = 0;
    const i_max = switch(direction) {
        .down, .up => grid.width,
        .left, .right => grid.height
    };
    const j_max = switch(direction) {
        .down, .up => grid.height,
        .left, .right => grid.width
    };
    while (i < i_max) : (i += 1) {
        var j: usize = 0;
        var largest_value: i32 = 0;
        while (j < j_max) : (j += 1) {
            const x = switch(direction) {
                .down, .up => i,
                .left => j,
                .right => (grid.width - 1) - j
            };
            const y = switch(direction) {
                .left, .right => i,
                .down => j,
                .up => (grid.height - 1) - j
            };
            const value: i32 = grid.getFromCoords(x, y);
            if (j == 0 or value > largest_value) {
                largest_value = value;
                const grid_index: usize = grid.indexFromCoords(x, y);
                visible[grid_index] = true;
            }
        }
    }
}

fn sceneryScoreFromDirection(grid: GridList, start_x: usize, start_y: usize, score: []i32, direction: Direction) void {
    var last_value: i32 = grid.getFromCoords(start_x, start_y);
    var origin_item_index = grid.indexFromCoords(start_x, start_y);
    var visible_count: usize = 0;

    var i = switch(direction) {
        .left => start_x,
        .right => 0,
        .down => start_y,
        .up => 0
    };
    var j = switch(direction) {
        .left, .right => start_y,
        .up, .down => start_x
    };
    var i_max = switch(direction) {
        .left => grid.width,
        .right => start_x+1,
        .down => grid.height,
        .up => start_y+1
    };

    i += 1;
    while(i < i_max) : (i += 1) {
        var x = switch(direction) {
            .left => i,
            .right => start_x - i,
            .up, .down => j
        };
        var y = switch(direction) {
            .left, .right => j,
            .down => i,
            .up => start_y - i
        };
        var value: i32 = grid.getFromCoords(x, y);
        visible_count += 1;
        if (value >= last_value) break;
    }
    
    score[origin_item_index] *= @intCast(i32, visible_count);
}

pub fn main() !void {
    // Read puzzle data and construct grid of trees.
    var trees = GridList.init(gpa, 0, 0);
    var lines = puzzleinput.inputLines(data);
    while (lines.next()) |line| {
        if (line.len > trees.width) trees.width = line.len;
        trees.height += 1;
        for (line) |char| {
            const tree_value: i32 = @intCast(i32, char - '0');
            try trees.append(tree_value);
        }
    }

    // Sweep along each direction, flagging visible trees.
    var visible_list: []bool = try gpa.alloc(bool, trees.width * trees.height);
    markVisibleFromDirection(&trees, visible_list, .down);
    markVisibleFromDirection(&trees, visible_list, .left);
    markVisibleFromDirection(&trees, visible_list, .up);
    markVisibleFromDirection(&trees, visible_list, .right);

    // Print out the grid of trees, marking visible ones as green.
    trees.userdata = &visible_list;
    trees.forEach(printTreeVisibility);

    // Count how many trees were flagged as visible.
    var visible_tree_count: usize = 0;
    for (visible_list) |b_visible| {
        if (b_visible) visible_tree_count += 1;
    }
    print("\nvisible trees: {d}\n", .{visible_tree_count});

    // init scenery scores, defaulting to 1.
    var scenery_scores: []i32 = try gpa.alloc(i32, trees.width * trees.height);
    for (scenery_scores) |*score| {
        score.* = 1;
    }

    // Iterate each tree and score its scenery.
    trees.userdata = &scenery_scores;
    trees.forEach(sceneryScoreTree);

    // Find and print the best scenery score.
    const max_scenery_score = std.mem.max(i32, scenery_scores);
    print("max scenery score: {d}\n", .{max_scenery_score});
}

fn sceneryScoreTree(trees: GridList, x: usize, y: usize, b_inner: bool) void {
    if (!b_inner) return;

    var scenery_scores: []i32 = trees.castUserdataAsSlice(i32);
    sceneryScoreFromDirection(trees, x, y, scenery_scores, .left);
    sceneryScoreFromDirection(trees, x, y, scenery_scores, .right);
    sceneryScoreFromDirection(trees, x, y, scenery_scores, .down);
    sceneryScoreFromDirection(trees, x, y, scenery_scores, .up);
}

fn printTreeVisibility(trees: GridList, x: usize, y: usize, b_inner: bool) void {
    var visible_list: []bool = trees.castUserdataAsSlice(bool);
    if (b_inner) {
        const tree_value: i32 = trees.getFromCoords(x, y);
        const tree_index: usize = trees.indexFromCoords(x, y);
        if (visible_list[tree_index]) {
            print("\x1b[92m{d}\x1b[0m", .{tree_value});
        } else {
            print("{d}", .{tree_value});
        }
    } else {
        print("\n", .{});
    }
}

fn printTreeSceneryScores(trees: GridList, x: usize, y: usize, b_inner: bool) void {
    var scenery_scores: []i32 = trees.castUserdataAsSlice(i32);
    if (b_inner) {
        const tree_index: usize = trees.indexFromCoords(x, y);
        var score = scenery_scores[tree_index];
        print("[{d}] ", .{score});
    } else {
        print("\n", .{});
    }
}
