const std = @import("std");
const Multiplier = @This();

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
