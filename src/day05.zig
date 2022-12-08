const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const data = @embedFile("data/day05.txt");
const util = @import("util.zig");
const allocator = util.gpa;
const print = std.debug.print;

const StackList = List(u8);
const DataStream = @import("datastream.zig");

const Order = struct {
    move_quantity: i32,
    src_stack: usize,
    dst_stack: usize
};

fn parseOrder(stream: *DataStream) !Order {
    _ = stream.seekForwardToChar('m');
    _ = stream.seekForwardToNumerical();
    const move_quantity = try stream.parseInt(i32);
    _ = stream.seekForwardToNumerical();
    const src_stack = (try stream.parseInt(usize)) - 1;
    _ = stream.seekForwardToNumerical();
    const dst_stack = (try stream.parseInt(usize)) - 1;

    return Order{
        .move_quantity = move_quantity,
        .src_stack = src_stack,
        .dst_stack = dst_stack
    };
}

fn printStacks(all_stacks: *List(StackList)) void {
    for (all_stacks.items) |stack, stack_i| {
        print("{d}: ", .{stack_i});
        for (stack.items) |char| {
            print("{c} ", .{char});
        }
        print("\n", .{});
    }
    print("\n\n", .{});
}

pub fn main() !void {
    // go to the first stack numerator.
    var stream = DataStream {.data = data};
    const first_stack_pos = stream.seekForwardToChar('1');
    if (stream.isEndOfData()) {
        @panic("Unknown data.");
    }

    // count the number of stacks.
    var stack_count: i32 = 0;
    while (!stream.isNewline()) {
        _ = stream.seekForwardUntilNotChar(' ');
        stack_count += 1;
    }
    if (stack_count > 9) {
        @panic("Cannot handle more than 9 stacks.");
    }
    
    // calc the text width of all stacks.
    const end_of_stack_numbers_pos = stream.seekForwardToNextLine() - 1;
    const stacks_width = (end_of_stack_numbers_pos - first_stack_pos) + 2;

    // walk up each stack, from bottom to top, parse it into a list of u8.
    var all_stacks_crane9000 = List(StackList).init(allocator);
    var all_stacks_crane9001 = List(StackList).init(allocator);
    var crane9001_side_stack = StackList.init(allocator);
    var stack_i: u8 = 0;
    while (stack_i < stack_count) : (stack_i += 1) {
        stream.cursor = first_stack_pos - 1;
        _ = stream.seekForwardToChar('1' + stack_i);
        var stack_crane9000 = StackList.init(allocator);
        var stack_crane9001 = StackList.init(allocator);
        while(stream.cursor >= stacks_width) {
            _ = stream.seekBackward(stacks_width);
            const char = stream.getChar();
            
            if (char == ' ') break;
            try stack_crane9000.append(char);
            try stack_crane9001.append(char);
        }
        try all_stacks_crane9000.append(stack_crane9000);
        try all_stacks_crane9001.append(stack_crane9001);
    }
    printStacks(&all_stacks_crane9000);
    printStacks(&all_stacks_crane9001);
    print("== End of initial stack state. ==\n", .{});

    // parse each move order.
    var all_orders = List(Order).init(allocator);
    stream.cursor = end_of_stack_numbers_pos;
    while (!stream.isEndOfData()) {
        const order = try parseOrder(&stream);
        try all_orders.append(order);
    }

    // execute all orders.
    for (all_orders.items) |*order| {
        // Crane 9000.
        var move_quantity = order.move_quantity;
        var src_stack_crane9000 = &all_stacks_crane9000.items[order.src_stack];
        var dst_stack_crane9000 = &all_stacks_crane9000.items[order.dst_stack];
        while (move_quantity > 0) {
            if (src_stack_crane9000.items.len > 0) {
                const crate = src_stack_crane9000.pop();
                try dst_stack_crane9000.append(crate);
            } else {
                @panic("unable to move items, stack empty.");
            }
            move_quantity -= 1;
        }
        // Crane 9001.
        move_quantity = order.move_quantity;
        var src_stack_crane9001 = &all_stacks_crane9001.items[order.src_stack];
        var dst_stack_crane9001 = &all_stacks_crane9001.items[order.dst_stack];
        while (move_quantity > 0) {
            if (src_stack_crane9001.items.len > 0) {
                const crate = src_stack_crane9001.pop();
                if (move_quantity > 1) {
                    try crane9001_side_stack.append(crate);
                } else {
                    try dst_stack_crane9001.append(crate);
                }
            } else {
                @panic("unable to move items, stack empty.");
            }
            move_quantity -= 1;
        }
        while(crane9001_side_stack.items.len > 0) {
            const crate = crane9001_side_stack.pop();
            try dst_stack_crane9001.append(crate);
        }
    }

    printStacks(&all_stacks_crane9000);
    printStacks(&all_stacks_crane9001);
}
