// DataStream
const DataStream = @This();
const std = @import("std");

data: []const u8,
cursor: usize = 0,
b_first_next: bool = true,

pub fn init(data: []const u8) DataStream {
    return DataStream{
        .data = data
    };
}

pub fn nextLine(self: *DataStream) bool {
    if (self.b_first_next) {
        self.b_first_next = false;
        return !self.isEndOfData();
    }

    _ = self.seekForwardToNextLine();
    return !self.isEndOfData();
}

pub fn seekForwardToChar(self: *DataStream, char: u8) usize {
    while(self.data[self.cursor] != char) {
        self.cursor += 1;
        if (self.isEndOfData()) break;
    }
    return self.cursor;
}

pub fn seekForwardUntilNotChar(self: *DataStream, char: u8) usize {
    while(self.data[self.cursor] == char) {
        self.cursor += 1;
        if (self.isEndOfData()) break;
    }
    return self.cursor;
}

pub fn seekForwardToAlphanumeric(self: *DataStream) usize {
    return self.seekForwardWhileCondition(isAlphanumeric, false);
}

pub fn seekForwardToNonAlphanumeric(self: *DataStream) usize {
    return self.seekForwardWhileCondition(isAlphanumeric, true);
}

pub fn seekForwardToNumerical(self: *DataStream) usize {
    return self.seekForwardWhileCondition(isNumerical, false);
}

pub fn seekForwardToNonNumerical(self: *DataStream) usize {
    return self.seekForwardWhileCondition(isNumerical, true);
}

pub fn seekForwardToNextLine(self: *DataStream) usize {
    _ = self.seekForwardWhileCondition(isNewline, false);
    if (self.isEndOfData()) return self.cursor;
    
    if (self.getChar() == '\r') self.cursor += 1;
    if (self.getChar() == '\n') self.cursor += 1;
    return self.cursor;
}

pub fn seekForwardWhileCondition(self: *DataStream, condition_fn: fn(DataStream) bool, expected: bool) usize {
    while(!self.isEndOfData() and condition_fn(self.*) == expected) {
        self.cursor += 1;
    }
    return self.cursor;
}

pub fn seekForward(self: *DataStream, distance: usize) usize {
    self.cursor += distance;
    return self.cursor;
}

pub fn seekBackward(self: *DataStream, distance: usize) usize {
    self.cursor -= distance;
    return self.cursor;
}

pub fn readWord(self: *DataStream) []const u8 {
    const start = self.seekForwardToAlphanumeric();
    const end = self.seekForwardToNonAlphanumeric();
    return self.data[start..end];
}

pub fn readNumber(self: *DataStream) ?usize {
    const start = self.seekForwardToNumerical();
    const end = self.seekForwardToNonNumerical();
    const value_bytes = self.data[start..end];
    const value = std.fmt.parseInt(usize, value_bytes, 10) catch {
        std.debug.print("[DataSteam] unable to parse number: {s} {any}\n", .{value_bytes, value_bytes});
        return null;
    };
    return value;
}

pub fn readChar(self: *DataStream) u8 {
    const result = self.data[self.cursor];
    self.cursor += 1;
    return result;
}

pub fn getChar(self: DataStream) u8 {
    return self.data[self.cursor];
}

pub fn parseInt(self: *DataStream, comptime T: anytype) !T {
    const begin = self.cursor;
    const end = self.seekForwardToNonAlphanumeric();
    return (try std.fmt.parseInt(T, self.data[begin..end], 10));
} 

pub fn isAlphanumeric(self: DataStream) bool {
    return self.isNumerical() or self.isAlphabetical();
}

pub fn isAlphabetical(self: DataStream) bool {
    const char = self.data[self.cursor];
    return (char >= 'a' and char <= 'z') or (char >= 'A' and char <= 'Z');
}

pub fn isNumerical(self: DataStream) bool {
    const char = self.data[self.cursor];
    return char >= '0' and char <= '9';
}

pub fn isEndOfData(self: DataStream) bool {
    return self.cursor >= self.data.len;
}

pub fn isNewline(self: DataStream) bool {
    const char = self.data[self.cursor];
    return char == '\r' or char == '\n';
}
