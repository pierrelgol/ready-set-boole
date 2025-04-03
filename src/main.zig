const std = @import("std");
const root = @import("root.zig");
const testing = std.testing;

comptime {
    testing.refAllDecls(@import("root.zig"));
    testing.refAllDecls(@import("ex00/Adder.zig"));
    testing.refAllDecls(@import("ex01/Multiplier.zig"));
    testing.refAllDecls(@import("ex02/GrayCode.zig"));
}

pub fn main() !void {
    var gpa_instance: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa_instance.deinit();

    const gpa = gpa_instance.allocator();
    var repl = root.Repl.init(gpa, ">> ");
    defer repl.deinit();

    while (try repl.readline(null)) |line| {
        defer repl.freeline(line);
        try repl.addHistory(line);
        try repl.println("hi pierre", .{});
    }
}
