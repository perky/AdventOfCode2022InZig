const std = @import("std");
const Allocator = std.mem.Allocator;
const Map = std.AutoHashMap;
const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");
const vector = @import("vector.zig");
const Vec2Int = vector.Vec2Int;
const Direction = vector.Direction;
const DataStream = @import("datastream.zig");

const NUM_KNOTS = 10;

const b_debug_mode = false;
fn null_print(_: anytype, _: anytype) void {}
const debug_print = if (b_debug_mode) std.debug.print else null_print;
const print = std.debug.print;

pub fn main() !void {
    var knots = [_]Vec2Int{ Vec2Int.zero } ** NUM_KNOTS;
    var head: *Vec2Int = &knots[0];
    var tail: *Vec2Int = &knots[NUM_KNOTS - 1];
    var visited = Map(Vec2Int, void).init(gpa);
    try visited.put(tail.*, {});
        
    var stream = DataStream.init(data);
    while (stream.nextLine()) {
        var maybe_direction = Direction.fromChar(stream.readChar());
        if (maybe_direction == null) @panic("unable to parse data.");

        var maybe_value = stream.readNumber();
        if (maybe_value == null) @panic("unable to parse data.");
        
        var i: i32 = 0;
        while (i < maybe_value.?) : (i += 1) {
            head.* = vector.moveVecByDirection(head.*, maybe_direction.?);

            for (knots) |*knot, knot_i| {
                if (knot_i == 0) continue;
                const prev_knot: *Vec2Int = &knots[knot_i - 1];
                const distance: f32 = knot.distance(prev_knot.*);
                if (distance >= 2.0) {
                    if (knot.x < prev_knot.x) {
                        knot.* = vector.moveVecByDirection(knot.*, .right);
                    } else if (knot.x > prev_knot.x) {
                        knot.* = vector.moveVecByDirection(knot.*, .left);
                    }
                    if (knot.y < prev_knot.y) {
                        knot.* = vector.moveVecByDirection(knot.*, .up);
                    } else if (knot.y > prev_knot.y) {
                        knot.* = vector.moveVecByDirection(knot.*, .down);
                    }
                }
            }

            try visited.put(tail.*, {});
            debug_print("dir => {}/{d} ## head => x: {d}, y: {d} ## tail => x: {d}, y: {d} ## dist => {d}\n", .{
                maybe_direction.?, maybe_value.?, head.x, head.y, tail.x, tail.y, head.distance(tail.*)
            });
        }
    }

    var keys = visited.keyIterator();
    var count: i32 = 0;
    while (keys.next()) |key| {
        count += 1;
        debug_print("visited => x: {d}, y: {d}\n", .{key.x, key.y});
    }
    print("places tail has visited => {d}\n", .{count});
}
