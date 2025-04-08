const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const testing = std.testing;
const root = @import("../root.zig");
const Ast = root.Ast;
const Token = root.Token;
const Variable = root.TokenKind.Variable;
const EnumMap = std.EnumMap;

pub const AstEvaluator = struct {
    variables: EnumMap(Variable, bool),
    root: *root.AstNode,

    pub fn init(node: *root.AstNode, variables: EnumMap(Variable, bool)) AstEvaluator {
        return .{
            .root = node,
            .variables = variables,
        };
    }

    pub fn eval(self: *AstEvaluator) error{InvalidExpression}!bool {
        return try self.evalNode(self.root);
    }

    fn substituteVariable(self: *const AstEvaluator, token: Token) bool {
        return self.variables.getAssertContains(token.variable);
    }

    fn evalNode(self: *const AstEvaluator, node: *const root.AstNode) error{InvalidExpression}!bool {
        return switch (node.getNodeKind()) {
            .leaf => self.evalLeaf(node),
            .unary => self.evalUnary(node),
            .binary => self.evalBinary(node),
        };
    }

    fn evalLeaf(self: *const AstEvaluator, node: *const root.AstNode) error{InvalidExpression}!bool {
        const token = node.getToken();
        return switch (token) {
            .value => (token.value == .true),
            .variable => self.substituteVariable(token),
            .operator => error.InvalidExpression,
        };
    }

    fn evalUnary(self: *const AstEvaluator, node: *const root.AstNode) error{InvalidExpression}!bool {
        const token = node.getToken();
        return switch (token) {
            .value => error.InvalidExpression,
            .variable => error.InvalidExpression,
            .operator => |op| result: {
                switch (op) {
                    .negation => break :result !(try self.evalNode(node.lhs.?)),
                    else => break :result error.InvalidExpression,
                }
            },
        };
    }

    fn evalBinary(self: *const AstEvaluator, node: *const root.AstNode) error{InvalidExpression}!bool {
        const token = node.getToken();
        const lhs = node.lhs orelse return error.InvalidExpression;
        const rhs = node.rhs orelse return error.InvalidExpression;
        return switch (token) {
            .value => error.InvalidExpression,
            .variable => error.InvalidExpression,
            .operator => |op| result: {
                switch (op) {
                    .conjunction => break :result (try self.evalNode(lhs) and try self.evalNode(rhs)),
                    .disjunction => break :result (try self.evalNode(lhs) or try self.evalNode(rhs)),
                    .exclusive_disjunction => break :result (try self.evalNode(lhs) != try self.evalNode(rhs)),
                    .material_condition => break :result ((!try self.evalNode(lhs)) or try self.evalNode(rhs)),
                    .logical_equivalence => break :result (try self.evalNode(lhs) == try self.evalNode(rhs)),
                    .negation => break :result error.InvalidExpression,
                }
            },
        };
    }
};
