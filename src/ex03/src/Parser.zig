// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   Parser.zig                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2025/03/22 09:15:27 by pollivie          #+#    #+#             //
//   Updated: 2025/03/22 09:15:28 by pollivie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

const std = @import("std");
const mem = std.mem;
const Lexer = @import("Lexer.zig");
const Token = Lexer.Token;
const Parser = @This();
const Ast = @import("Ast.zig");
const Node = Ast.Node;
const Stack = @import("Stack.zig").StackUnamanaged;
pub const Error = error{} || Ast.Error;

gpa: mem.Allocator,
tokens: []const Token,
pos: usize,
stack: Stack(*Node),
ast: Ast,

pub fn init(gpa: mem.Allocator, tokens: []const Token) Parser {
    return .{
        .gpa = gpa,
        .tokens = tokens,
        .pos = 0,
        .ast = Ast.init(gpa),
        .stack = Stack(*Node).empty,
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
pub fn parse(self: *Parser) !?Ast {
    if (self.tokens.len == 0) return null;

    while (self.next()) |token| {
        const node = try self.ast.makeNode(token);
        switch (token) {
            .boolean => try self.stack.push(self.gpa, node),
            .operator => {
                node.rhs = self.stack.pop();
                node.lhs = self.stack.pop();
                try self.stack.push(self.gpa, node);
            },
            .invalid => {
                std.debug.print("syntax error on token : {}", .{token});
                return error.SyntaxError;
            },
        }
    }
    self.ast.root = self.stack.pop();
    return self.ast;
}

fn next(self: *Parser) ?Token {
    if (self.pos >= self.tokens.len) return null;
    defer self.pos += 1;
    return self.tokens[self.pos];
}

pub fn deinit(self: *Parser) void {
    self.ast.deinit();
    self.stack.deinit(self.gpa);
}
