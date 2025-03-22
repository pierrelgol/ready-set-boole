const std = @import("std");
const Interpreter = @import("Interpreter.zig");

comptime {
    std.testing.refAllDeclsRecursive(Interpreter);
}
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var buffer: [std.heap.pageSize()]u8 = undefined;
    var fba_instance: std.heap.FixedBufferAllocator = .init(buffer[0..]);
    const fba = fba_instance.allocator();

    var args = std.process.argsWithAllocator(fba) catch |err| {
        std.log.err("Fatal error : {!}", .{err});
        return;
    };
    defer args.deinit();

    if (!args.skip()) {
        std.log.err("Fatal error : Missing Arguments", .{});
        return;
    }

    var interpreter: Interpreter = .init(buffer[0..]);
    while (args.next()) |arg| {
        std.debug.print("\n", .{});
        const result = interpreter.evalFormula(arg, true) catch |err| {
            std.log.err("Fatal error : {!}", .{err});
            return;
        };
        std.debug.print("{s} --> {}", .{ arg, result });
    }
}
