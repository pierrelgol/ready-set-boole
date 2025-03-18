const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn adder(a: u32, b: u32) u32 {
    var carry: u32 = a & b;
    var result: u32 = a ^ b;
    while (carry != 0) {
        const new_carry = carry << 1;
        carry = result & new_carry;
        result ^= new_carry;
    }
    return result;
}

test adder {
    var random_generator = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = random_generator.random();

    const test_number = random.uintAtMost(u16, std.math.maxInt(u16));
    for (0..test_number) |_| {
        const num1 = random.uintAtMost(u32, std.math.maxInt(u32));
        const num2 = random.uintAtMost(u32, std.math.maxInt(u32));
        try std.testing.expect(adder(num1, num2) == (num1 +% num2));
    }
}
const adder_visual =
    \\ pub fn add({d}: u32, {d}: u32) u32 {{
    \\     var {d}: u32 = {b} & {b};
    \\     var {d}: u32 = {b} ^ {b};
    \\     while ({d} != 0) {{
    \\         const {b} = {b} << 1;
    \\         {b} = {b} & {b};
    \\         {b} ^= {b};
    \\     }}
    \\     return {d};
    \\ }}
;

pub fn displayOperation(a: u32, b: u32) !void {
    var carry: u32 = a & b;
    var result: u32 = a ^ b;
    var new_carry: u32 = 0;
    try stdout.print(adder_visual, .{ a, b, carry, a, b, result, a, b, carry, new_carry, carry, carry, result, new_carry, result, new_carry, result });
    while (carry != 0) {
        new_carry = carry << 1;
        carry = result & new_carry;
        result ^= new_carry;
        try stdout.print(adder_visual, .{ a, b, carry, a, b, result, a, b, carry, new_carry, carry, carry, result, new_carry, result, new_carry, result });
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
