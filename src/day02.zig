const std = @import("std");
const data = @embedFile("data/day02.txt");
const print = std.debug.print;
const puzzleinput = @import("puzzleinput.zig");

const Shape = enum(i32) {rock = 1, paper, scissors};
const Outcome = enum(i32) {lose = 0, draw = 3, win = 6};
const DataParseError = error {UnknownCharacter, InvalidLineLength};

pub fn main() !void {
    const score1 = try puzzleinput.executeFuncPerInputLine(data, strategyFollowShapeGuide);
    print("(follow shape guide) total score: {d}\n", .{score1});
    const score2 = try puzzleinput.executeFuncPerInputLine(data, strategyAchieveOutcome);
    print("(achieve outcome) total score: {d}\n", .{score2});
}

fn strategyFollowShapeGuide(line: []const u8, _: usize) !i32 {
    if (line.len != 3) {
        return DataParseError.InvalidLineLength;
    }
    var play_char = line[0];
    var response_char = line[2];
    var play_shape = try shapeFromCharacter(play_char);
    var response_shape = try shapeFromCharacter(response_char);
    var shape_score = score(response_shape);
    var outcome_score = score(outcomeFromShapes(response_shape, play_shape));
    return shape_score + outcome_score; 
}

fn strategyAchieveOutcome(line: []const u8, _: usize) !i32 {
    if (line.len != 3) {
        return DataParseError.InvalidLineLength;
    }
    var play_char = line[0];
    var response_char = line[2];
    var play_shape = try shapeFromCharacter(play_char);
    var response_outcome = try outcomeFromCharacter(response_char);
    var response_shape = shapeFromOutcome(response_outcome, play_shape);
    var shape_score = score(response_shape);
    var outcome_score = score(response_outcome);
    return shape_score + outcome_score;
}

fn outcomeFromShapes(my_shape: Shape, opponent_shape: Shape) Outcome {
    if (my_shape == opponent_shape) { // equal means draw
        return Outcome.draw;
    } if (my_shape == .rock and opponent_shape == .scissors) {
        return Outcome.win;
    } else if (my_shape == .paper and opponent_shape == .rock) {
        return Outcome.win;
    } else if (my_shape == .scissors and opponent_shape == .paper) {
        return Outcome.win;
    } else { // all other cases is loss.
        return Outcome.lose;
    }
}

fn shapeFromOutcome(my_outcome: Outcome, opponent_shape: Shape) Shape {
    if (my_outcome == .draw) {
        return opponent_shape;
    } else if (my_outcome == .win and opponent_shape != .scissors) {
        return @intToEnum(Shape, @enumToInt(opponent_shape) + 1);
    } else if (my_outcome == .win and opponent_shape == .scissors) {
        return Shape.rock;
    } else if (my_outcome == .lose and opponent_shape != .rock) {
        return @intToEnum(Shape, @enumToInt(opponent_shape) - 1);
    } else if (my_outcome == .lose and opponent_shape == .rock) {
        return Shape.scissors;
    } else {
        unreachable;
    }
}

fn shapeFromCharacter(char: u8) !Shape {
    switch(char) {
        'A', 'X' => return .rock,
        'B', 'Y' => return .paper,
        'C', 'Z' => return .scissors,
        else => return DataParseError.UnknownCharacter
    }
}

fn outcomeFromCharacter(char: u8) !Outcome {
    switch(char) {
        'X' => return .lose,
        'Y' => return .draw,
        'Z' => return .win,
        else => return DataParseError.UnknownCharacter
    }
}

fn score(input: anytype) i32 {
    return @enumToInt(input);
}
