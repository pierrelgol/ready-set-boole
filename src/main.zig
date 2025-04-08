const std = @import("std");
const testing = std.testing;

const BooleanEvaluator = @import("root.zig").BooleanEvaluator;
const root = @import("root.zig");
const Interpreter = root.Interpreter;
const Repl = root.Repl;

comptime {
    testing.refAllDecls(@import("root.zig"));
    testing.refAllDecls(@import("ex00/Adder.zig"));
    testing.refAllDecls(@import("ex01/Multiplier.zig"));
    testing.refAllDecls(@import("ex02/GrayCode.zig"));
    testing.refAllDecls(@import("ex03/BooleanEvaluation.zig"));
    testing.refAllDecls(@import("ex04/TruthTable.zig"));
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
        var evaluator = BooleanEvaluator.init(gpa);
        defer evaluator.deinit();
        evaluator.ast = interpreter.evalRepl(&repl) catch |err| switch (err) {
            error.CtrlC => break,
            else => {
                std.log.err("{!}", .{err});
                continue;
            },
        };
        repl.println("{?}", .{evaluator.ast}) catch break;
        const evaluation = evaluator.evalExpression();

        if (evaluation) |valid| {
            try repl.println("Result : {s}", .{if (valid) "True" else "False"});
        } else |err| {
            try repl.println("Error occurred : {!}", .{err});
        }
    }
}
