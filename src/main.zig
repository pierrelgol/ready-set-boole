const std = @import("std");
const root = @import("root.zig");
const Interpreter = root.Interpreter;
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
    _ = gpa;

    // var eval = try Interpreter.init(gpa);
    // defer eval.deinit();

    // while (true) {
    //     try eval.dynamicEval();
    // }
}
