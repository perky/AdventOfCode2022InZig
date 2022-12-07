const std = @import("std");
const print = std.debug.print;
const data = @embedFile("data/day06.txt");

fn RingBuffer(comptime T: type, comptime N: usize) type {
    return struct {
        items: [N]T = undefined,
        capacity: usize = N,
        cursor: usize = 0,
        put_count: usize = 0,
        const Self = @This();

        pub fn next(self: *Self) T {
            const result: T = self.items[self.cursor];
            self.cursor += 1;
            if (self.cursor == N) {
                self.cursor = 0;
            }
            return result;
        }

        pub fn put(self: *Self, item: T) void {
            self.items[self.cursor] = item;
            self.put_count += 1;
            _ = self.next();
        }

        pub fn get(self: Self) T {
            return self.items[self.cursor];
        }
    };
}

fn doesSliceContainDuplicate(comptime T: type, items: []T) bool {
    for (items) |item_0, i_0| {
        for (items) |item_1, i_1| {
            if (i_0 == i_1) continue;
            if (item_0 == item_1) {
                return true;
            }
        }       
    }
    return false;
}

fn findMarkerInByteStream(stream_buffer: anytype, comptime print_msg: []const u8) void {
    for (data) |byte, byte_i| {
        stream_buffer.put(byte);
        if (stream_buffer.put_count >= stream_buffer.capacity) {
            var b_found_same = doesSliceContainDuplicate(u8, stream_buffer.items[0..]);
            if (!b_found_same) {
                print("{s}\n", .{print_msg});
                print("Found sequence with no duplicate starting at index: {d}.\n", .{byte_i});
                print("Processed {d} bytes.\n", .{stream_buffer.put_count});
                break;
            }
        }
    }
}

const PacketMarkerRingBuffer = RingBuffer(u8, 4);
const MessageMarkerRingBuffer = RingBuffer(u8, 14);

pub fn main() !void {
    var packet_marker_stream_buffer = PacketMarkerRingBuffer {};
    findMarkerInByteStream(&packet_marker_stream_buffer, "start-of-packet marker...");

    var message_marker_stream_buffer = MessageMarkerRingBuffer {};
    findMarkerInByteStream(&message_marker_stream_buffer, "start-of-message marker...");
}
