const std = @import("std");
const GrayCode = @This();

pub fn GrayTable(comptime n: usize) type {
    if (n == 0) @compileError("0 sized types are not supported");
    if (n >= 16) @compileError("n sized types above or equal 16 are not supported");
    return struct {
        const Self = @This();
        const State = std.math.pow(u16, 2, n) - 1;
        pub const IntegerType = std.math.IntFittingRange(0, State);
        pub const Length = std.math.maxInt(IntegerType) + 1;
        table: [Length]IntegerType = blk: {
            var buf: [Length]IntegerType = undefined;
            @setEvalBranchQuota(20000000);
            for (0..Length) |i| {
                buf[i] = (i ^ (i >> 1));
            }
            break :blk buf;
        },

        pub fn get(self: Self, num: anytype) IntegerType {
            return self.table[std.math.lossyCast(IntegerType, num)];
        }

        pub fn print(self: Self) void {
            for (0..Length) |i| {
                std.debug.print("{d:0>4} -> {b:0>10} : {b:0>10}\n", .{ i, i, self.table[i] });
            }
        }
    };
}

test "GrayTable generates correct Gray codes for n = 1" {
    const table1 = GrayTable(1){};
    try std.testing.expect(table1.get(0) == 0);
    try std.testing.expect(table1.get(1) == 1);
}

test "GrayTable generates correct Gray codes for n = 2" {
    const table2 = GrayTable(2){};
    try std.testing.expect(table2.get(0) == 0);
    try std.testing.expect(table2.get(1) == 1);
    try std.testing.expect(table2.get(2) == 3);
    try std.testing.expect(table2.get(3) == 2);
}

test "GrayTable generates correct Gray codes for n = 3" {
    const table3 = GrayTable(3){};
    const expected = [_]u8{ 0, 1, 3, 2, 6, 7, 5, 4 };
    for (expected, 0..) |expected_val, i| {
        try std.testing.expect(table3.get(i) == expected_val);
    }
}
