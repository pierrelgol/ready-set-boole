const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const testing = std.testing;
const Ast = root.Ast.Ast;

const root = @import("../root.zig");

pub const Evaluator = struct {
    interpreter: root.Interpreter,
    ast: ?Ast,

    pub fn init(gpa: mem.Allocator) Evaluator {
        return .{
            .interpreter = root.Interpreter.init(gpa),
            .ast = null,
        };
    }

    pub fn deinit(self: *Evaluator) void {
        self.interpreter.deinit();
    }

    pub fn evalFormula(self: *Evaluator, formula: []const u8) !bool {
        self.ast = try self.interpreter.eval(formula);
        return try self.evalExpression();
    }

    pub fn evalExpression(self: *Evaluator) error{InvalidExpression}!bool {
        if (self.ast) |ast| {
            return try evalNode(ast.root orelse return error.InvalidExpression);
        }
        return error.InvalidExpression;
    }

    fn evalNode(node: *root.AstNode) error{InvalidExpression}!bool {
        return switch (node.getNodeKind()) {
            .leaf => evalLeaf(node),
            .unary => evalUnary(node),
            .binary => evalBinary(node),
        };
    }

    fn evalLeaf(node: *root.AstNode) error{InvalidExpression}!bool {
        const token = node.getToken();
        return switch (token) {
            .value => (token.value == .true),
            .variable => error.InvalidExpression,
            .operator => error.InvalidExpression,
        };
    }

    fn evalUnary(node: *root.AstNode) error{InvalidExpression}!bool {
        const token = node.getToken();
        return switch (token) {
            .value => error.InvalidExpression,
            .variable => error.InvalidExpression,
            .operator => |op| result: {
                switch (op) {
                    .negation => break :result !(try evalNode(node.lhs.?)),
                    else => break :result error.InvalidExpression,
                }
            },
        };
    }

    fn evalBinary(node: *root.AstNode) error{InvalidExpression}!bool {
        const token = node.getToken();
        return switch (token) {
            .value => error.InvalidExpression,
            .variable => error.InvalidExpression,
            .operator => |op| result: {
                switch (op) {
                    .conjunction => break :result (try evalNode(node.lhs.?) and try evalNode(node.rhs.?)),
                    .disjunction => break :result (try evalNode(node.lhs.?) or try evalNode(node.rhs.?)),
                    .exclusive_disjunction => break :result (try evalNode(node.lhs.?) != try evalNode(node.rhs.?)),
                    .material_condition => break :result ((!try evalNode(node.lhs.?)) or try evalNode(node.rhs.?)),
                    .logical_equivalence => break :result (try evalNode(node.lhs.?) == try evalNode(node.rhs.?)),
                    .negation => break :result error.InvalidExpression,
                }
            },
        };
    }
};

test Evaluator {
    const gpa = testing.allocator;

    var interpreter = Evaluator.init(gpa);
    defer interpreter.deinit();

    const result = try interpreter.evalFormula("11&");
    std.debug.print("Formula : {s}\nEvaluate : {s}\nAst : {?}\n", .{ "10&", if (result) "True" else "False", interpreter.ast });
}
