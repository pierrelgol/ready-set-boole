const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Lexer = @This();

items: []const u8 = undefined,
pos: usize = 0,

pub fn init(items: []const u8) Lexer {
    return .{
        .items = items,
        .pos = 0,
    };
}

pub fn next(self: *Lexer) ?Token {
    if (self.pos >= self.items.len) return null;
    defer self.pos += 1;
    return switch (self.items[self.pos]) {
        '0', '1' => .{ .kind = .boolean, .value = self.items[self.pos] },
        else => .{ .kind = .operator, .value = self.items[self.pos] },
    };
}

pub const Token = struct {
    kind: Kind,
    value: u8,

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("[{s}:{s}]", .{ @tagName(self.kind), self.value });
    }
};

pub const Kind = enum {
    boolean,
    operator,
};
