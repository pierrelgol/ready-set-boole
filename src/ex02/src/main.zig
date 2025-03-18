const std = @import("std");

fn GrayTable(comptime n: usize) type {
    if (n == 0) @compileError("0 sized types are not supported");
    if (n >= 16) @compileError("n sized types above or equal 16 are not supported");
    return struct {
        const Self = @This();
        const State = std.math.pow(u16, 2, n) - 1;
        pub const IntegerType = std.math.IntFittingRange(0, State);
        pub const Length = std.math.maxInt(IntegerType);
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
fn binaryToGray(comptime n: u32) u32 {
    return n ^ (n >> 1);
}

fn grayToBinary(comptime n: u32) u32 {
    var nb = n;
    nb ^= nb >> 16;
    nb ^= nb >> 8;
    nb ^= nb >> 4;
    nb ^= nb >> 2;
    nb ^= nb >> 1;
    return nb;
}

const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var buffer: [std.heap.pageSize()]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(buffer[0..]);
    const allocator = fba.allocator();
    const table = GrayTable(15){};
    while (true) {
        const number = stdin.readUntilDelimiterAlloc(allocator, '\n', 6) catch continue;
        const num = std.fmt.parseUnsigned(u16, number, 10) catch 0;
        std.debug.print("integer : {d:>6} | gray : {d:>6} \n", .{ num, table.get(num) });
    }
}
