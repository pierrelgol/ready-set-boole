const std = @import("std");

pub fn add(a: u1024, b: u1024) u1024 {
    var carry: u32 = a & b;
    var result: u32 = a ^ b;
    while (carry != 0) {
        const new_carry = carry << 1;
        carry = result & new_carry;
        result ^= new_carry;
    }
    return result;
}

test add {
    var random_generator = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = random_generator.random();

    const test_number = random.uintAtMost(u16, std.math.maxInt(u16));
    for (0..test_number) |_| {
        const num1 = random.uintAtMost(u32, std.math.maxInt(u32));
        const num2 = random.uintAtMost(u32, std.math.maxInt(u32));
        try std.testing.expect(add(num1, num2) == (num1 +% num2));
    }
}
const add_visual =
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
pub fn main() !void {
    var buffer: [std.heap.pageSize()]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(buffer[0..]);
    const allocator = fba.allocator();
    _ = allocator;

    const stdin = std.io.getStdIn().reader();
    _ = stdin;
    const stdout = std.io.getStdOut().writer();

    const a: u32 = 25;
    const b: u32 = 30;
    var carry: u32 = a & b;
    var result: u32 = a ^ b;
    var new_carry: u32 = 0;
    try stdout.print(add_visual, .{ a, b, carry, a, b, result, a, b, carry, new_carry, carry, carry, result, new_carry, result, new_carry, result });
    while (carry != 0) {
        new_carry = carry << 1;
        carry = result & new_carry;
        result ^= new_carry;
        try stdout.print(add_visual, .{ a, b, carry, a, b, result, a, b, carry, new_carry, carry, carry, result, new_carry, result, new_carry, result });
    }
}
