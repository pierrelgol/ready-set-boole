const std = @import("std");
const root = @import("root.zig");
const Interpreter = root.Interpreter;
const Repl = root.Repl;
const testing = std.testing;

comptime {
    testing.refAllDecls(@import("root.zig"));
    testing.refAllDecls(@import("ex00/Adder.zig"));
    testing.refAllDecls(@import("ex01/Multiplier.zig"));
    testing.refAllDecls(@import("ex02/GrayCode.zig"));
    testing.refAllDecls(@import("ex03/BooleanEvaluation.zig"));
}

pub fn main() !void {
    var gpa_instance: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa_instance.deinit();

    const gpa = gpa_instance.allocator();

    var interpreter = Interpreter.init(gpa);
    defer interpreter.deinit();

    var repl = Repl.init(gpa, ">>> ");
    defer repl.deinit();

    while (true) {
        const ast = interpreter.evalRepl(&repl) catch |err| switch (err) {
            error.CtrlC => break,
            else => {
                std.log.err("{!}", .{err});
                continue;
            },
        };
        repl.println("{}", .{ast}) catch break;
    }
}
