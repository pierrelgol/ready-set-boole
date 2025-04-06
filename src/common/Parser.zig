const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Token = @import("Token.zig").Token;
const AstNode = @import("AstNode.zig").AstNode;
const Stack = @import("Stack.zig").StackUnmanaged;
const Ast = @import("Ast.zig").Ast;
const assert = std.debug.assert;

pub const Parser = struct {
    inputs: []const Token,
    ast: Ast,

    pub const Error = error{InvalidExpression} || mem.Allocator.Error;

    pub fn init(gpa: mem.Allocator, inputs: []const Token) Error!Parser {
        return .{
            .inputs = inputs,
            .ast = try Ast.init(gpa, inputs.len),
        };
    }

    pub fn deinit(self: *Parser) void {
        self.ast.deinit();
    }

    pub fn parse(self: *Parser, gpa: mem.Allocator) Error!Ast {
        errdefer self.ast.deinit();

        var stack: Stack(*AstNode) = .empty;
        defer stack.deinit(gpa);

        var lhs: ?*AstNode = null;
        var rhs: ?*AstNode = null;

        for (self.inputs) |token| {
            const node = try self.ast.makeNode();
            switch (token) {
                .value, .variable => {
                    node.* = AstNode.initLeaf(token);
                },
                .operator => |op| {
                    if (op.isBinary()) {
                        rhs = stack.pop();
                        lhs = stack.pop();
                        node.* = AstNode.initBinary(token, lhs, rhs);
                    } else {
                        lhs = stack.pop();
                        node.* = AstNode.initUnary(token, lhs);
                    }
                },
            }
            try stack.push(gpa, node);
        }

        self.ast.root = stack.pop();
        return self.ast;
    }

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("inputs : \n", .{});
        for (self.inputs, 0..) |token, idx| {
            const is_last: bool = idx == (self.inputs.len -| 1);
            if (is_last)
                try writer.print("{}\n", .{token})
            else
                try writer.print("{},", .{token});
        }
        try writer.print("Ast : \n{}\n", .{self.ast});
    }
};

test Parser {
    const gpa = std.testing.allocator;

    var tokens = [_]Token{
        Token{ .value = .true },
        Token{ .value = .false },
        Token{ .operator = .conjunction },
        Token{ .value = .false },
        Token{ .operator = .disjunction },
        Token{ .value = .true },
        Token{ .operator = .exclusive_disjunction },
        Token{ .operator = .negation },
    };

    var parser = try Parser.init(gpa, tokens[0..]);
    defer parser.deinit();

    _ = try parser.parse(gpa);
    std.debug.print("{}\n", .{parser});
}
