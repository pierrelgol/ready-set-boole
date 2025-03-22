// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   Interpreter.zig                                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2025/03/22 10:50:15 by pollivie          #+#    #+#             //
//   Updated: 2025/03/22 10:50:15 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Interpreter = @This();
const Lexer = @import("Lexer.zig");
const Parser = @import("Parser.zig");
const Ast = @import("Ast.zig");

fba: heap.FixedBufferAllocator,

pub fn init(buffer: []u8) Interpreter {
    return .{
        .fba = heap.FixedBufferAllocator.init(buffer[0..]),
    };
}

//Symbol | Mathematical equivalent | Description
//  0    |             ⊥           | false
//  1    |             ⊤           | true
//  !    |             ¬           | Negation
//  &    |             ∧           | Conjunction
//  |    |             ∨           | Disjunction
//  ˆ    |             ⊕           | Exclusive disjunction
//  >    |             ⇒           | Material condition
//  =    |             ⇔           | Logical equivalence

pub fn evalFormula(self: *Interpreter, formula: []const u8, print_ast: bool) !bool {
    defer self.fba.reset();
    const allocator = self.fba.allocator();

    var lex: Lexer = .init(formula[0..]);
    var tokens_list: std.ArrayListUnmanaged(Lexer.Token) = .empty;
    var token_count: usize = 0;
    while (lex.next()) |token| : (token_count += 1) {
        try tokens_list.append(allocator, token);
    }
    std.debug.print("\n", .{});
    var parser: Parser = .init(allocator, tokens_list.items[0..token_count]);
    defer parser.deinit();

    const maybe_ast = try parser.parse();
    if (maybe_ast) |ast| {
        if (ast.root) |root| {
            if (print_ast)
                try Ast.printNode(allocator, root);
            const result = evalNode(root);
            // std.debug.print("Formula : {s} --> {s}\n", .{ formula, if (result) "True" else "False" });
            return result;
        }
    }
    return error.EmptyExpression;
}

pub fn evalNode(node: *Ast.Node) bool {
    switch (node.token) {
        .boolean => |b| return b,
        .operator => |op| {
            return switch (op) {
                '!' => result: {
                    var right: bool = undefined;
                    if (node.rhs) |rhs| {
                        right = evalNode(rhs);
                    }
                    break :result !right;
                },
                '&' => result: {
                    var left: bool = undefined;

                    if (node.lhs) |lhs| {
                        left = evalNode(lhs);
                    }

                    var right: bool = undefined;
                    if (node.rhs) |rhs| {
                        right = evalNode(rhs);
                    }
                    break :result (left and right);
                },
                '|' => result: {
                    var left: bool = undefined;

                    if (node.lhs) |lhs| {
                        left = evalNode(lhs);
                    }

                    var right: bool = undefined;
                    if (node.rhs) |rhs| {
                        right = evalNode(rhs);
                    }
                    break :result (left or right);
                },
                '^' => result: {
                    var left: bool = undefined;

                    if (node.lhs) |lhs| {
                        left = evalNode(lhs);
                    }

                    var right: bool = undefined;
                    if (node.rhs) |rhs| {
                        right = evalNode(rhs);
                    }
                    break :result !(left or right);
                },
                '>' => result: {
                    var left: bool = undefined;

                    if (node.lhs) |lhs| {
                        left = evalNode(lhs);
                    }

                    var right: bool = undefined;
                    if (node.rhs) |rhs| {
                        right = evalNode(rhs);
                    }
                    break :result (!left) or right;
                },
                '=' => result: {
                    var left: bool = undefined;

                    if (node.lhs) |lhs| {
                        left = evalNode(lhs);
                    }

                    var right: bool = undefined;
                    if (node.rhs) |rhs| {
                        right = evalNode(rhs);
                    }
                    break :result left == right;
                },
                else => unreachable,
            };
        },
        else => unreachable,
    }
}

var PRINT_AST: bool = true;

test "0" {
    var buffer: [std.heap.pageSize()]u8 = undefined;
    var interpreter: Interpreter = .init(buffer[0..]);
    try std.testing.expect(try interpreter.evalFormula("10&", PRINT_AST) == false);
}

test "1" {
    var buffer: [std.heap.pageSize()]u8 = undefined;
    var interpreter: Interpreter = .init(buffer[0..]);
    try std.testing.expect(try interpreter.evalFormula("10|", PRINT_AST) == true);
}

test "2" {
    var buffer: [std.heap.pageSize()]u8 = undefined;
    var interpreter: Interpreter = .init(buffer[0..]);
    try std.testing.expect(try interpreter.evalFormula("11>", PRINT_AST) == true);
}

test "3" {
    var buffer: [std.heap.pageSize()]u8 = undefined;
    var interpreter: Interpreter = .init(buffer[0..]);
    try std.testing.expect(try interpreter.evalFormula("10=", PRINT_AST) == false);
}

test "4" {
    var buffer: [std.heap.pageSize()]u8 = undefined;
    var interpreter: Interpreter = .init(buffer[0..]);
    try std.testing.expect(try interpreter.evalFormula("1011||=", PRINT_AST) == true);
}
