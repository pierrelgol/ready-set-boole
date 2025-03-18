const std = @import("std");

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const Evaluator = struct {
    buffer: []u8 = undefined,
    len: u8 = 0,

    pub fn init(buffer: []u8) Evaluator {
        return .{
            .buffer = buffer,
            .len = 0,
        };
    }

    pub fn eraseAll(self: *Evaluator) !void {
        for (0..self.len) |_| {
            try stdout.print("\x08 \x08", .{});
        }
        self.len = 0;
    }

    pub fn readUntilDelimiter(self: *Evaluator, delimiter: u8) ?[]const u8 {
        self.eraseAll() catch return null;
        std.debug.print("$> ", .{});
        while (self.len < self.buffer.len) {
            const byte = stdin.readByte() catch return self.buffer[0..self.len];
            if (byte == delimiter) {
                break;
            }
            if (byte == std.ascii.control_code.del and self.len != 0) {
                stdout.print("\x08 \x08", .{}) catch return null;
            } else {
                self.buffer[self.len] = byte;
                stdout.print("{c}", .{byte}) catch return null;
            }
        }
        return self.buffer[0..self.len];
    }
};

pub fn main() !void {
    var buffer: [32]u8 = undefined;
    var eval: Evaluator = .init(buffer[0..]);

    while (eval.readUntilDelimiter('\n')) |item| {
        std.debug.print("{s}\n", .{item});
    }
}
