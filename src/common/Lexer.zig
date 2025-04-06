const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Token = @import("Token.zig").Token;

pub const Lexer = struct {
    inputs: []const u8,
    tokens: []Token,

    pub const Error = error{ InvalidExpression, InvalidCharacter } || mem.Allocator.Error || Token.Error;

    pub fn init(gpa: mem.Allocator, inputs: []const u8) Error!Lexer {
        return .{
            .inputs = inputs,
            .tokens = try gpa.alloc(Token, inputs.len),
        };
    }

    pub fn deinit(self: *Lexer, gpa: mem.Allocator) void {
        gpa.free(self.tokens);
    }

    pub fn lex(lexer: *Lexer) Error![]const Token {
        for (lexer.inputs, 0..) |input, index| {
            switch (input) {
                'A'...'Z' => |variable| lexer.tokens[index] = try Token.init(.variable, variable),
                '0', '1' => |value| lexer.tokens[index] = try Token.init(.value, value),
                '!', '&', '|', '^', '>', '=' => |binary_op| lexer.tokens[index] = try Token.init(.operator, binary_op),
                else => return Error.InvalidCharacter,
            }
        }

        return try lexer.validateRpn(lexer.tokens);
    }

    pub fn validateRpn(_: *Lexer, tokens: []const Token) Error![]const Token {
        if (tokens.len == 0) {
            return Error.InvalidExpression;
        }
        var virtual_stack_size: usize = 0;

        for (tokens) |token| {
            switch (token) {
                .variable, .value => virtual_stack_size += 1,
                .operator => |op| switch (op) {
                    .negation => if (virtual_stack_size < 1) return Error.InvalidExpression,
                    else => if (virtual_stack_size < 2) return Error.InvalidExpression,
                },
            }
        }

        return tokens;
    }

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        for (self.tokens) |token| {
            try writer.print("{}", .{token});
        }
    }
};

test Lexer {
    const gpa = std.testing.allocator;
    var lexer = try Lexer.init(gpa, "01|0^A&B!C^D=E>F&G!H|I&J!K|L&M^N!O|P&Q^R>S=T!U=V^W>X=Y!Z&");
    defer lexer.deinit(gpa);

    const tokens = try lexer.lex();
    std.debug.print("{}\n", .{lexer});
    _ = tokens;
}
