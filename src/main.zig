const std = @import("std");
const root = @import("root.zig");
const Interpreter = root.Interpreter.Interpreter;
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

    var interpreter = Interpreter.init(gpa);
    defer interpreter.deinit();

    while (true) {
        const ast = interpreter.eval() catch |err| switch (err) {
            error.CtrlC => break,
            else => {
                std.log.err("{!}", .{err});
                continue;
            },
        };
        interpreter.repl.println("{}", .{ast}) catch break;
    }
}
