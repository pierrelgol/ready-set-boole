const std = @import("std");
const root = @import("../root.zig");
const Token = root.Token;
const TokenKind = root.TokenKind;
const Lexer = root.Lexer;
const Parser = root.Parser;
const Ast = root.Ast;
const AstNode = root.AstNode;
const AstNodeKind = root.AstNode.Kind;
const EnumMap = std.EnumMap;
const Variable = TokenKind.Variable;

pub const TruthTable = struct {
    symbol_table: EnumMap(Variable, bool),
};
