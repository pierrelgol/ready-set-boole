const std = @import("std");
const Lexer = @This();
const Token = @import("Token.zig").Token;

input: []const u8,
index: usize,

pub fn init(input: []const u8) Lexer {
    return .{
        .input = input,
        .index = 0,
    };
}

fn tokenize(self: *Lexer) !?Token {
    if (self.index >= self.input.len) return null;
    defer self.index += 1;
    return switch (self.input[self.index]) {
        '0' => Token.initValue(false),
        '1' => Token.initValue(true),
        '!' => Token.initOperator(.negation),
        '&' => Token.initOperator(.conjunction),
        '|' => Token.initOperator(.disjunction),
        '^' => Token.initOperator(.exclusive_disjunction),
        '>' => Token.initOperator(.material_condition),
        '=' => Token.initOperator(.logical_equivalence),
        'A'...'Z' => |c| Token.initVariable(@enumFromInt(c), null),
        else => error.SyntaxError,
    };
}

pub fn nextToken(self: *Lexer) !?Token {
    return try self.tokenize();
}
