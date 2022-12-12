
const std = @import("std");
const absInt = std.math.absInt;

pub const Direction = enum {
    left, right, up, down,
    
    pub fn fromChar(char: u8) ?Direction {
        return switch(char) {
            'l', 'L' => .left,
            'r', 'R' => .right,
            'u', 'U' => .up,
            'd', 'D' => .down,
            else => null
        };
    }
};

pub const Vec2Int = struct {
    x: i32,
    y: i32,

    pub fn manhattanDistance(self: Vec2Int, other: Vec2Int) i32 {
        return abs_i32(self.x - other.x) + abs_i32(self.y - other.y);
    }

    pub fn distance(self: Vec2Int, other: Vec2Int) f32 {
        const dx = self.x - other.x;
        const dy = self.y - other.y;
        const sqr_dist = (dx * dx) + (dy * dy);
        return @sqrt(@intToFloat(f32, sqr_dist));
    }

    pub const zero = Vec2Int{ .x = 0, .y = 0 };
};

pub fn moveVecByDirection(vec: Vec2Int, direction: Direction) Vec2Int {
    return switch(direction) {
        .left => .{.x = vec.x - 1, .y = vec.y},
        .right => .{.x = vec.x + 1, .y = vec.y},
        .up => .{.x = vec.x, .y = vec.y + 1},
        .down => .{.x = vec.x, .y = vec.y - 1}
    };
}

fn abs_i32(x: i32) i32 {
    return if (x < 0) -x else x;
}