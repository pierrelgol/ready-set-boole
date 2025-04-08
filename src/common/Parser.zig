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
            .ast = try Ast.initCapacity(gpa, inputs.len),
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

const testing = std.testing;
const Lexer = @import("Lexer.zig").Lexer;

test "fuzz test1" {
    const Context = struct {
        fn testOne(_: @This(), input: []const u8) anyerror!void {
            const gpa = testing.allocator;

            const tokens = [_]Token{
                Token{ .value = .true },
                Token{ .value = .false },
                Token{ .operator = .conjunction },
                Token{ .value = .false },
                Token{ .operator = .disjunction },
                Token{ .value = .true },
                Token{ .operator = .exclusive_disjunction },
                Token{ .operator = .negation },
            };

            var lexer = Lexer.init(gpa, input) catch return;
            defer lexer.deinit(gpa);

            const tok = lexer.lex() catch tokens[0..];

            var parser = Parser.init(gpa, tok) catch return;
            defer parser.deinit();

            _ = parser.parse(gpa) catch {};
        }
    };

    try std.testing.fuzz(Context{}, Context.testOne, .{
        .corpus = &.{
            "0!0>1000!",
            "011111>!0",
            "^1>0100!>",
            "=&0!000!1",
            "010!!010>",
            ">111^0001",
            "|0011000|",
            "110001100",
            "^1&111=0&",
            "110!00011",
            ">1|0&0000",
            "100000&0=",
            "101>0000&",
            "|01=|>!!>",
            "|10=&00^&",
            "0!010|0=>",
            "^!011>00^",
            "1111^&110",
            ">=0110>",
            "0>&110",
            ">1=01&0",
            "0>|110",
            "001110^",
            ">000&>|",
            "=11011^",
            "^110|0=0>0",
            "00&001>",
            "&1>10^0001^1",
            "01|111>",
            "0^&=^1001",
            "^0&&!^0",
            "!>!1!0>1&00",
            "0110=01",
            "&111>0101^|",
            "0110&1=",
            "01&110&!&01>^=",
            "10&1^>=",
            "111=0^==&11",
            "000110^",
            "110>1^1010^",
            "0&!!011",
            "=10=1|1!=",
            "^11&000",
            "00!^=0&!0110",
            "|>>|1|1",
            "01^110101^0",
            "=11&&0",
            "0^10!11",
            ">!0^|100",
            "0^1010",
            "0=0111100001",
            "|0=00&101",
            "0=|000001010",
            "1&1>|001111||",
            "100011!",
            "0000^&",
            "1^11=0",
            "^11!0=00>>0",
            "0=11!10>&|1101&1",
            "00=&01=00=",
            "|010^=00",
            "0&1^1!11!|0!",
            "|^101000111100=!",
            ">01&|01011",
            "10!=01|&^",
            "1=1=000110=01001>=",
            "10|1&0^&011000|=",
            "|11010>|>0,",
            "10!11!011",
            "00|!100>00",
            "01^|0011!11|",
        },
    });
}
