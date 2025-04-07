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

const testing = std.testing;

test "fuzz test1" {
    const Context = struct {
        fn testOne(_: @This(), input: []const u8) anyerror!void {
            const gpa = testing.allocator;

            var lexer = Lexer.init(gpa, input) catch return;
            defer lexer.deinit(gpa);
            _ = lexer.lex() catch return;
        }
    };

    try std.testing.fuzz(Context{}, Context.testOne, .{
        .corpus = &.{
            "0!0>1000!>=0110>0>&110>1=01&00>|110001110^>000&>|=11011^^110|0=0>0",
            "011111>!000&001>&1>10^0001^101|111>0^&=^1001^0&&!^0!>!1!0>1&00",
            "^1>0100!>0110=01&111>0101^|0110&1=01&110&!&01>^=10&1^>=111=0^==&11",
            "=&0!000!1000110^110>1^1010^0&!!011=10=1|1!=^11&00000!^=0&!0110",
            "010!!010>|>>|1|101^110101^0=11&&00^10!11>!0^|1000^10100=0111100001",
            ">111^0001|0=00&1010=|0000010101&1>|001111||100011!0000^&1^11=0",
            "|0011000|^11!0=00>>00=11!10>&|1101&100=&01=00=|010^=000&1^1!11!|0!",
            "110001100|^101000111100=!>01&|0101110!=01|&^1=1=000110=01001>=",
            "^1&111=0&10|1&0^&011000|=|11010>|>010!11!01100|!100>0001^|0011!11|",
            "110!00011>|000^1^1^00|1!00>1>=1^1||1!=!1!=1=0|0001!0!1=001^&0=",
            ">1|0&00000&|1111!=1&011=|010=!1100^10001011=11^111!^101010^^1010=1",
            "100000&0=&|1!|101!010!1101&1000101!1101^>&010000|!==!&|&0>!110",
            "101>0000&&1111>0|&00>>00100!10&&11&11>1^00010!0&!01^^=0|1000!111!=",
            "|01=|>!!>1|111!0!1011&1!1^1110|0&00>00000^1101101^>10&0|1>=||0",
            "|10=&00^&|0001|010^0111^00000|0!11001=100^001&0000=01&00010010!1!&",
            "0!010|0=>1111001|11!101111!0001110!&|1>&0010110001^=11111^0&=0",
            "^!011>00^11110=0>1^011000=010010>01>01!&&111^0=01!&0&0&0>11101&|10",
            "1111^&110&^=>1!|10!>10&1==11!1&0^1&!^&110|1&!1^!11000>01!!|&10",
        },
    });
}
