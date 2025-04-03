const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Ast = @This();
const Token = @import("Token.zig").Token;

pub const AstOption = struct {
    print_buffer: bool = true,
    print_buffer_size: ?usize = 4096,
};

arena: heap.ArenaAllocator = undefined,
print_buffer: ?[]const u8,
root: ?*Node = null,

pub fn init(gpa: mem.Allocator, options: AstOption) !Ast {
    var arena: heap.ArenaAllocator = .init(gpa);
    errdefer arena.deinit();

    const print_buffer = if (options.print_buffer)
        try arena.allocator().alloc(u8, options.print_buffer_size)
    else
        null;

    return .{
        .arena = arena,
        .print_buffer = print_buffer,
        .root = null,
    };
}

pub fn deinit(self: *Ast) void {
    self.arena.deinit();
}

pub fn makeUnaryNode(self: *Ast, tok: ?Token) !*Node {
    const node: *Node = try self.arena.allocator().create(Node);
    node.* = Node.initUnary(tok);
    return node;
}

pub fn makeBinaryNode(self: *Ast, tok: ?Token) !*Node {
    const node: *Node = try self.arena.allocator().create(Node);
    node.* = Node.initBinary(tok);
    return node;
}

pub fn printNode(writer: anytype, buffer: *std.ArrayList(u8), node: *Node) !void {
    var children_list: [2]?*Node = .{ null, null };
    if (node.lhs) |left| {
        children_list[0] = left;
    }
    if (node.rhs) |right| {
        children_list[1] = right;
    }
    for (children_list.items, 0..) |child, idx| {
        const is_last_child = idx == (children_list.len - 1);
        try printNodeInner(writer, buffer, child, is_last_child);
    }
}

fn printNodeInner(writer: anytype, prefix: *std.ArrayList(u8), node: *Node, is_last: bool) !void {
    if (is_last) {
        writer.print("{s}└──{s}\n", .{ prefix.items[0..], node.token });
        try prefix.appendSlice("    ");
    } else {
        try writer.print("{s}├──{s}\n", .{ prefix.items[0..], node.token });
        prefix.appendSlice("|   ");
    }

    var children_list: [2]?*Node = .{ null, null };
    if (node.lhs) |left| {
        children_list[0] = left;
    }
    if (node.rhs) |right| {
        children_list[1] = right;
    }

    for (children_list.items, 0..) |child, idx| {
        const is_last_child = idx == (children_list.len - 1);
        try printNodeInner(prefix, child, is_last_child);
    }
}

pub fn format(
    self: @This(),
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = fmt;
    _ = options;

    var fba_instance: heap.FixedBufferAllocator = .init(self.print_buffer[0..]);
    const fba = fba_instance.allocator();

    var list = std.ArrayList(u8).init(fba);
    defer list.deinit();

    printNode(writer, &list, self.root orelse return);
}

pub const Kind = enum { unary, binary };

pub const Node = union(Kind) {
    unary: UnaryNode,
    binary: BinaryNode,

    pub fn initUnary(tok: ?Token) Node {
        return .{ .unary = UnaryNode.init(tok) };
    }

    pub fn initBinary(tok: ?Token) Node {
        return .{ .binary = BinaryNode.init(tok) };
    }

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        switch (std.meta.activeTag(self)) {
            .unary => try writer.print("{?}", .{self.unary.tok}),
            .binary => try writer.print("{?}", .{self.binary.tok}),
        }
    }
};

pub const UnaryNode = struct {
    tok: Token = undefined,
    child: ?*Node = null,

    pub fn init(tok: ?Token) UnaryNode {
        return .{
            .tok = tok orelse undefined,
            .child = null,
        };
    }
};

pub const BinaryNode = struct {
    tok: Token = undefined,
    lhs: ?*Node = null,
    rhs: ?*Node = null,

    pub fn init(tok: ?Token) BinaryNode {
        return .{
            .tok = tok orelse undefined,
            .lhs = null,
            .rhs = null,
        };
    }
};
