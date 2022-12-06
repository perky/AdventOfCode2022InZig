const std = @import("std");
const puzzleinput = @import("puzzleinput.zig");
const data = @embedFile("data/day04.txt");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const int = i32;
const TwoSpans = struct {a: Span, b: Span};
const Span = struct {
    min: int,
    max: int,

    pub fn overlaps(self: Span, other: Span) bool {
        return other.min <= self.max and other.max >= self.min;
    }

    pub fn contains(self: Span, other: Span) bool {
        return other.min >= self.min and other.max <= self.max;
    }
};

const expect = std.testing.expect;
test "Span contains" {
    const span_base = Span {.min = 5, .max = 20};
    const span_inside = Span {.min = 11, .max = 16};
    try expect(span_base.contains(span_inside));
    const span_outside = Span {.min = 21, .max = 55};
    try expect(!span_base.contains(span_outside));
    const span_overlap = Span {.min = 19, .max = 55};
    try expect(!span_base.contains(span_overlap));
    const span_invert_contain = Span {.min = 4, .max = 21};
    try expect(!span_base.contains(span_invert_contain));
}

pub fn main() !void {
    var score_contain = try puzzleinput.executeFuncPerInputLine(data, countContainingSectors);
    print("count of containing sectors: {d}\n", .{score_contain});
    var score_overlap = try puzzleinput.executeFuncPerInputLine(data, countOverlappingSectors);
    print("count of overlapping sectors: {d}\n", .{score_overlap});
}

fn parseSpans(line: []const u8) !TwoSpans {
    var tokens = std.mem.tokenize(u8, line, "-,");
    var span1 = Span {
        .min = try parseInt(int, tokens.next().?, 10),
        .max = try parseInt(int, tokens.next().?, 10)
    };
    var span2 = Span {
        .min = try parseInt(int, tokens.next().?, 10),
        .max = try parseInt(int, tokens.next().?, 10)
    };
    return TwoSpans {.a = span1, .b = span2};
}

fn countContainingSectors(line: []const u8, _: usize) !i32 {
    const span = try parseSpans(line);
    const b_contains = span.a.contains(span.b) or span.b.contains(span.a);
    if (b_contains) {
        return 1;
    }
    return 0;
}

fn countOverlappingSectors(line: []const u8, _: usize) !i32 {
    const span = try parseSpans(line);
    const b_overlaps = span.a.overlaps(span.b);
    if (b_overlaps) {
        return 1;
    }
    return 0;
}
