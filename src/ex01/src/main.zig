const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn multiplier(a: u32, b: u32) u32 {
    var result: u32 = 0;
    var n1: u32 = 0;
    var n2: u32 = 0;
    n1, n2 = if (a > b) .{ a, b } else .{ b, a };
    while (n2 != 0) {
        if (n2 & 1 != 0) {
            result = (result +% n1);
        }
        n1 <<= 1;
        n2 >>= 1;
    }
    return result;
}

test multiplier {
    var random_generator = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = random_generator.random();

    const test_number = random.uintAtMost(u16, std.math.maxInt(u16));
    for (0..test_number) |_| {
        const num1 = random.uintAtMost(u32, std.math.maxInt(u32));
        const num2 = random.uintAtMost(u32, std.math.maxInt(u32));
        try std.testing.expect(multiplier(num1, num2) == (num1 *% num2));
    }
}
const multiplier_visual =
    \\ pub fn multiplier({d}: u32, {d}: u32) u32 {{
    \\     var {d} : u32 = 0;
    \\     var {d} : u32 = 0;
    \\     var {d} : u32 = 0;
    \\     {d}, {d} = if ({d} > {d}) .{{ {d}, {d} }} else .{{ {d}, {d} }};
    \\     while ({b} != 0) {{
    \\         if ({b} & 1 != 0) {{
    \\             {b} = ({b} + {b});
    \\         }}
    \\         {b} <<= 1;
    \\         {b} >>= 1;
    \\     }}
    \\     return {d};
    \\ }}
;

pub fn displayOperation(a: u32, b: u32) !void {
    var result: u32 = 0;
    var n1: u32 = 0;
    var n2: u32 = 0;
    n1, n2 = if (a > b) .{ a, b } else .{ b, a };
    try stdout.print(multiplier_visual, .{ a, b, result, n1, n2, n1, n2, a, b, a, b, b, a, n2, n2, result, result, n1, n1, n2, result });
    while (n2 != 0) {
        if (n2 & 1 != 0) {
            result = (result + n1);
        }
        n1 <<= 1;
        n2 >>= 1;
        try stdout.print(multiplier_visual, .{ a, b, result, n1, n2, n1, n2, a, b, a, b, b, a, n2, n2, result, result, n1, n1, n2, result });
    }
}

pub fn main() !void {
    var buffer: [std.heap.pageSize()]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(buffer[0..]);
    const allocator = fba.allocator();
    var quit: bool = false;

    while (!quit) {
        fba.reset();
        const buff = try stdin.readUntilDelimiterAlloc(allocator, '\n', 128);
        var it = std.mem.tokenizeScalar(u8, buff[0..], ' ');
        var a: ?u32 = null;
        var b: ?u32 = null;
        while (it.next()) |token| {
            if (std.ascii.eqlIgnoreCase("quit", token)) {
                quit = true;
                break;
            } else if (a == null) {
                a = try std.fmt.parseUnsigned(u32, token, 10);
            } else {
                b = try std.fmt.parseUnsigned(u32, token, 10);
            }
        }
        std.debug.print("\x1b[2J\x1b[H", .{});
        try displayOperation(a orelse 0, b orelse 0);
        std.debug.print("\n", .{});
    }
}
