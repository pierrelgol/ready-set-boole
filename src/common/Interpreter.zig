const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Interpreter = @This();

const Ast = @import("Ast.zig");
const Repl = @import("Repl.zig");
const Token = @import("Token.zig").Token;
const Lexer = @import("Lexer.zig");
const Stack = @import("Stack.zig").StackUnmanaged;

gpa: mem.Allocator,
ast: Ast,
repl: Repl,

pub fn init(gpa: mem.Allocator) !Interpreter {
    return .{
        .gpa = gpa,
        .ast = try Ast.init(gpa, .{}),
        .repl = Repl.init(gpa, "ready@set@boole >> "),
    };
}

pub fn staticEval(self: *Interpreter, input: []const u8) !Ast {
    var lex = Lexer.init(input);
    var list: std.ArrayListUnmanaged(Token) = .empty;
    defer list.deinit(self.gpa);

    var stack: Stack(*Ast.Node) = .init();
    defer stack.deinit(self.gpa);

    while (try lex.nextToken()) |token| {
        try list.append(self.gpa, token);
    }

    for (list.items) |token| {
        const node = try self.getNodeForToken(token);
        switch (token) {
            .value, .variable => try stack.push(
                self.gpa,
                node,
            ),
            .operator => |op| {
                if (op == .negation) {
                    node.unary.child = stack.pop(self.gpa);
                } else {
                    node.binary.rhs = stack.pop(self.gpa);
                    node.binary.lhs = stack.pop(self.gpa);
                }
                try stack.push(self.gpa, node);
            },
        }
    }

    self.ast.root = stack.pop(self.gpa);
    try self.repl.println("{}", .{self.ast});
    try self.repl.println("{s}", .{self.evalExpression()});
    return self.ast;
}

fn evalExpression(self: *Interpreter) []const u8 {
    if (self.ast.root) |root| {
        return if (evalNode(root) == true) "True" else "False";
    } else {
        return "Error";
    }
}

fn evalNode(node: *Ast.Node) bool {
    const tok = switch (node.*) {
        .leaf => node.leaf.tok,
        .unary => node.unary.tok,
        .binary => node.binary.tok,
    };

    return switch (tok) {
        .operator => |op| if (op == .negation) evalUnaryNode(node) else evalBinaryNode(node),
        .value, .variable => evalLeafNode(node),
    };
}

fn evalLeafNode(node: *Ast.Node) bool {
    return switch (node.leaf.tok) {
        .value => |b| b.value,
        .variable => |v| v.value,
        .operator => unreachable,
    };
}

fn evalUnaryNode(node: *Ast.Node) bool {
    return !evalNode(node.unary.child.?);
}

fn evalBinaryNode(node: *Ast.Node) bool {
    var left: bool = undefined;
    var right: bool = undefined;
    return switch (node.binary.tok.operator) {
        .conjunction => result: {
            if (node.binary.lhs) |lhs| {
                left = evalNode(lhs);
            }
            if (node.binary.rhs) |rhs| {
                right = evalNode(rhs);
            }
            break :result (left and right);
        },
        .disjunction => result: {
            if (node.binary.lhs) |lhs| {
                left = evalNode(lhs);
            }
            if (node.binary.rhs) |rhs| {
                right = evalNode(rhs);
            }
            break :result (left or right);
        },
        .exclusive_disjunction => result: {
            if (node.binary.lhs) |lhs| {
                left = evalNode(lhs);
            }
            if (node.binary.rhs) |rhs| {
                right = evalNode(rhs);
            }
            break :result (left != right);
        },
        .material_condition => result: {
            if (node.binary.lhs) |lhs| {
                left = evalNode(lhs);
            }
            if (node.binary.rhs) |rhs| {
                right = evalNode(rhs);
            }
            break :result (!left) or right;
        },
        .logical_equivalence => result: {
            if (node.binary.lhs) |lhs| {
                left = evalNode(lhs);
            }
            if (node.binary.rhs) |rhs| {
                right = evalNode(rhs);
            }
            break :result left == right;
        },
        .negation => unreachable,
    };
}

pub fn getNodeForToken(self: *Interpreter, token: Token) !*Ast.Node {
    return switch (token) {
        .operator => |op| if (op == .negation) try self.ast.makeUnaryNode(token) else try self.ast.makeBinaryNode(token),
        else => try self.ast.makeLeafNode(token),
    };
}

pub fn dynamicEval(self: *Interpreter) !void {
    while (try self.repl.readline(null)) |line| {
        defer self.gpa.free(line);
        try self.repl.addHistory(line);
        _ = try self.staticEval(line);
    }
}

pub fn clear(self: *Interpreter) !void {
    self.ast.deinit();
    self.ast = try Ast.init(self.gpa, .{});
}

pub fn deinit(self: *Interpreter) void {
    self.ast.deinit();
    self.repl.deinit();
}
