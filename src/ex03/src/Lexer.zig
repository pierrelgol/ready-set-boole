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
    return switch (self.items[self.pos]) {
        '0'...'1' => self.boolean(),
        '!', '&', '|', '^', '>', '=' => self.operator(),
        else => self.invalid(),
    };
}

pub fn boolean(self: *Lexer) Token {
    defer self.pos += 1;
    return switch (self.items[self.pos]) {
        '0' => .{ .boolean = false },
        '1' => .{ .boolean = true },
        else => unreachable,
    };
}

pub fn operator(self: *Lexer) Token {
    defer self.pos += 1;
    return switch (self.items[self.pos]) {
        '!' => .{ .operator = '!' },
        '&' => .{ .operator = '&' },
        '|' => .{ .operator = '|' },
        '^' => .{ .operator = '^' },
        '>' => .{ .operator = '>' },
        '=' => .{ .operator = '=' },
        else => unreachable,
    };
}

pub fn invalid(self: *Lexer) Token {
    defer self.pos += 1;
    return .{ .invalid = self.items[self.pos] };
}

pub const Token = union(Kind) {
    boolean: bool,
    operator: u8,
    invalid: u8,

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        switch (self) {
            .boolean => try writer.print("'{c}'", .{if (self.boolean) @as(u8, '1') else @as(u8, '0')}),
            .invalid => try writer.print("'{c}'", .{self.invalid}),
            .operator => try writer.print("'{c}'", .{self.operator}),
        }
    }
};

pub const Kind = enum {
    boolean,
    operator,
    invalid,
};
