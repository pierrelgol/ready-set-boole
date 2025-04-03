const std = @import("std");
const Adder = @This();

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
