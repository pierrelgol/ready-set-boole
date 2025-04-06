const std = @import("std");
const mem = std.mem;
const heap = std.heap;

const Ast = @import("Ast.zig").Ast;
const AstError = Ast.Error;
const AstNode = @import("AstNode.zig").AstNode;
const AstNodeKind = AstNode.Kind;
const Lexer = @import("Lexer.zig").Lexer;
const LexerError = Lexer.Error;
const Parser = @import("Parser.zig").Parser;
const ParserError = Parser.Error;
const Token = @import("Token.zig").Token;
const TokenError = @import("Token.zig").Token.Error;
const TokenKind = @import("Token.zig").Kind;
const TokenKindError = @import("Token.zig").Kind.Error;
const Repl = @import("Repl.zig").Repl;

pub const Interpreter = struct {
    gpa: mem.Allocator,
    arena: heap.ArenaAllocator,

    pub const Error = error{EmptyLine} || mem.Allocator.Error || AstError || LexerError || ParserError || TokenError || TokenKindError;

    pub fn init(gpa: mem.Allocator) Interpreter {
        return .{
            .gpa = gpa,
            .arena = heap.ArenaAllocator.init(gpa),
        };
    }

    pub fn evalRepl(self: *Interpreter, repl: *Repl) !Ast {
        const line = try repl.readline(null) orelse return error.EmptyLine;
        defer repl.freeline(line);
        try repl.addHistory(line);

        return try self.eval(line);
    }

    pub fn eval(self: *Interpreter, inputs: []const u8) Error!Ast {
        _ = self.arena.reset(.{ .retain_with_limit = std.math.maxInt(u16) });
        const allocator = self.arena.allocator();
        var lexer = try Lexer.init(allocator, inputs);
        defer lexer.deinit(allocator);
        const tokens = try lexer.lex();
        var parser = try Parser.init(allocator, tokens);
        defer parser.deinit();
        return try parser.parse(allocator);
    }

    pub fn deinit(self: *Interpreter) void {
        self.arena.deinit();
    }
};
