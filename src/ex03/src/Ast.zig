const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Allocator = std.mem.Allocator;
const Lexer = @import("Lexer.zig");
const Ast = @This();
pub const Error = error{} || Allocator.Error;

arena_instance: std.heap.ArenaAllocator,
root: ?*Node = null,

pub fn init(gpa: Allocator) Ast {
    const arena_instance: std.heap.ArenaAllocator = .init(gpa);
    return .{
        .arena_instance = arena_instance,
        .root = null,
    };
}

pub fn deinit(self: *Ast) void {
    self.arena_instance.deinit();
}

pub fn makeNode(self: *Ast, token: Lexer.Token) Error!*Node {
    return try Node.create(self.arena_instance.allocator(), token);
}

pub fn printNode(arena: Allocator, node: *Node) !void {
    std.debug.print("{s}\n", .{node.token});
    var children_list = std.ArrayListUnmanaged(*Node).empty;
    if (node.lhs) |left| {
        try children_list.append(arena, left);
    }
    if (node.rhs) |right| {
        try children_list.append(arena, right);
    }
    const new_prefix = " ";
    for (children_list.items, 0..) |child, idx| {
        const is_last_child = idx == (children_list.items.len - 1);
        try printNodeInner(arena, child, new_prefix, is_last_child);
    }
}

fn printNodeInner(arena: Allocator, node: *Node, prefix: []const u8, is_last: bool) !void {
    var new_prefix: []const u8 = "";
    if (is_last) {
        std.debug.print("{s}└──{s}\n", .{ prefix, node.token });
        new_prefix = try std.mem.concat(arena, u8, &.{
            prefix,
            "   ",
        });
    } else {
        std.debug.print("{s}├──{s}\n", .{ prefix, node.token });
        new_prefix = try std.mem.concat(arena, u8, &.{
            prefix,
            "│   ",
        });
    }

    var children_list = std.ArrayListUnmanaged(*Node).empty;
    if (node.lhs) |left| {
        try children_list.append(arena, left);
    }
    if (node.rhs) |right| {
        try children_list.append(arena, right);
    }

    for (children_list.items, 0..) |child, idx| {
        const is_last_child = idx == (children_list.items.len - 1);
        try printNodeInner(arena, child, new_prefix, is_last_child);
    }
}

pub const Node = struct {
    token: Lexer.Token = undefined,
    lhs: ?*Node = null,
    rhs: ?*Node = null,

    fn create(arena: Allocator, token: Lexer.Token) Error!*Node {
        const self = try arena.create(Node);
        self.* = .{
            .lhs = null,
            .rhs = null,
            .token = token,
        };
        return self;
    }

    fn destroy(self: *Node, arena: Allocator) void {
        arena.destroy(self);
    }

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{}", .{self.token});
    }
};
