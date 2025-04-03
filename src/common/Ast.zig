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
print_buffer: ?[]u8,
root: ?*Node = null,

pub fn init(gpa: mem.Allocator, options: AstOption) !Ast {
    var arena: heap.ArenaAllocator = .init(gpa);
    errdefer arena.deinit();

    const print_buffer = if (options.print_buffer)
        try arena.allocator().alloc(u8, options.print_buffer_size orelse 0)
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

pub fn makeLeafNode(self: *Ast, tok: ?Token) !*Node {
    const node: *Node = try self.arena.allocator().create(Node);
    node.* = Node.initLeaf(tok);
    return node;
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

pub fn printAst(writer: anytype, prefix: *std.ArrayList(u8), node: *Node) !void {
    try printAstInner(writer, prefix, node, true);
}

fn printAstInner(writer: anytype, prefix: *std.ArrayList(u8), node: *Node, isLast: bool) !void {
    // Extract token based on node kind.
    const tok = switch (node.*) {
        .leaf => node.leaf.tok,
        .unary => node.unary.tok,
        .binary => node.binary.tok,
    };

    // Print current node with proper branch character.
    if (isLast) {
        try writer.print("{s}└── {s}\n", .{ prefix.items[0..], tok });
        try prefix.appendSlice("    ");
    } else {
        try writer.print("{s}├── {s}\n", .{ prefix.items[0..], tok });
        try prefix.appendSlice("|   ");
    }
    // Save current prefix length to later restore it.
    const prev_len = prefix.items.len;

    // Recurse according to node type.
    switch (node.*) {
        .leaf => {},
        .unary => {
            if (node.unary.child) |child| {
                try printAstInner(writer, prefix, child, true);
            }
        },
        .binary => {
            var children: [2]*Node = .{ undefined, undefined };
            var count: usize = 0;
            if (node.binary.lhs) |lhs| {
                children[count] = lhs;
                count += 1;
            }
            if (node.binary.rhs) |rhs| {
                children[count] = rhs;
                count += 1;
            }
            for (children[0..count], 0..) |child, idx| {
                try printAstInner(writer, prefix, child, idx == count - 1);
            }
        },
    }

    // Restore prefix.
    try prefix.resize(prev_len);
}

pub fn format(
    self: @This(),
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = fmt;
    _ = options;

    if (self.print_buffer) |buffer| {
        var fba_instance: heap.FixedBufferAllocator = .init(buffer[0..]);
        const fba = fba_instance.allocator();

        var list = std.ArrayList(u8).init(fba);
        defer list.deinit();

        try printAst(writer, &list, self.root orelse return);
    }
}

pub const Kind = enum { unary, binary, leaf };

pub const Node = union(Kind) {
    unary: UnaryNode,
    binary: BinaryNode,
    leaf: LeafNode,

    pub fn initLeaf(tok: ?Token) Node {
        return .{ .leaf = LeafNode.init(tok) };
    }

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
            .leaf => try writer.print("{?}", .{self.leaf.tok}),
            .unary => try writer.print("{?}", .{self.unary.tok}),
            .binary => try writer.print("{?}", .{self.binary.tok}),
        }
    }
};

pub const LeafNode = struct {
    tok: Token = undefined,

    pub fn init(tok: ?Token) LeafNode {
        return .{
            .tok = tok orelse undefined,
        };
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
