const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Token = @import("Token.zig").Token;
const TokenKind = @import("Token.zig").Kind;

pub const AstNode = struct {
    token: Token = undefined,
    lhs: ?*AstNode = null,
    rhs: ?*AstNode = null,

    pub const empty: AstNode = .{
        .token = undefined,
        .lhs = null,
        .rhs = null,
    };

    fn init(token: Token, lhs: ?*AstNode, rhs: ?*AstNode) AstNode {
        return .{
            .token = token,
            .lhs = lhs,
            .rhs = rhs,
        };
    }

    pub fn initLeaf(token: Token) AstNode {
        return AstNode.init(token, null, null);
    }

    pub fn initUnary(token: Token, lhs: ?*AstNode) AstNode {
        return AstNode.init(token, lhs, null);
    }

    pub fn initBinary(token: Token, lhs: ?*AstNode, rhs: ?*AstNode) AstNode {
        return AstNode.init(token, lhs, rhs);
    }

    pub fn setToken(self: *AstNode, token: Token) void {
        self.*.token = token;
    }

    pub fn setLhs(self: *AstNode, lhs: ?*AstNode) void {
        self.*.lhs = lhs;
    }

    pub fn setRhs(self: *AstNode, rhs: ?*AstNode) void {
        self.*.rhs = rhs;
    }

    pub fn getToken(self: *const AstNode) Token {
        return self.token;
    }

    pub fn getTokenTag(self: *const AstNode) TokenKind {
        return self.token.tag();
    }

    pub fn getNodeKind(self: *const AstNode) Kind {
        return switch (self.getTokenTag()) {
            .value, .variable => .leaf,
            .operator => if (self.token.isUnary()) .unary else .binary,
        };
    }

    pub fn fromNodeToU8(self: *const AstNode) u8 {
        return switch (self.getToken()) {
            .value => self.token.value.u8FromValue(),
            .variable => self.token.variable.u8FromVariable(),
            .operator => self.token.operator.u8FromOperator(),
        };
    }

    pub fn isLeaf(self: *const AstNode) bool {
        return self.getNodeKind() == .leaf;
    }

    pub fn isUnary(self: *const AstNode) bool {
        return self.getNodeKind() == .unary;
    }

    pub fn isBinary(self: *const AstNode) bool {
        return self.getNodeKind() == .binary;
    }

    pub const Kind = enum { leaf, unary, binary };

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("'{c}'", .{self.fromNodeToU8()});
    }
};
