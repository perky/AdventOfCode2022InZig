const std = @import("std");
const puzzleinput = @import("puzzleinput.zig");
const data = @embedFile("data/day03.txt");
const print = std.debug.print;

const DataParseError = error {UnknownCharacter, InvalidLineLength};
const ELF_GROUP_SIZE = 3;

const ItemSet = struct {
    item_flags: u64 = 0,

    pub fn initWithString(input_str: []const u8) !ItemSet {
        var item_set = ItemSet {};
        for (input_str) |char| {
            const priority = try priorityFromCharacter(char);
            item_set.setFlag(priority);
        }
        return item_set;
    }

    pub fn initWithOnlySameItems(a: ItemSet, b: ItemSet) ItemSet {
        var same_item_flags: u64 = a.item_flags & b.item_flags;
        return ItemSet {.item_flags = same_item_flags};
    }

    pub fn setFlag(self: *ItemSet, item_priority: u6) void {
        var mask: u64 = @as(u64, 1) << item_priority;
        self.item_flags = self.item_flags | mask;
    }

    pub fn itemPriority(self: ItemSet) u6 {
        if (self.item_flags == 0) {
            return 0;
        } else if (std.math.isPowerOfTwo(self.item_flags)) {
            var mask: u64 = 1;
            var bit_position: u6 = 0;
            while((mask & self.item_flags) == 0) {
                mask = mask << 1;
                bit_position += 1;
            }
            return bit_position;
        } else {
            print("item flags not power of two...\n{b:64}\n", .{
                self.item_flags,
            });
            unreachable;
        }
    }
};

pub fn main() !void {
    var score_misplaced = try puzzleinput.executeFuncPerInputLine(data, sumPriorityOfMisplacedItems);
    print("sum of misplaced items: {d}\n", .{score_misplaced});

    var score_badges = try puzzleinput.executeFuncPerGroupOfInputLines(ELF_GROUP_SIZE, data, sumPriorityOfGroupBadges);
    print("sum of group badges: {d}\n", .{score_badges});
}

fn sumPriorityOfMisplacedItems(input_line: []const u8, _: usize) !i32 {
    if (input_line.len % 2 != 0) {
        print("Item line not divisible by two.\n", .{});    
        return DataParseError.InvalidLineLength;
    }
    const compartment_len = input_line.len / 2;
    const compartment1_str = input_line[0..compartment_len];
    const compartment2_str = input_line[compartment_len..];
    var compartment1 = try ItemSet.initWithString(compartment1_str);
    var compartment2 = try ItemSet.initWithString(compartment2_str);
    const same_item = ItemSet.initWithOnlySameItems(compartment1, compartment2).itemPriority();
    return same_item;
}

fn sumPriorityOfGroupBadges(group_lines: [ELF_GROUP_SIZE][]const u8, _: usize) !i32 {
    var rucksacks: [ELF_GROUP_SIZE]ItemSet = undefined;
    for (group_lines) |line, line_i| {
        rucksacks[line_i] = try ItemSet.initWithString(line);
    }
    
    var common_badge = ItemSet.initWithOnlySameItems(rucksacks[0], rucksacks[1]);
    common_badge = ItemSet.initWithOnlySameItems(common_badge, rucksacks[2]);
    const common_badge_priority = common_badge.itemPriority();
    return common_badge_priority;
}

fn priorityFromCharacter(char: u8) !u6 {
    var char_value = @intCast(i32, char);
    if (char_value >= 'A' and char_value <= 'Z') {
        const priority_value = 27 + (char_value - 'A');
        return @intCast(u6, priority_value);
    } else if (char_value >= 'a' and char_value <= 'z') {
        const priority_value = 1 + (char_value - 'a');
        return @intCast(u6, priority_value);
    } else {
        return DataParseError.UnknownCharacter;
    }
}