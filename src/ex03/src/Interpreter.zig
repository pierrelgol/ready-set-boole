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

pub fn evalFormula(self: *Interpreter, formula: []const u8) !void {
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
            try Ast.printNode(allocator, root);
        }
    }
}
